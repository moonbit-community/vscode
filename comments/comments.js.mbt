///|
/// VS Code comments namespace bindings for the JS backend.
using @vscode {type CommentController}

///|
pub fn create_comment_controller(
  id : String,
  label : String,
) -> CommentController {
  comments_create_comment_controller_ffi(id, label)
}
