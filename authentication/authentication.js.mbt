///|
/// VS Code authentication namespace bindings for the JS backend.
using @vscode {
  type AuthenticationGetSessionOptions,
  type AuthenticationProviderInformation,
  type AuthenticationProviderOptions,
  type AuthenticationSession,
  type AuthenticationSessionAccountInformation,
  type AuthenticationSessionsChangeEvent,
  type AuthenticationWwwAuthenticateRequest,
  type Event,
}

///|
fn[T : @vscode.AuthenticationProvider] authentication_provider_object(
  provider : T,
) -> @providers.AuthenticationProviderObject {
  @providers.AuthenticationProviderObject::new(
    provider.on_did_change_sessions(),
    async fn(scopes, options) { provider.get_sessions(scopes, options) },
    async fn(scopes, options) { provider.create_session(scopes, options) },
    async fn(session_id) { provider.remove_session(session_id) },
  )
}

///|
fn authentication_provider_options_to_js(
  options : AuthenticationProviderOptions,
) -> @v.JsValue {
  authentication_provider_options_to_js_ffi(
    @v.option_to_js(options.supports_multiple_accounts),
  )
}

///|
fn authentication_provider_information_array_from_js(
  values : Array[@v.JsValue],
) -> Array[AuthenticationProviderInformation] {
  let providers : Array[AuthenticationProviderInformation] = []
  for provider in values {
    match authentication_provider_information_from_js(provider) {
      Some(value) => providers.push(value)
      None => ()
    }
  }
  providers
}

///|
fn authentication_account_information_array_from_js(
  values : Array[@v.JsValue],
) -> Array[AuthenticationSessionAccountInformation] {
  let accounts : Array[AuthenticationSessionAccountInformation] = []
  for account in values {
    match authentication_session_account_information_from_js(account) {
      Some(value) => accounts.push(value)
      None => ()
    }
  }
  accounts
}

///|
fn authentication_get_session_options_to_js(
  options : AuthenticationGetSessionOptions?,
) -> @v.JsValue {
  match options {
    None => @v.JsValue::make(())
    Some(value) => authentication_get_session_options_value_to_js(value)
  }
}

///|
fn authentication_get_session_options_value_to_js(
  options : AuthenticationGetSessionOptions,
) -> @v.JsValue {
  let create_if_none = match options.create_if_none {
    None => @v.JsValue::make(())
    Some(value) => authentication_create_if_none_to_js(value)
  }
  let force_new_session = match options.force_new_session {
    None => @v.JsValue::make(())
    Some(value) => authentication_force_new_session_value_to_js(value)
  }
  let account = match options.account {
    None => @v.JsValue::make(())
    Some(value) => authentication_session_account_information_to_js(value)
  }
  authentication_get_session_options_to_js_ffi(
    @v.option_to_js(options.clear_session_preference),
    create_if_none,
    force_new_session,
    @v.option_to_js(options.silent),
    account,
  )
}

///|
fn authentication_create_if_none_to_js(
  value : @vscode.AuthenticationGetSessionPresentationOptionsCreateIfNone,
) -> @v.JsValue {
  match value {
    BoolValue(value) => @v.JsValue::make(value)
    AuthenticationGetSessionPresentationOptions(value) =>
      authentication_get_session_presentation_options_to_js(value)
  }
}

///|
fn authentication_force_new_session_value_to_js(
  value : @vscode.AuthenticationForceNewSessionValue,
) -> @v.JsValue {
  match value {
    BoolValue(value) => @v.JsValue::make(value)
    AuthenticationGetSessionPresentationOptions(value) =>
      authentication_get_session_presentation_options_to_js(value)
    AuthenticationForceNewSessionOptions(value) =>
      authentication_force_new_session_options_to_js(value)
  }
}

///|
fn authentication_get_session_presentation_options_to_js(
  value : @vscode.AuthenticationGetSessionPresentationOptions,
) -> @v.JsValue {
  authentication_get_session_presentation_options_to_js_ffi(
    @v.option_to_js(value.detail),
  )
}

///|
fn authentication_force_new_session_options_to_js(
  value : @vscode.AuthenticationForceNewSessionOptions,
) -> @v.JsValue {
  authentication_force_new_session_options_to_js_ffi(
    @v.option_to_js(value.detail),
  )
}

///|
fn authentication_session_account_information_to_js(
  value : AuthenticationSessionAccountInformation,
) -> @v.JsValue {
  authentication_session_account_information_to_js_ffi(
    value.id(),
    value.label(),
  )
}

