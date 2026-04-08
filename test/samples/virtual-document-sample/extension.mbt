///|
/// MoonBit port of `virtual-document-sample`.
let cowsay_scheme = "cowsay"

///|
fn reverse_text(value : String) -> String {
  value.rev()
}

fn render_cowsay(path_text : String) -> String {
  let message = if path_text == "" { "moo" } else { path_text }
  let edge = "_".repeat(message.length() + 2)
  let bottom = "-".repeat(message.length() + 2)
  [
    " \{edge}",
    "< \{message} >",
    " \{bottom}",
    "        \\\\   ^__^",
    "         \\\\  (oo)\\\\_______",
    "            (__)\\\\       )\\\\/\\\\",
    "                ||----w |",
    "                ||     ||",
  ].join("\n")
}

priv struct CowsayContentProvider {}

impl @vscode.TextDocumentContentProvider for CowsayContentProvider with on_did_change(
  _self,
) {
  None
}

impl @vscode.TextDocumentContentProvider for CowsayContentProvider with provide_text_document_content(
  _self,
  uri,
  _token,
) {
  render_cowsay(uri.path())
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  subscriptions.push(
    @workspace.register_text_document_content_provider(
      cowsay_scheme,
      CowsayContentProvider::{},
    ),
  )

  let say = @commands.register_command_async(
    "cowsay.say",
    async fn(_args) {
      let input = @window.show_input_box(
        options=@vscode.InputBoxOptions::new(place_holder="cowsay..."),
      )
      match input {
        None => ()
        Some(what) => {
          let uri = @vscode.Uri::parse("\{cowsay_scheme}:\{what}")
          let doc = @workspace.open_text_document_uri(uri)
          ignore(
            @window.show_text_document(
              doc,
              options=@vscode.TextDocumentShowOptions::new(preview=false),
            ),
          )
        }
      }
    },
  )
  subscriptions.push(say)

  let backwards = @commands.register_command_async(
    "cowsay.backwards",
    async fn(_args) {
      match @window.active_text_editor() {
        None => ()
        Some(editor) => {
          let uri = editor.document().uri()
          if uri.scheme() != cowsay_scheme {
            ()
          } else {
            let reversed = reverse_text(uri.path())
            let new_uri = @vscode.Uri::parse("\{cowsay_scheme}:\{reversed}")
            let doc = @workspace.open_text_document_uri(new_uri)
            ignore(
              @window.show_text_document(
                doc,
                options=@vscode.TextDocumentShowOptions::new(preview=false),
              ),
            )
          }
        }
      }
    },
  )
  subscriptions.push(backwards)
}

pub fn deactivate() -> Unit {
  ()
}
