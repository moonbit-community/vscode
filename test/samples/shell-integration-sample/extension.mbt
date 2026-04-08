///|
/// MoonBit port of `shell-integration-sample`.
let terminal_profile_name = "Tracking Editor"

fn dirname(path : String) -> String {
  let mut end = 0
  for i, c in path {
    if c == '/' || c == '\\' {
      end = i
    }
  }
  path.unsafe_substring(start=0, end=end)
}

///|
priv struct TrackingEditorTerminalProfileProvider {
  name : String
}

///|
impl @vscode.TerminalProfileProvider for TrackingEditorTerminalProfileProvider with provide_terminal_profile(
  self,
  _token,
) {
  let options = @vscode.TerminalOptions::new(name=self.name)
  Some(@vscode.TerminalProfile::from_terminal(options))
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let profile_provider = TrackingEditorTerminalProfileProvider::{
    name: terminal_profile_name,
  }
  let profile_registration = @window.register_terminal_profile_provider(
    "shell-integration-sample.track-editor-directory",
    profile_provider,
  )
  subscriptions.push(profile_registration)

  let integration_change = @window.on_did_change_terminal_shell_integration().subscribe(
    fn(event) {
      let terminal = event.terminal
      if terminal.name() == terminal_profile_name {
        ()
      }
    },
  )
  subscriptions.push(integration_change)

  let on_open_document = @workspace.on_did_open_text_document().subscribe(
    fn(document) {
      let uri = document.uri()
      if uri.scheme() != "file" {
        ()
      } else {
        let target_uri = @vscode.Uri::file(dirname(document.file_name()))
        let target = target_uri.to_string()
        for terminal in @window.terminals() {
          if terminal.name() != terminal_profile_name {
            continue
          }
          match terminal.shell_integration() {
            None => ()
            Some(integration) => {
              match integration.cwd {
                None =>
                  ignore(integration.execute_command("cd", [target_uri.fs_path()]))
                Some(cwd) => {
                  if cwd.to_string() != target {
                    ignore(
                      integration.execute_command(
                        "cd",
                        [target_uri.fs_path()],
                      ),
                    )
                  }
                }
              }
            }
          }
        }
      }
    },
  )
  subscriptions.push(on_open_document)
}

pub fn deactivate() -> Unit {
  ()
}
