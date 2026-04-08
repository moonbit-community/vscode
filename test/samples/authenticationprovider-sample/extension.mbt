///|
/// MoonBit port of `authenticationprovider-sample`.
let azure_devops_provider_id = "azuredevopspat"

///|
let azure_devops_provider_label = "Azure Repos"

///|
let azure_devops_pat_secret_key = "AzureDevOpsPAT"

///|
let azure_devops_profile_api = "https://app.vssps.visualstudio.com/_apis/profile/profiles/me?api-version=6.0"

///|
let login_command = "vscode-authenticationprovider-sample.login"

///|
priv suberror AuthenticationSampleError {
  PatRequired
  ProfileRequestFailed(Int, String)
}

///|
fn basic_auth_header(access_token : String) -> String {
  let token = @utf8.encode(":\{access_token}")
  let encoded = @base64.encode(token[:])
  "Basic \{encoded}"
}

///|
fn profile_display_name(profile : Json) -> String {
  if profile is { "displayName": String(display_name), .. } {
    display_name
  } else {
    ""
  }
}

///|
async fn fetch_azure_devops_profile_display_name(
  access_token : String,
) -> String {
  let (response, body) = @http.get(azure_devops_profile_api, headers={
    "authorization": basic_auth_header(access_token),
    "content-type": "application/json",
  })
  if response.code != 200 {
    raise ProfileRequestFailed(response.code, response.reason)
  }
  profile_display_name(body.json())
}

///|
fn create_if_none_options() -> @vscode.AuthenticationGetSessionOptions {
  @vscode.AuthenticationGetSessionOptions::new(
    create_if_none=BoolValue(true),
  )
}

///|
fn azure_devops_pat_session(
  access_token : String,
) -> @vscode.AuthenticationSession {
  let account = @vscode.AuthenticationSessionAccountInformation::new(
    azure_devops_provider_id, "Personal Access Token",
  )
  @vscode.AuthenticationSession::new(
    azure_devops_provider_id,
    access_token,
    account,
    [],
  )
}

///|
fn first_session(
  sessions : Array[@vscode.AuthenticationSession],
) -> @vscode.AuthenticationSession? {
  match sessions {
    [value, ..] => Some(value)
    [] => None
  }
}

///|
priv struct AzureDevOpsAuthenticationProvider {
  secret_storage : @vscode.SecretStorage
  mut current_token : String?
  mut is_initialized : Bool
  mut is_disposed : Bool
  mut listeners : Array[&@vscode.Disposable]
  on_did_change_sessions_emitter : @vscode.EventEmitter[
    @vscode.AuthenticationProviderAuthenticationSessionsChangeEvent,
  ]
  on_did_change_sessions_event : @vscode.Event[
    @vscode.AuthenticationProviderAuthenticationSessionsChangeEvent,
  ]
}

///|
fn AzureDevOpsAuthenticationProvider::new(
  secret_storage : @vscode.SecretStorage,
) -> AzureDevOpsAuthenticationProvider {
  let emitter : @vscode.EventEmitter[
    @vscode.AuthenticationProviderAuthenticationSessionsChangeEvent,
  ] = @vscode.EventEmitter::new()
  AzureDevOpsAuthenticationProvider::{
    secret_storage,
    current_token: None,
    is_initialized: false,
    is_disposed: false,
    listeners: [],
    on_did_change_sessions_emitter: emitter,
    on_did_change_sessions_event: emitter.event(),
  }
}

///|
async fn AzureDevOpsAuthenticationProvider::cache_token_from_storage(
  self : AzureDevOpsAuthenticationProvider,
) -> String? {
  let token = self.secret_storage.get(azure_devops_pat_secret_key)
  self.current_token = token
  token
}

///|
async fn AzureDevOpsAuthenticationProvider::ensure_initialized(
  self : AzureDevOpsAuthenticationProvider,
) -> Unit {
  if self.is_initialized || self.is_disposed {
    return
  }
  self.is_initialized = true
  let _ = self.cache_token_from_storage()

  let secret_change_listener = self.secret_storage
    .on_did_change()
    .subscribe_async(async fn(event) {
      if event.key == azure_devops_pat_secret_key {
        self.check_for_updates()
      }
    })
  self.listeners.push(secret_change_listener)

  let session_change_listener = @authentication.on_did_change_sessions().subscribe_async(async fn(
      event,
    ) {
      if event.provider.id == azure_devops_provider_id {
        self.check_for_updates()
      }
    },
  )
  self.listeners.push(session_change_listener)
}

