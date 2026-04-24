///|
/// JS FFI bindings for VS Code authentication namespace.

///|
extern "js" fn authentication_providers_ffi() -> Array[@v.JsValue] =
  #| () => {
  #|   const providers = require("vscode").authentication.providers;
  #|   return Array.isArray(providers) ? providers : [];
  #| }

///|
extern "js" fn authentication_on_did_change_sessions_ffi() -> Event[
  AuthenticationSessionsChangeEvent,
] =
  #| () => require("vscode").authentication.onDidChangeSessions

///|
extern "js" fn authentication_get_accounts_ffi(
  provider_id : String,
) -> @js_async.Promise[Array[@v.JsValue]] =
  #| (providerId) => require("vscode").authentication.getAccounts(providerId)

///|
extern "js" fn authentication_get_session_with_scopes_ffi(
  provider_id : String,
  scopes : Array[String],
  options : @v.JsValue,
) -> @js_async.Promise[@v.JsValue] =
  #| (providerId, scopes, options) => {
  #|   const authentication = require("vscode").authentication;
  #|   return options === undefined || options === null
  #|     ? authentication.getSession(providerId, scopes)
  #|     : authentication.getSession(providerId, scopes, options);
  #| }

///|
extern "js" fn authentication_get_session_with_request_ffi(
  provider_id : String,
  www_authenticate : String,
  fallback_scopes : @v.JsValue,
  options : @v.JsValue,
) -> @js_async.Promise[@v.JsValue] =
  #| (providerId, wwwAuthenticate, fallbackScopes, options) => {
  #|   const authentication = require("vscode").authentication;
  #|   const request = { wwwAuthenticate };
  #|   if (fallbackScopes !== undefined && fallbackScopes !== null) {
  #|     request.fallbackScopes = fallbackScopes;
  #|   }
  #|   return options === undefined || options === null
  #|     ? authentication.getSession(providerId, request)
  #|     : authentication.getSession(providerId, request, options);
  #| }

///|
extern "js" fn authentication_register_authentication_provider_ffi(
  id : String,
  label : String,
  provider : @providers.AuthenticationProviderObject,
  options : @v.JsValue,
) -> @vscode.Disposable =
  #| (id, label, provider, options) => {
  #|   const authentication = require("vscode").authentication;
  #|   return options === undefined || options === null
  #|     ? authentication.registerAuthenticationProvider(id, label, provider)
  #|     : authentication.registerAuthenticationProvider(id, label, provider, options);
  #| }
