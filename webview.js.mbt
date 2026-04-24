///|
/// Webview-related helpers.

///|
/// Defines a port mapping used for localhost inside the webview.
pub struct WebviewPortMapping {
  webview_port : Int
  extension_host_port : Int
}

///|
pub(all) enum CommandUrisValue {
  Enabled(Bool)
  List(Array[String])
}

///|
pub fn WebviewPortMapping::new(
  webview_port : Int,
  extension_host_port : Int,
) -> WebviewPortMapping {
  WebviewPortMapping::{ webview_port, extension_host_port }
}

///|
pub fn WebviewOptions::new(
  enable_scripts? : Bool,
  enable_forms? : Bool,
  enable_command_uris? : CommandUrisValue,
  local_resource_roots? : Array[Uri],
  port_mapping? : Array[WebviewPortMapping],
) -> WebviewOptions {
  WebviewOptions::{
    enable_scripts,
    enable_forms,
    enable_command_uris,
    local_resource_roots,
    port_mapping,
  }
}

///|
pub fn WebviewPanelOptions::new(
  enable_find_widget? : Bool,
  retain_context_when_hidden? : Bool,
) -> WebviewPanelOptions {
  WebviewPanelOptions::{ enable_find_widget, retain_context_when_hidden }
}

///|
pub fn WebviewViewOptions::new(
  retain_context_when_hidden? : Bool,
) -> WebviewViewOptions {
  WebviewViewOptions::{ retain_context_when_hidden, }
}

///|
fn[T] webview_js_to_option(value : JsValue) -> T? {
  if value.is_null_or_undefined() {
    None
  } else {
    Some(value.cast())
  }
}

///|
fn[T] webview_option_to_js(value : T?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => JsValue::make(value)
  }
}

///|
/// Content settings for the webview.
pub extern "js" fn Webview::options(self : Webview) -> WebviewOptions =
  #| (webview) => webview.options

///|
/// Content settings for the webview.
pub extern "js" fn Webview::set_options(
  self : Webview,
  value : WebviewOptions,
) -> Unit =
  #| (webview, value) => { webview.options = value; }

///|
/// HTML contents of the webview.
///
/// This should be a complete, valid html document. Changing this property causes the webview to be reloaded.
///
/// Webviews are sandboxed from normal extension process, so all communication with the webview must use
/// message passing. To send a message from the extension to the webview, use {@linkcode Webview.postMessage postMessage}.
/// To send message from the webview back to an extension, use the `acquireVsCodeApi` function inside the webview
/// to get a handle to the editor's api and then call `.postMessage()`:
///
/// ```html
/// <script>
///     const vscode = acquireVsCodeApi(); // acquireVsCodeApi can only be invoked once
///     vscode.postMessage({ message: 'hello!' });
/// </script>
/// ```
///
/// To load a resources from the workspace inside a webview, use the {@linkcode Webview.asWebviewUri asWebviewUri} method
/// and ensure the resource's directory is listed in {@linkcode WebviewOptions.localResourceRoots}.
///
/// Keep in mind that even though webviews are sandboxed, they still allow running scripts and loading arbitrary content,
/// so extensions must follow all standard web security best practices when working with webviews. This includes
/// properly sanitizing all untrusted input (including content from the workspace) and
/// setting a [content security policy](https://aka.ms/vscode-api-webview-csp).
pub extern "js" fn Webview::html(self : Webview) -> String =
  #| (webview) => webview.html

///|
/// HTML contents of the webview.
///
/// This should be a complete, valid html document. Changing this property causes the webview to be reloaded.
///
/// Webviews are sandboxed from normal extension process, so all communication with the webview must use
/// message passing. To send a message from the extension to the webview, use {@linkcode Webview.postMessage postMessage}.
/// To send message from the webview back to an extension, use the `acquireVsCodeApi` function inside the webview
/// to get a handle to the editor's api and then call `.postMessage()`:
///
/// ```html
/// <script>
///     const vscode = acquireVsCodeApi(); // acquireVsCodeApi can only be invoked once
///     vscode.postMessage({ message: 'hello!' });
/// </script>
/// ```
///
/// To load a resources from the workspace inside a webview, use the {@linkcode Webview.asWebviewUri asWebviewUri} method
/// and ensure the resource's directory is listed in {@linkcode WebviewOptions.localResourceRoots}.
///
/// Keep in mind that even though webviews are sandboxed, they still allow running scripts and loading arbitrary content,
/// so extensions must follow all standard web security best practices when working with webviews. This includes
/// properly sanitizing all untrusted input (including content from the workspace) and
/// setting a [content security policy](https://aka.ms/vscode-api-webview-csp).
pub extern "js" fn Webview::set_html(self : Webview, value : String) -> Unit =
  #| (webview, value) => { webview.html = value; }

