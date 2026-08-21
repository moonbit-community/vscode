///|
/// Public provider contracts and non-object helper types.

///|
/// A provider result represents the values a provider, like the {@linkcode HoverProvider},
/// may return. For once this is the actual result type `T`, like `Hover`, or a thenable that resolves
/// to that type `T`. In addition, `null` and `undefined` can be returned - either directly or from a
/// thenable.
///
/// The snippets below are all valid implementations of the {@linkcode HoverProvider}:
///
/// ```ts
/// let a: HoverProvider = {
/// 	provideHover(doc, pos, token): ProviderResult<Hover> {
/// 		return new Hover('Hello World');
/// 	}
/// }
///
/// let b: HoverProvider = {
/// 	provideHover(doc, pos, token): ProviderResult<Hover> {
/// 		return new Promise(resolve => {
/// 			resolve(new Hover('Hello World'));
/// 	 	});
/// 	}
/// }
///
/// let c: HoverProvider = {
/// 	provideHover(doc, pos, token): ProviderResult<Hover> {
/// 		return; // undefined
/// 	}
/// }
/// ```
pub(all) enum ProviderResult[T] {
  Value(T)
  Async(@js_async.Promise[T?])
  NoneValue
}

///|
/// Information about where a symbol is defined.
///
/// Provides additional metadata over normal {@link Location} definitions, including the range of
/// the defining symbol
pub(all) enum DefinitionLink {
  LocationLinkValue(LocationLink)
}

///|
/// The definition of a symbol represented as one or many {@link Location locations}.
/// For most programming languages there is only one location at which a symbol is
/// defined.
pub(all) enum Definition {
  LocationValue(Location)
  Locations(Array[Location])
}

///|
/// The declaration of a symbol representation as one or many {@link Location locations}
/// or {@link LocationLink location links}.
pub(all) enum Declaration {
  LocationValue(Location)
  Locations(Array[Location])
  LocationLinks(Array[LocationLink])
}

///|
pub fn[T] ProviderResult::from_async(
  value : async () -> T?,
) -> ProviderResult[T] {
  Async(@js_async.Promise::from_async(value))
}

///|
pub fn DefinitionLink::as_location_link(value : DefinitionLink) -> LocationLink {
  match value {
    LocationLinkValue(value) => value
  }
}

///|
pub fn AuthenticationProviderOptions::new(
  supports_multiple_accounts? : Bool,
) -> AuthenticationProviderOptions {
  AuthenticationProviderOptions::{ supports_multiple_accounts, }
}

///|
pub fn AuthenticationProviderSessionOptions::new(
  account? : AuthenticationSessionAccountInformation,
) -> AuthenticationProviderSessionOptions {
  AuthenticationProviderSessionOptions::{ account, }
}

///|
pub(open) trait AuthenticationProvider {
  fn on_did_change_sessions(Self) -> Event[
    AuthenticationProviderAuthenticationSessionsChangeEvent,
  ]
  async fn get_sessions(
    Self,
    Array[String]?,
    AuthenticationProviderSessionOptions,
  ) -> Array[AuthenticationSession]
  async fn create_session(
    Self,
    Array[String],
    AuthenticationProviderSessionOptions,
  ) -> AuthenticationSession
  async fn remove_session(Self, String) -> Unit
}

///|
pub(open) trait TaskProvider {
  async fn provide_tasks(Self, CancellationToken) -> Array[Task]?
  async fn resolve_task(Self, Task, CancellationToken) -> Task?
}

///|
pub fn UriHandler::new(handle_uri : async (Uri) -> Unit) -> UriHandler {
  uri_handler_ffi(uri => @js_async.Promise::from_async(() => handle_uri(uri)))
}

///|
pub fn WebviewPanelSerializer::new(
  deserialize : async (WebviewPanel, Any) -> Unit,
) -> WebviewPanelSerializer {
  webview_panel_serializer_ffi((panel, state) => {
    @js_async.Promise::from_async(() => deserialize(panel, state))
  })
}

///|
extern "js" fn uri_handler_ffi(
  handle_uri : (Uri) -> @js_async.Promise[Unit],
) -> UriHandler =
  #| (handleUri) => ({ handleUri })

///|
extern "js" fn webview_panel_serializer_ffi(
  deserialize : (WebviewPanel, Any) -> @js_async.Promise[Unit],
) -> WebviewPanelSerializer =
  #| (deserializeWebviewPanel) => ({ deserializeWebviewPanel })
