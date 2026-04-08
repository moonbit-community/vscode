///|
/// JS entrypoint for authentication namespace binding checks.

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-authentication-fixture")
  }
}

///|
fn fixture_uri(root : @vscode.Uri, name : String) -> @vscode.Uri {
  @vscode.Uri::join_path(root, [name])
}

///|
async fn write_result(
  root : @vscode.Uri,
  name : String,
  content : String,
) -> Unit {
  let fs = @workspace.fs()
  fs.write_file(fixture_uri(root, name), @workspace.encode(content))
}

///|
struct FixtureAuthenticationProvider {
  sessions_event :
    @vscode.Event[@vscode.AuthenticationProviderAuthenticationSessionsChangeEvent]
}

///|
pub impl @vscode.AuthenticationProvider for FixtureAuthenticationProvider with on_did_change_sessions(
  self,
) {
  self.sessions_event
}

///|
pub impl @vscode.AuthenticationProvider for FixtureAuthenticationProvider with get_sessions(
  _self,
  _scopes,
  _options,
) {
  []
}

///|
pub impl @vscode.AuthenticationProvider for FixtureAuthenticationProvider with create_session(
  _self,
  _scopes,
  _options,
) {
  panic()
}

///|
pub impl @vscode.AuthenticationProvider for FixtureAuthenticationProvider with remove_session(
  _self,
  _session_id,
) {
  ()
}

///|
async fn run_check_authentication(root : @vscode.Uri) -> Unit {
  write_result(root, "authentication-result.txt", "authentication step=0")

  let id = "moonbit-authentication-provider"
  let provider_infos = @authentication.providers()
  write_result(
    root,
    "authentication-result.txt",
    "authentication step=1 providers=\{provider_infos.length()}",
  )

  let emitter = @vscode.EventEmitter::new()
  let provider = FixtureAuthenticationProvider::{ sessions_event: emitter.event() }
  write_result(root, "authentication-result.txt", "authentication step=2")

  let registration = @authentication.register_authentication_provider(
    id,
    "MoonBit Authentication Provider",
    provider,
  )
  write_result(root, "authentication-result.txt", "authentication step=3")

  let session_change = @authentication.on_did_change_sessions().subscribe(_ => ())
  session_change.dispose()
  write_result(root, "authentication-result.txt", "authentication step=4")

  let presentation_options = @vscode.AuthenticationGetSessionPresentationOptions::new(
    detail="MoonBit authentication detail",
  )
  let force_new_options = @vscode.AuthenticationForceNewSessionOptions::new(
    detail="MoonBit force new session detail",
  )
  let create_if_none =
    @vscode.AuthenticationGetSessionPresentationOptionsCreateIfNone::AuthenticationGetSessionPresentationOptions(
    presentation_options,
  )
  let force_new_session = @vscode.AuthenticationForceNewSessionValue::AuthenticationForceNewSessionOptions(
    force_new_options,
  )
  let complex_options = @vscode.AuthenticationGetSessionOptions::new(
    clear_session_preference=true,
    create_if_none=create_if_none,
    force_new_session=force_new_session,
    silent=true,
  )
  let silent_options = @vscode.AuthenticationGetSessionOptions::new(silent=true)
  let maybe_session = @authentication.get_session(
    id,
    ["moonbit.scope"],
    options=silent_options,
  )
  let session_state = match maybe_session {
    None => "none"
    Some(_) => "some"
  }

  let www_auth_request = @vscode.AuthenticationWwwAuthenticateRequest::new(
    "Bearer scope=\"moonbit.scope\"",
    fallback_scopes=["moonbit.scope"],
  )
  let accounts = @authentication.get_accounts(id)
  if false {
    ignore(
      @authentication.get_session_from_request(
        id,
        www_auth_request,
        options=silent_options,
      ),
    )
  } else {
    ()
  }
  let request_session_state = "skipped_unsupported_provider"
  let fallback_scope_count = match www_auth_request.fallback_scopes {
    None => 0
    Some(value) => value.length()
  }
  let presentation_detail = match presentation_options.detail {
    None => "none"
    Some(value) => value
  }
  let force_detail = match force_new_options.detail {
    None => "none"
    Some(value) => value
  }
  let complex_silent = match complex_options.silent {
    None => "none"
    Some(value) => if value { "true" } else { "false" }
  }

  registration.dispose()
  emitter.dispose()
  write_result(root, "authentication-result.txt", "authentication step=5")

  let after_dispose_infos = @authentication.providers()

  write_result(
    root,
    "authentication-result.txt",
    "authentication ok providers_before=\{provider_infos.length()} providers_after=\{after_dispose_infos.length()} accounts=\{accounts.length()} session=\{session_state} request_session=\{request_session_state} request=\{www_auth_request.www_authenticate} fallback_scopes=\{fallback_scope_count} detail=\{presentation_detail} force_detail=\{force_detail} complex_silent=\{complex_silent}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.authentication.checkBindings",
    async fn(_args) {
      run_check_authentication(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
