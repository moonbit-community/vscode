///|
/// VS Code extensions namespace bindings for the JS backend.
using @vscode {type CommentController, type Event, type Extension, type Any}

///|
/// Get an extension by its full identifier in the form of: `publisher.name`.
///
/// @param extensionId An extension identifier.
/// @returns An extension or `undefined`.
pub fn[T] get_extension(extension_id : String) -> Extension[T]? {
  let raw = extensions_get_extension_ffi(extension_id)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// All extensions currently known to the system.
pub fn all() -> Array[Extension[Any]] {
  extensions_all_ffi().map(ext => @v.JsValue::make(ext).cast())
}

///|
/// An event which fires when `extensions.all` changes. This can happen when extensions are
/// installed, uninstalled, enabled or disabled.
pub fn on_did_change() -> Event[Unit] {
  extensions_on_did_change_ffi()
}

///|
pub fn create_comment_controller(
  id : String,
  label : String,
) -> CommentController {
  extensions_create_comment_controller_ffi(id, label)
}
