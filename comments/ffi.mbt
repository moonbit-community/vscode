///|
/// JS FFI bindings for VS Code comments namespace.

///|
extern "js" fn comments_create_comment_controller_ffi(
  id : String,
  label : String,
) -> CommentController =
  #| (id, label) => require("vscode").comments.createCommentController(id, label)