///|
fn authentication_provider_information_from_js(
  value : @v.JsValue,
) -> AuthenticationProviderInformation? {
  let id = authentication_provider_information_id_raw(value)
  let label = authentication_provider_information_label_raw(value)
  match (auth_js_value_as_string_ffi(id), auth_js_value_as_string_ffi(label)) {
    (Some(id), Some(label)) =>
      Some(AuthenticationProviderInformation::new(id, label))
    _ => None
  }
}

///|
fn authentication_session_account_information_from_js(
  value : @v.JsValue,
) -> AuthenticationSessionAccountInformation? {
  let id = authentication_session_account_information_id_raw(value)
  let label = authentication_session_account_information_label_raw(value)
  match (auth_js_value_as_string_ffi(id), auth_js_value_as_string_ffi(label)) {
    (Some(id), Some(label)) =>
      Some(AuthenticationSessionAccountInformation::new(id, label))
    _ => None
  }
}

///|
fn authentication_session_from_js(value : @v.JsValue) -> AuthenticationSession? {
  let id_raw = authentication_session_id_raw(value)
  let access_token_raw = authentication_session_access_token_raw(value)
  let account_raw = authentication_session_account_raw(value)
  let scopes_raw = authentication_session_scopes_raw(value)
  match
    (
      auth_js_value_as_string_ffi(id_raw),
      auth_js_value_as_string_ffi(access_token_raw),
      authentication_session_account_information_from_js(account_raw),
    ) {
    (Some(id), Some(access_token), Some(account)) =>
      if scopes_raw.is_null_or_undefined() {
        None
      } else {
        Some(
          AuthenticationSession::new(
            id,
            access_token,
            account,
            scopes_raw.cast(),
          ),
        )
      }
    _ => None
  }
}

///|

///|
pub fn providers() -> Array[AuthenticationProviderInformation] {
  authentication_provider_information_array_from_js(
    authentication_providers_ffi(),
  )
}

///|
/// An {@link Event} which fires when the authentication sessions of an authentication provider have
/// been added, removed, or changed.
pub fn on_did_change_sessions() -> Event[AuthenticationSessionsChangeEvent] {
  authentication_on_did_change_sessions_ffi()
}

///|
/// Get all accounts that the user is logged in to for the specified provider.
/// Use this paired with {@link getSession} in order to get an authentication session for a specific account.
///
/// Currently, there are only two authentication providers that are contributed from built in extensions
/// to the editor that implement GitHub and Microsoft authentication: their providerId's are 'github' and 'microsoft'.
///
/// Note: Getting accounts does not imply that your extension has access to that account or its authentication sessions. You can verify access to the account by calling {@link getSession}.
///
/// @param providerId The id of the provider to use
/// @returns A thenable that resolves to a readonly array of authentication accounts.
pub async fn get_accounts(
  provider_id : String,
) -> Array[AuthenticationSessionAccountInformation] {
  authentication_account_information_array_from_js(
    @js_async.Promise::wait(authentication_get_accounts_ffi(provider_id)),
  )
}

///|
/// Get an authentication session matching the desired scopes or satisfying the WWW-Authenticate request. Rejects if
/// a provider with providerId is not registered, or if the user does not consent to sharing authentication information
/// with the extension. If there are multiple sessions with the same scopes, the user will be shown a quickpick to
/// select which account they would like to use.
///
/// Built-in auth providers include:
/// * 'github' - For GitHub.com
/// * 'microsoft' For both personal & organizational Microsoft accounts
/// * (less common) 'github-enterprise' - for alternative GitHub hostings, GHE.com, GitHub Enterprise Server
/// * (less common) 'microsoft-sovereign-cloud' - for alternative Microsoft clouds
///
/// @param providerId The id of the provider to use
/// @param scopeListOrRequest A scope list of permissions requested or a WWW-Authenticate request. These are dependent on the authentication provider.
/// @param options The {@link AuthenticationGetSessionOptions} to use
/// @returns A thenable that resolves to an authentication session
pub async fn get_session(
  provider_id : String,
  scopes : Array[String],
  options? : AuthenticationGetSessionOptions,
) -> AuthenticationSession? {
  let raw = @js_async.Promise::wait(
    authentication_get_session_with_scopes_ffi(
      provider_id,
      scopes,
      authentication_get_session_options_to_js(options),
    ),
  )
  if raw.is_null_or_undefined() {
    None
  } else {
    match authentication_session_from_js(raw) {
      Some(value) => Some(value)
      None => Some(raw.cast())
    }
  }
}

