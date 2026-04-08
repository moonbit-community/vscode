///|
/// Base JS interop types for VS Code API bindings.

///|
/// Shared JS value carrier from the internal package.
type JsValue = @v.JsValue

///|
/// A disposable resource contract returned by VS Code APIs.
pub(open) trait Disposable {
  dispose(Self) -> Unit
}

///|
/// VS Code extension host version.
pub extern "js" fn version() -> String =
  #| () => require("vscode").version