///|
/// Fired when the webview content posts a message.
///
/// Webview content can post strings or json serializable objects back to an extension. They cannot
/// post `Blob`, `File`, `ImageData` and other DOM specific objects since the extension that receives the
/// message does not run in a browser environment.
pub extern "js" fn Webview::on_did_receive_message(
  self : Webview,
) -> Event[Any] =
  #| (webview) => webview.onDidReceiveMessage

///|
fn Webview::post_message_promise(
  self : Webview,
  message : Any,
) -> @js_async.Promise[Bool] {
  webview_post_message_ffi(self, JsValue::make(message))
}

///|
/// Post a message to the webview content.
///
/// Messages are only delivered if the webview is live (either visible or in the
/// background with `retainContextWhenHidden`).
///
/// @param message Body of the message. This must be a string or other json serializable object.
///
///   For older versions of vscode, if an `ArrayBuffer` is included in `message`,
///   it will not be serialized properly and will not be received by the webview.
///   Similarly any TypedArrays, such as a `Uint8Array`, will be very inefficiently
///   serialized and will also not be recreated as a typed array inside the webview.
///
///   However if your extension targets vscode 1.57+ in the `engines` field of its
///   `package.json`, any `ArrayBuffer` values that appear in `message` will be more
///   efficiently transferred to the webview and will also be correctly recreated inside
///   of the webview.
///
/// @returns A promise that resolves when the message is posted to a webview or when it is
/// dropped because the message was not deliverable.
///
///   Returns `true` if the message was posted to the webview. Messages can only be posted to
/// live webviews (i.e. either visible webviews or hidden webviews that set `retainContextWhenHidden`).
///
///   A response of `true` does not mean that the message was actually received by the webview.
///   For example, no message listeners may be have been hooked up inside the webview or the webview may
///   have been destroyed after the message was posted but before it was received.
///
///   If you want confirm that a message as actually received, you can try having your webview posting a
///   confirmation message back to your extension.
pub async fn Webview::post_message(self : Webview, message : Any) -> Bool {
  @js_async.Promise::wait(Webview::post_message_promise(self, message))
}

///|
/// Convert a uri for the local file system to one that can be used inside webviews.
///
/// Webviews cannot directly load resources from the workspace or local file system using `file:` uris. The
/// `asWebviewUri` function takes a local `file:` uri and converts it into a uri that can be used inside of
/// a webview to load the same resource:
///
/// ```ts
/// webview.html = `<img src="${webview.asWebviewUri(vscode.Uri.file('/Users/codey/workspace/cat.gif'))}">`
/// ```
pub extern "js" fn Webview::as_webview_uri(
  self : Webview,
  local_resource : Uri,
) -> Uri =
  #| (webview, localResource) => webview.asWebviewUri(localResource)

///|
/// Content security policy source for webview resources.
///
/// This is the origin that should be used in a content security policy rule:
///
/// ```ts
/// `img-src https: ${webview.cspSource} ...;`
/// ```
pub extern "js" fn Webview::csp_source(self : Webview) -> String =
  #| (webview) => webview.cspSource

///|
/// Identifies the type of the webview panel, such as `'markdown.preview'`.
pub extern "js" fn WebviewPanel::view_type(self : WebviewPanel) -> String =
  #| (panel) => panel.viewType

///|
/// Title of the panel shown in UI.
pub extern "js" fn WebviewPanel::title(self : WebviewPanel) -> String =
  #| (panel) => panel.title

///|
/// Title of the panel shown in UI.
pub extern "js" fn WebviewPanel::set_title(
  self : WebviewPanel,
  value : String,
) -> Unit =
  #| (panel, value) => { panel.title = value; }

