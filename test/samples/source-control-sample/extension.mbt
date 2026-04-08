///|
/// MoonBit port of `source-control-sample`.
let jsfiddle_scheme = "jsfiddle"
let jsfiddle_uri : @vscode.Uri = @vscode.Uri::parse("jsfiddle:/fiddle.js")

priv struct JsFiddleContentProvider {
  on_change : @vscode.Event[@vscode.Uri]
}

priv struct ScmState {
  mut version : Int
  mut dirty : Bool
  mut source : @vscode.SourceControl?
  mut group : @vscode.SourceControlResourceGroup?
  mut change_emitter : @vscode.EventEmitter[@vscode.Uri]?
}

let scm_state : ScmState = {
  version: 1,
  dirty: false,
  source: None,
  group: None,
  change_emitter: None,
}

fn jsfiddle_content() -> String {
  "// MoonBit JSFiddle sample\n// version: \{scm_state.version}\nconsole.log('hello from source-control-sample');\n"
}

fn refresh_source_control() -> Unit {
  match scm_state.group {
    None => ()
    Some(group) => {
      if scm_state.dirty {
        let state = @vscode.SourceControlResourceState::new(
          jsfiddle_uri,
          command=@vscode.Command::new(
            "extension.source-control.open",
            "Open JS Fiddle",
          ),
        )
        group.set_resource_states([state])
      } else {
        group.set_resource_states([])
      }
    }
  }
  match scm_state.source {
    None => ()
    Some(source) => {
      if scm_state.dirty {
        source.set_count(1)
      } else {
        source.clear_count()
      }
    }
  }

  match scm_state.change_emitter {
    Some(emitter) => emitter.fire(jsfiddle_uri)
    None => ()
  }
}

impl @vscode.TextDocumentContentProvider for JsFiddleContentProvider with on_did_change(
  self,
) {
  Some(self.on_change)
}

impl @vscode.TextDocumentContentProvider for JsFiddleContentProvider with provide_text_document_content(
  _self,
  _uri,
  _token,
) {
  jsfiddle_content()
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let emitter : @vscode.EventEmitter[@vscode.Uri] = @vscode.EventEmitter::new()
  scm_state.change_emitter = Some(emitter)

  let provider = JsFiddleContentProvider::{ on_change: emitter.event(), }
  subscriptions.push(
    @workspace.register_text_document_content_provider(jsfiddle_scheme, provider),
  )

  let source = @scm.create_source_control(
    "moonbit-jsfiddle",
    "MoonBit JS Fiddle",
  )
  source.set_accept_input_command(@vscode.Command::new(
      "extension.source-control.commit",
      "Commit local changes to JS Fiddle",
    ))
  let group = source.create_resource_group("changes", "Changes")
  scm_state.source = Some(source)
  scm_state.group = Some(group)
  refresh_source_control()

  subscriptions.push(
    @workspace.on_did_change_text_document().subscribe(fn(event) {
      if event.document.uri().scheme() == jsfiddle_scheme {
        scm_state.dirty = true
        refresh_source_control()
      }
    }),
  )

  let open_command = @commands.register_command_async(
    "extension.source-control.open",
    async fn(_args) {
      let doc = @workspace.open_text_document_uri(jsfiddle_uri)
      ignore(@window.show_text_document(doc))
    },
  )
  subscriptions.push(open_command)

  let refresh_command = @commands.register_command(
    "extension.source-control.refresh",
    fn(_args) {
      refresh_source_control()
    },
  )
  subscriptions.push(refresh_command)

  let commit_command = @commands.register_command_async(
    "extension.source-control.commit",
    async fn(_args) {
      scm_state.version = scm_state.version + 1
      scm_state.dirty = false
      refresh_source_control()
      ignore(@window.show_information_message("Committed local JS Fiddle changes."))
    },
  )
  subscriptions.push(commit_command)

  let discard_command = @commands.register_command_async(
    "extension.source-control.discard",
    async fn(_args) {
      scm_state.dirty = false
      refresh_source_control()
      ignore(@window.show_information_message("Discarded local JS Fiddle changes."))
    },
  )
  subscriptions.push(discard_command)

  let checkout_command = @commands.register_command_async(
    "extension.source-control.checkout",
    async fn(_args) {
      scm_state.version = scm_state.version + 1
      scm_state.dirty = false
      refresh_source_control()
      ignore(@window.show_information_message("Checked out another JS Fiddle version."))
    },
  )
  subscriptions.push(checkout_command)

  let browse_command = @commands.register_command_async(
    "extension.source-control.browse",
    async fn(_args) {
      ignore(@env.open_external(@vscode.Uri::parse("https://jsfiddle.net/")))
    },
  )
  subscriptions.push(browse_command)
}

pub fn deactivate() -> Unit {
  ()
}
