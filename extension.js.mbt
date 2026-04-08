///|
/// Extension helpers.

///|
pub(all) enum ExtensionKind {
  UI = 1
  Workspace = 2
} derive(Eq)

///|
fn[T] extension_cast(ext : Extension[T]) -> Extension[JsValue] {
  JsValue::make(ext).cast()
}

///|
/// The canonical extension identifier in the form of: `publisher.name`.
pub fn[T] Extension::id(self : Extension[T]) -> String {
  extension_id_raw(extension_cast(self))
}

///|
/// The uri of the directory containing the extension.
pub fn[T] Extension::extension_uri(self : Extension[T]) -> Uri {
  extension_uri_raw(extension_cast(self))
}

///|
/// The absolute file path of the directory containing this extension. Shorthand
/// notation for {@link Extension.extensionUri Extension.extensionUri.fsPath} (independent of the uri scheme).
pub fn[T] Extension::extension_path(self : Extension[T]) -> String {
  extension_path_raw(extension_cast(self))
}

///|
/// `true` if the extension has been activated.
pub fn[T] Extension::is_active(self : Extension[T]) -> Bool {
  extension_is_active_raw(extension_cast(self))
}

///|
pub fn[T] Extension::package_json(self : Extension[T]) -> Any {
  JsValue::make(extension_package_json_raw(extension_cast(self))).cast()
}

///|
/// The extension kind describes if an extension runs where the UI runs
/// or if an extension runs where the remote extension host runs. The extension kind
/// is defined in the `package.json`-file of extensions but can also be refined
/// via the `remote.extensionKind`-setting. When no remote extension host exists,
/// the value is {@linkcode ExtensionKind.UI}.
pub fn[T] Extension::extension_kind(self : Extension[T]) -> ExtensionKind {
  extension_kind_raw(extension_cast(self))
}

///|
/// The extension kind describes if an extension runs where the UI runs
/// or if an extension runs where the remote extension host runs. The extension kind
/// is defined in the `package.json`-file of extensions but can also be refined
/// via the `remote.extensionKind`-setting. When no remote extension host exists,
/// the value is {@linkcode ExtensionKind.UI}.
pub fn[T] Extension::set_extension_kind(
  self : Extension[T],
  value : ExtensionKind,
) -> Unit {
  extension_kind_set_raw(extension_cast(self), value)
}

///|
/// The public API exported by this extension (return value of `activate`).
/// It is an invalid action to access this field before this extension has been activated.
pub fn[T] Extension::exports(self : Extension[T]) -> T {
  extension_exports_raw(extension_cast(self)).cast()
}

///|
extern "js" fn extension_activate_promise(
  ext : Extension[JsValue],
) -> @js_async.Promise[JsValue] =
  #| (ext) => ext.activate()

///|
/// Activates this extension and returns its public API.
///
/// @returns A promise that will resolve when this extension has been activated.
pub async fn[T] Extension::activate(self : Extension[T]) -> T {
  let raw = @js_async.Promise::wait(
    extension_activate_promise(extension_cast(self)),
  )
  raw.cast()
}

///|
/// Run async activation logic from a synchronous VS Code `activate` entrypoint.
///
/// Example:
/// `pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {`
/// `  @vscode.activate_async(ctx, async_activate)`
/// `}`
pub fn activate_async(
  ctx : ExtensionContext,
  async_activate : async (ExtensionContext) -> Unit,
) -> Unit {
  let _ = @js_async.Promise::from_async(async fn() { async_activate(ctx) })
}

///|
extern "js" fn extension_id_raw(ext : Extension[JsValue]) -> String =
  #| (ext) => ext.id

///|
extern "js" fn extension_uri_raw(ext : Extension[JsValue]) -> Uri =
  #| (ext) => ext.extensionUri

///|
extern "js" fn extension_path_raw(ext : Extension[JsValue]) -> String =
  #| (ext) => ext.extensionPath

///|
extern "js" fn extension_is_active_raw(ext : Extension[JsValue]) -> Bool =
  #| (ext) => ext.isActive

///|
extern "js" fn extension_package_json_raw(ext : Extension[JsValue]) -> JsValue =
  #| (ext) => ext.packageJSON

///|
extern "js" fn extension_kind_raw(ext : Extension[JsValue]) -> ExtensionKind =
  #| (ext) => ext.extensionKind

///|
extern "js" fn extension_kind_set_raw(
  ext : Extension[JsValue],
  value : ExtensionKind,
) -> Unit =
  #| (ext, value) => { ext.extensionKind = value; }

///|
extern "js" fn extension_exports_raw(ext : Extension[JsValue]) -> JsValue =
  #| (ext) => ext.exports
