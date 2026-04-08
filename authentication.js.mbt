///|
/// Authentication helpers.

///|
pub extern "js" fn AuthenticationSessionAccountInformation::id(
  self : AuthenticationSessionAccountInformation,
) -> String =
  #| (value) => value.id

///|
pub extern "js" fn AuthenticationSessionAccountInformation::label(
  self : AuthenticationSessionAccountInformation,
) -> String =
  #| (value) => value.label

///|
pub extern "js" fn AuthenticationSession::id(
  self : AuthenticationSession,
) -> String =
  #| (value) => value.id

///|
pub extern "js" fn AuthenticationSession::access_token(
  self : AuthenticationSession,
) -> String =
  #| (value) => value.accessToken

///|
pub extern "js" fn AuthenticationSession::account(
  self : AuthenticationSession,
) -> AuthenticationSessionAccountInformation =
  #| (value) => value.account

///|
pub extern "js" fn AuthenticationSession::scopes(
  self : AuthenticationSession,
) -> Array[String] =
  #| (value) => value.scopes