///|
async fn AzureDevOpsAuthenticationProvider::check_for_updates(
  self : AzureDevOpsAuthenticationProvider,
) -> Unit {
  let added = []
  let removed = []
  let changed = []

  let previous_token = self.current_token
  let current_session = first_session(
    self.get_sessions(None, @vscode.AuthenticationProviderSessionOptions::new()),
  )

  match previous_token {
    None =>
      match current_session {
        None => return ()
        Some(session) => added.push(session)
      }
    Some(previous_token) =>
      match current_session {
        None => removed.push(azure_devops_pat_session(previous_token))
        Some(session) =>
          if session.access_token() == previous_token {
            return ()
          } else {
            changed.push(session)
          }
      }
  }

  let _ = self.cache_token_from_storage()
  self.on_did_change_sessions_emitter.fire(
    @vscode.AuthenticationProviderAuthenticationSessionsChangeEvent::new(
      added~,
      removed~,
      changed~,
    ),
  )
}

///|
impl @vscode.AuthenticationProvider for AzureDevOpsAuthenticationProvider with on_did_change_sessions(
  self,
) {
  self.on_did_change_sessions_event
}

///|
impl @vscode.AuthenticationProvider for AzureDevOpsAuthenticationProvider with get_sessions(
  self,
  _scopes,
  _options,
) {
  self.ensure_initialized()
  match self.cache_token_from_storage() {
    None => []
    Some(token) => [azure_devops_pat_session(token)]
  }
}

///|
impl @vscode.AuthenticationProvider for AzureDevOpsAuthenticationProvider with create_session(
  self,
  _scopes,
  _options,
) {
  self.ensure_initialized()

  let token = match
    @window.show_input_box(
      options=@vscode.InputBoxOptions::new(
        ignore_focus_out=true,
        place_holder="Personal access token",
        prompt="Enter an Azure DevOps Personal Access Token (PAT).",
        password=true,
      ),
    ) {
    None => raise PatRequired
    Some(value) => if value == "" { raise PatRequired } else { value }
  }

  self.secret_storage.store(azure_devops_pat_secret_key, token)
  azure_devops_pat_session(token)
}

///|
impl @vscode.AuthenticationProvider for AzureDevOpsAuthenticationProvider with remove_session(
  self,
  _session_id,
) {
  match self.current_token {
    None => ()
    Some(token) => {
      self.secret_storage.delete(azure_devops_pat_secret_key)
      self.on_did_change_sessions_emitter.fire(
        @vscode.AuthenticationProviderAuthenticationSessionsChangeEvent::new(
          removed=[azure_devops_pat_session(token)],
          added=[],
          changed=[],
        ),
      )
    }
  }
}

///|
impl @vscode.Disposable for AzureDevOpsAuthenticationProvider with dispose(self) {
  if self.is_disposed {
    return
  }
  self.is_disposed = true
  for listener in self.listeners {
    listener.dispose()
  }
  self.listeners = []
  self.on_did_change_sessions_emitter.dispose()
}

///|
pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()
  let provider = AzureDevOpsAuthenticationProvider::new(context.secrets())

  subscriptions.push(
    @authentication.register_authentication_provider(
      azure_devops_provider_id, azure_devops_provider_label, provider,
    ),
  )
  subscriptions.push(provider)

  subscriptions.push(
    @commands.register_command_async(login_command, async fn(_args) {
      let session = @authentication.get_session(
        azure_devops_provider_id,
        [],
        options=create_if_none_options(),
      )
      match session {
        None => ()
        Some(session) =>
          try {
            let display_name = fetch_azure_devops_profile_display_name(
              session.access_token(),
            )
            @window.show_information_message("Hello \{display_name}")
          } catch {
            ProfileRequestFailed(status, reason) => {
              if status == 401 {
                @window.show_error_message(
                  "Failed to get profile. You need to use a PAT that has access to all organizations. Please sign out and try again.",
                )
              }
              raise ProfileRequestFailed(status, reason)
            }
            err => raise err
          }
      }
    }),
  )
}

///|
pub fn deactivate() -> Unit {
  ()
}