///|
/// Icon for the panel shown in UI.
pub fn WebviewPanel::icon_path(self : WebviewPanel) -> IconPath? {
  webview_js_to_option(webview_panel_icon_path_raw(self))
}

///|
/// Icon for the panel shown in UI.
pub fn WebviewPanel::set_icon_path(
  self : WebviewPanel,
  value : IconPath?,
) -> Unit {
  webview_panel_set_icon_path_raw(self, webview_option_to_js(value))
}

///|
/// Icon for the panel shown in UI.
pub fn WebviewPanel::clear_icon_path(self : WebviewPanel) -> Unit {
  webview_panel_set_icon_path_raw(self, JsValue::make(()))
}

///|
/// {@linkcode Webview} belonging to the panel.
pub extern "js" fn WebviewPanel::webview(self : WebviewPanel) -> Webview =
  #| (panel) => panel.webview

///|
/// Content settings for the webview panel.
pub extern "js" fn WebviewPanel::options(
  self : WebviewPanel,
) -> WebviewPanelOptions =
  #| (panel) => panel.options

///|
/// Editor position of the panel. This property is only set if the webview is in
/// one of the editor view columns.
pub fn WebviewPanel::view_column(self : WebviewPanel) -> ViewColumn? {
  webview_js_to_option(webview_panel_view_column_raw(self))
}

///|
/// Whether the panel is active (focused by the user).
pub extern "js" fn WebviewPanel::active(self : WebviewPanel) -> Bool =
  #| (panel) => panel.active

///|
/// Whether the panel is visible.
pub extern "js" fn WebviewPanel::visible(self : WebviewPanel) -> Bool =
  #| (panel) => panel.visible

///|
/// Fired when the panel's view state changes.
pub extern "js" fn WebviewPanel::on_did_change_view_state(
  self : WebviewPanel,
) -> Event[WebviewPanelOnDidChangeViewStateEvent] =
  #| (panel) => panel.onDidChangeViewState

///|
/// Fired when the panel is disposed.
///
/// This may be because the user closed the panel or because `.dispose()` was
/// called on it.
///
/// Trying to use the panel after it has been disposed throws an exception.
pub extern "js" fn WebviewPanel::on_did_dispose(
  self : WebviewPanel,
) -> Event[Unit] =
  #| (panel) => panel.onDidDispose

///|
/// Show the webview panel in a given column.
///
/// A webview panel may only show in a single column at a time. If it is already showing, this
/// method moves it to a new column.
///
/// @param viewColumn View column to show the panel in. Shows in the current `viewColumn` if undefined.
/// @param preserveFocus When `true`, the webview will not take focus.
pub fn WebviewPanel::reveal(
  self : WebviewPanel,
  view_column? : ViewColumn,
  preserve_focus? : Bool = false,
) -> Unit {
  webview_panel_reveal_raw(
    self,
    webview_option_view_column_to_js(view_column),
    preserve_focus,
  )
}

///|
fn webview_view_column_to_js_value(value : ViewColumn) -> JsValue {
  let raw = match value {
    Active => -1
    Beside => -2
    One => 1
    Two => 2
    Three => 3
    Four => 4
    Five => 5
    Six => 6
    Seven => 7
    Eight => 8
    Nine => 9
    Custom(value) => value
  }
  JsValue::make(raw)
}

///|
fn webview_option_view_column_to_js(value : ViewColumn?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => webview_view_column_to_js_value(value)
  }
}

///|
extern "js" fn webview_panel_reveal_raw(
  panel : WebviewPanel,
  view_column : JsValue,
  preserve_focus : Bool,
) -> Unit =
  #| (panel, viewColumn, preserveFocus) => panel.reveal(viewColumn, preserveFocus)

///|
extern "js" fn webview_panel_icon_path_raw(panel : WebviewPanel) -> JsValue =
  #| (panel) => panel.iconPath

///|
extern "js" fn webview_panel_set_icon_path_raw(
  panel : WebviewPanel,
  value : JsValue,
) -> Unit =
  #| (panel, value) => { panel.iconPath = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn webview_panel_view_column_raw(panel : WebviewPanel) -> JsValue =
  #| (panel) => panel.viewColumn

