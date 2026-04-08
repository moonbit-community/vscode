///|
/// MoonBit port of `webview-view-sample`.
priv struct ColorsViewState {
  mut view : @vscode.WebviewView?
  mut extension_uri : @vscode.Uri?
}

fn get_nonce() -> String {
  "moonbit-calico-colors-nonce"
}

fn message_type(value : @vscode.Any) -> String? {
  value.object_get_string("type")
}

fn message_value(value : @vscode.Any) -> String? {
  value.object_get_string("value")
}

fn add_color_message() -> @vscode.Any {
  @vscode.Any::empty_object().object_with_string("type", "addColor")
}

fn clear_colors_message() -> @vscode.Any {
  @vscode.Any::empty_object().object_with_string("type", "clearColors")
}

fn insert_color_snippet(color : String) -> Unit {
  let _ = @js_async.Promise::from_async(async fn() {
    match @window.active_text_editor() {
      None => ()
      Some(editor) => {
        ignore(editor.insert_snippet(@vscode.SnippetString::new("#\{color}")))
      }
    }
  })
}

fn html_for_webview(
  webview : @vscode.Webview,
  extension_uri : @vscode.Uri,
) -> String {
  let script_uri = webview.as_webview_uri(
    @vscode.Uri::join_path(extension_uri, ["media", "main.js"]),
  )
  let style_reset_uri = webview.as_webview_uri(
    @vscode.Uri::join_path(extension_uri, ["media", "reset.css"]),
  )
  let style_vscode_uri = webview.as_webview_uri(
    @vscode.Uri::join_path(extension_uri, ["media", "vscode.css"]),
  )
  let style_main_uri = webview.as_webview_uri(
    @vscode.Uri::join_path(extension_uri, ["media", "main.css"]),
  )
  let nonce = get_nonce()

  [
    "<!DOCTYPE html>",
    "<html lang=\"en\">",
    "<head>",
    "  <meta charset=\"UTF-8\">",
    "  <meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'none'; style-src \{webview.csp_source()}; script-src 'nonce-\{nonce}';\">",
    "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">",
    "  <link href=\"\{style_reset_uri.to_string()}\" rel=\"stylesheet\">",
    "  <link href=\"\{style_vscode_uri.to_string()}\" rel=\"stylesheet\">",
    "  <link href=\"\{style_main_uri.to_string()}\" rel=\"stylesheet\">",
    "  <title>Cat Colors</title>",
    "</head>",
    "<body>",
    "  <ul class=\"color-list\"></ul>",
    "  <button class=\"add-color-button\">Add Color</button>",
    "  <script nonce=\"\{nonce}\" src=\"\{script_uri.to_string()}\"></script>",
    "</body>",
    "</html>",
  ].join("\n")
}

fn handle_webview_message(message : @vscode.Any) -> Unit {
  match message_type(message) {
    Some("colorSelected") =>
      match message_value(message) {
        Some(value) => insert_color_snippet(value)
        None => ()
      }
    _ => ()
  }
}

priv struct ColorsViewProvider {
  mut _tag : Unit
}

impl @vscode.WebviewViewProvider for ColorsViewProvider with resolve_webview_view(
  self,
  webview_view,
  _context,
  _token,
) {
  ignore(self)
  colors_state.view = Some(webview_view)

  match colors_state.extension_uri {
    None => ()
    Some(extension_uri) => {
      webview_view.webview().set_options(@vscode.WebviewOptions::new(
          enable_scripts=true,
          local_resource_roots=[extension_uri],
        ))
      webview_view.webview().set_html(html_for_webview(webview_view.webview(), extension_uri))
    }
  }

  ignore(webview_view.webview().on_did_receive_message().subscribe(fn(message) {
    handle_webview_message(message)
  }))
}

let colors_state : ColorsViewState = { view: None, extension_uri: None }

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()
  colors_state.extension_uri = Some(context.extension_uri())
  let provider = ColorsViewProvider::{ _tag: (), }

  subscriptions.push(
    @window.register_webview_view_provider("calicoColors.colorsView", provider),
  )

  subscriptions.push(
    @commands.register_command_async("calicoColors.addColor", async fn(_args) {
      match colors_state.view {
        None => ()
        Some(view) => {
          view.show(preserve_focus=true)
          ignore(view.webview().post_message(add_color_message()))
        }
      }
    }),
  )

  subscriptions.push(
    @commands.register_command_async("calicoColors.clearColors", async fn(_args) {
      match colors_state.view {
        None => ()
        Some(view) => {
          ignore(view.webview().post_message(clear_colors_message()))
        }
      }
    }),
  )
}

pub fn deactivate() -> Unit {
  ()
}
