///|
/// Clipboard helpers.

///|
extern "js" fn Clipboard::read_text_promise(
  self : Clipboard,
) -> @js_async.Promise[String] =
  #| (clipboard) => clipboard.readText()

///|
/// Read the current clipboard contents as text.
/// @returns A thenable that resolves to a string.
pub async fn Clipboard::read_text(self : Clipboard) -> String {
  @js_async.Promise::wait(Clipboard::read_text_promise(self))
}

///|
extern "js" fn Clipboard::write_text_promise(
  self : Clipboard,
  value : String,
) -> @js_async.Promise[Unit] =
  #| (clipboard, value) => clipboard.writeText(value)

///|
/// Writes text into the clipboard.
/// @returns A thenable that resolves when writing happened.
pub async fn Clipboard::write_text(self : Clipboard, value : String) -> Unit {
  @js_async.Promise::wait(Clipboard::write_text_promise(self, value))
}