///|
/// Get an authentication session matching the desired scopes or satisfying the WWW-Authenticate request. Rejects if
/// a provider with providerId is not registered, or if the user does not consent to sharing authentication information
/// with the extension. If there are multiple sessions with the same scopes, the user will be shown a quickpick to
/// select which account they would like to use.
///
/// Built-in auth providers include:
/// * 'github' - For GitHub.com
/// * 'microsoft' For both personal & organizational Microsoft accounts
/// * (less common) 'github-enterprise' - for alternative GitHub hostings, GHE.com, GitHub Enterprise Server
/// * (less common) 'microsoft-sovereign-cloud' - for alternative Microsoft clouds
///
/// @param providerId The id of the provider to use
/// @param scopeListOrRequest A scope list of permissions requested or a WWW-Authenticate request. These are dependent on the authentication provider.
/// @param options The {@link AuthenticationGetSessionOptions} to use
/// @returns A thenable that resolves to an authentication session
pub async fn get_session_from_request(
  provider_id : String,
  request : AuthenticationWwwAuthenticateRequest,
  options? : AuthenticationGetSessionOptions,
) -> AuthenticationSession? {
  let raw = @js_async.Promise::wait(
    authentication_get_session_with_request_ffi(
      provider_id,
      request.www_authenticate,
      @v.option_to_js(request.fallback_scopes),
      authentication_get_session_options_to_js(options),
    ),
  )
  if raw.is_null_or_undefined() {
    None
  } else {
    match authentication_session_from_js(raw) {
      Some(value) => Some(value)
      None => Some(raw.cast())
    }
  }
}

///|
/// Register an authentication provider.
///
/// There can only be one provider per id and an error is being thrown when an id
/// has already been used by another provider. Ids are case-sensitive.
///
/// @param id The unique identifier of the provider.
/// @param label The human-readable name of the provider.
/// @param provider The authentication provider provider.
/// @param options Additional options for the provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.AuthenticationProvider] register_authentication_provider(
  id : String,
  label : String,
  provider : T,
  options? : AuthenticationProviderOptions,
) -> &@vscode.Disposable {
  let options_js = match options {
    None => @v.JsValue::make(())
    Some(value) => authentication_provider_options_to_js(value)
  }
  authentication_register_authentication_provider_ffi(
    id,
    label,
    authentication_provider_object(provider),
    options_js,
  )
}

///|
extern "js" fn authentication_provider_options_to_js_ffi(
  supports_multiple_accounts : @v.JsValue,
) -> @v.JsValue =
  #| (supportsMultipleAccounts) => {
  #|   const options = {};
  #|   if (supportsMultipleAccounts !== undefined && supportsMultipleAccounts !== null) {
  #|     options.supportsMultipleAccounts = supportsMultipleAccounts;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn authentication_get_session_presentation_options_to_js_ffi(
  detail : @v.JsValue,
) -> @v.JsValue =
  #| (detail) => ({
  #|   detail: detail === undefined || detail === null ? undefined : detail,
  #| })

///|
extern "js" fn authentication_force_new_session_options_to_js_ffi(
  detail : @v.JsValue,
) -> @v.JsValue =
  #| (detail) => ({
  #|   detail: detail === undefined || detail === null ? undefined : detail,
  #| })

///|
extern "js" fn authentication_get_session_options_to_js_ffi(
  clear_session_preference : @v.JsValue,
  create_if_none : @v.JsValue,
  force_new_session : @v.JsValue,
  silent : @v.JsValue,
  account : @v.JsValue,
) -> @v.JsValue =
  #| (clearSessionPreference, createIfNone, forceNewSession, silent, account) => {
  #|   const options = {};
  #|   if (clearSessionPreference !== undefined && clearSessionPreference !== null) {
  #|     options.clearSessionPreference = clearSessionPreference;
  #|   }
  #|   if (createIfNone !== undefined && createIfNone !== null) {
  #|     options.createIfNone = createIfNone;
  #|   }
  #|   if (forceNewSession !== undefined && forceNewSession !== null) {
  #|     options.forceNewSession = forceNewSession;
  #|   }
  #|   if (silent !== undefined && silent !== null) {
  #|     options.silent = silent;
  #|   }
  #|   if (account !== undefined && account !== null) {
  #|     options.account = account;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn authentication_session_account_information_to_js_ffi(
  id : String,
  label : String,
) -> @v.JsValue =
  #| (id, label) => ({ id, label })

///|
extern "js" fn auth_js_value_as_string_ffi(value : @v.JsValue) -> String? =
  #| (value) => typeof value === "string" ? value : undefined

///|
extern "js" fn authentication_provider_information_id_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.id

///|
extern "js" fn authentication_provider_information_label_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.label

///|
extern "js" fn authentication_session_account_information_id_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.id

///|
extern "js" fn authentication_session_account_information_label_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.label

///|
extern "js" fn authentication_session_id_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.id

///|
extern "js" fn authentication_session_access_token_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.accessToken

///|
extern "js" fn authentication_session_account_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.account

///|
extern "js" fn authentication_session_scopes_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.scopes
