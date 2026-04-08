///|
/// JS FFI bindings for VS Code extensions namespace.

///|
extern "js" fn extensions_get_extension_ffi(
  extension_id : String,
) -> @v.JsValue =
  #| (extensionId) => require("vscode").extensions.getExtension(extensionId)

///|
extern "js" fn extensions_all_ffi() -> Array[Extension[@v.JsValue]] =
  #| () => require("vscode").extensions.all

///|
extern "js" fn extensions_on_did_change_ffi() -> Event[Unit] =
  #| () => require("vscode").extensions.onDidChange

///|
extern "js" fn extensions_create_comment_controller_ffi(
  id : String,
  label : String,
) -> CommentController =
  #| (id, label) => require("vscode").comments.createCommentController(id, label)