///|
/// Dispose of the webview panel.
///
/// This closes the panel if it showing and disposes of the resources owned by the webview.
/// Webview panels are also disposed when the user closes the webview panel. Both cases
/// fire the `onDidDispose` event.
extern "js" fn webview_panel_dispose_raw(panel : WebviewPanel) -> Unit =
  #| (panel) => panel.dispose()

///|
pub fn WebviewPanel::dispose(self : WebviewPanel) -> Unit {
  webview_panel_dispose_raw(self)
}

///|
pub impl AsDisposable for WebviewPanel with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// Event fired when a webview panel's view state changes.
pub struct WebviewPanelOnDidChangeViewStateEvent {
  webviewPanel : WebviewPanel
}

///|
/// Webview panel whose view state changed.
pub fn WebviewPanelOnDidChangeViewStateEvent::new(
  webview_panel : WebviewPanel,
) -> WebviewPanelOnDidChangeViewStateEvent {
  WebviewPanelOnDidChangeViewStateEvent::{ webviewPanel: webview_panel }
}

///|
/// Webview panel whose view state changed.

///|
/// Identifies the type of the webview view, such as `'hexEditor.dataView'`.
pub extern "js" fn WebviewView::view_type(self : WebviewView) -> String =
  #| (view) => view.viewType

///|
/// The underlying webview for the view.
pub extern "js" fn WebviewView::webview(self : WebviewView) -> Webview =
  #| (view) => view.webview

///|
/// View title displayed in the UI.
///
/// The view title is initially taken from the extension `package.json` contribution.
pub fn WebviewView::title(self : WebviewView) -> String? {
  webview_js_to_option(webview_view_title_raw(self))
}

///|
/// View title displayed in the UI.
///
/// The view title is initially taken from the extension `package.json` contribution.
pub fn WebviewView::set_title(self : WebviewView, value : String?) -> Unit {
  webview_view_set_title_raw(self, webview_option_to_js(value))
}

///|
/// View title displayed in the UI.
///
/// The view title is initially taken from the extension `package.json` contribution.
pub fn WebviewView::clear_title(self : WebviewView) -> Unit {
  webview_view_set_title_raw(self, JsValue::make(()))
}

///|
/// Human-readable string which is rendered less prominently in the title.
pub fn WebviewView::description(self : WebviewView) -> String? {
  webview_js_to_option(webview_view_description_raw(self))
}

///|
/// Human-readable string which is rendered less prominently in the title.
pub fn WebviewView::set_description(
  self : WebviewView,
  value : String?,
) -> Unit {
  webview_view_set_description_raw(self, webview_option_to_js(value))
}

///|
/// Human-readable string which is rendered less prominently in the title.
pub fn WebviewView::clear_description(self : WebviewView) -> Unit {
  webview_view_set_description_raw(self, JsValue::make(()))
}

///|
/// The badge to display for this webview view.
/// To remove the badge, set to undefined.
pub fn WebviewView::badge(self : WebviewView) -> ViewBadge? {
  webview_js_to_option(webview_view_badge_raw(self))
}

///|
/// The badge to display for this webview view.
/// To remove the badge, set to undefined.
pub fn WebviewView::set_badge(self : WebviewView, value : ViewBadge?) -> Unit {
  webview_view_set_badge_raw(self, webview_option_to_js(value))
}

///|
/// The badge to display for this webview view.
/// To remove the badge, set to undefined.
pub fn WebviewView::clear_badge(self : WebviewView) -> Unit {
  webview_view_set_badge_raw(self, JsValue::make(()))
}

///|
/// Event fired when the view is disposed.
///
/// Views are disposed when they are explicitly hidden by a user (this happens when a user
/// right clicks in a view and unchecks the webview view).
///
/// Trying to use the view after it has been disposed throws an exception.
pub extern "js" fn WebviewView::on_did_dispose(
  self : WebviewView,
) -> Event[Unit] =
  #| (view) => view.onDidDispose

///|
/// Tracks if the webview is currently visible.
///
/// Views are visible when they are on the screen and expanded.
pub extern "js" fn WebviewView::visible(self : WebviewView) -> Bool =
  #| (view) => view.visible

