///|
/// MoonBit port of `github-authentication-sample`.
fn github_session_options(create_if_none : Bool) -> @vscode.AuthenticationGetSessionOptions {
  @vscode.AuthenticationGetSessionOptions::new(create_if_none=BoolValue(create_if_none))
}

async fn fetch_github_session(
  create_if_none : Bool,
) -> @vscode.AuthenticationSession? {
  @authentication.get_session(
    "github",
    ["user:email"],
    options=github_session_options(create_if_none),
  )
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let sessions_disposable = @authentication.on_did_change_sessions().subscribe(
    fn(event) {
      if event.provider.id == "github" {
        ()
      }
    },
  )
  subscriptions.push(sessions_disposable)

  let command = @commands.register_command_async(
    "extension.getGitHubUser",
    async fn(_args) {
      match fetch_github_session(true) {
        Some(session) => {
          let login = session.account().label()
          ignore(@window.show_information_message("Logged into GitHub as \{login}"))
        }
        None => {
          ignore(@window.show_warning_message("GitHub login was cancelled."))
        }
      }
    },
  )
  subscriptions.push(command)
}

pub fn deactivate() -> Unit {
  ()
}