///|
/// Event fired when the visibility of the view changes.
///
/// Actions that trigger a visibility change:
///
/// - The view is collapsed or expanded.
/// - The user switches to a different view group in the sidebar or panel.
///
/// Note that hiding a view using the context menu instead disposes of the view and fires `onDidDispose`.
pub extern "js" fn WebviewView::on_did_change_visibility(
  self : WebviewView,
) -> Event[Unit] =
  #| (view) => view.onDidChangeVisibility

///|
/// Reveal the view in the UI.
///
/// If the view is collapsed, this will expand it.
///
/// @param preserveFocus When `true` the view will not take focus.
pub extern "js" fn WebviewView::show(
  self : WebviewView,
  preserve_focus? : Bool = false,
) -> Unit =
  #| (view, preserveFocus) => view.show(preserveFocus)

///|
extern "js" fn webview_view_title_raw(view : WebviewView) -> JsValue =
  #| (view) => view.title

///|
extern "js" fn webview_view_set_title_raw(
  view : WebviewView,
  value : JsValue,
) -> Unit =
  #| (view, value) => { view.title = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn webview_view_description_raw(view : WebviewView) -> JsValue =
  #| (view) => view.description

///|
extern "js" fn webview_view_set_description_raw(
  view : WebviewView,
  value : JsValue,
) -> Unit =
  #| (view, value) => { view.description = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn webview_view_badge_raw(view : WebviewView) -> JsValue =
  #| (view) => view.badge

///|
extern "js" fn webview_view_set_badge_raw(
  view : WebviewView,
  value : JsValue,
) -> Unit =
  #| (view, value) => { view.badge = value === undefined || value === null ? undefined : value; }

///|
/// Persisted state from the webview content.
///
/// To save resources, the editor normally deallocates webview documents (the iframe content) that are not visible.
/// For example, when the user collapse a view or switches to another top level activity in the sidebar, the
/// `WebviewView` itself is kept alive but the webview's underlying document is deallocated. It is recreated when
/// the view becomes visible again.
///
/// You can prevent this behavior by setting `retainContextWhenHidden` in the `WebviewOptions`. However this
/// increases resource usage and should be avoided wherever possible. Instead, you can use persisted state to
/// save off a webview's state so that it can be quickly recreated as needed.
///
/// To save off a persisted state, inside the webview call `acquireVsCodeApi().setState()` with
/// any json serializable object. To restore the state again, call `getState()`. For example:
///
/// ```js
/// // Within the webview
/// const vscode = acquireVsCodeApi();
///
/// // Get existing state
/// const oldState = vscode.getState() || { value: 0 };
///
/// // Update state
/// setState({ value: oldState.value + 1 })
/// ```
///
/// The editor ensures that the persisted state is saved correctly when a webview is hidden and across
/// editor restarts.
pub fn WebviewViewResolveContext::new(
  state? : Any,
) -> WebviewViewResolveContext {
  WebviewViewResolveContext::{ state, }
}

///|
/// Persisted state from the webview content.
///
/// To save resources, the editor normally deallocates webview documents (the iframe content) that are not visible.
/// For example, when the user collapse a view or switches to another top level activity in the sidebar, the
/// `WebviewView` itself is kept alive but the webview's underlying document is deallocated. It is recreated when
/// the view becomes visible again.
///
/// You can prevent this behavior by setting `retainContextWhenHidden` in the `WebviewOptions`. However this
/// increases resource usage and should be avoided wherever possible. Instead, you can use persisted state to
/// save off a webview's state so that it can be quickly recreated as needed.
///
/// To save off a persisted state, inside the webview call `acquireVsCodeApi().setState()` with
/// any json serializable object. To restore the state again, call `getState()`. For example:
///
/// ```js
/// // Within the webview
/// const vscode = acquireVsCodeApi();
///
/// // Get existing state
/// const oldState = vscode.getState() || { value: 0 };
///
/// // Update state
/// setState({ value: oldState.value + 1 })
/// ```
///
/// The editor ensures that the persisted state is saved correctly when a webview is hidden and across
/// editor restarts.

///|
extern "js" fn webview_post_message_ffi(
  webview : Webview,
  message : JsValue,
) -> @js_async.Promise[Bool] =
  #| (webview, message) => webview.postMessage(message)
