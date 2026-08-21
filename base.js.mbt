///|
/// Base JS interop types for VS Code API bindings.

///|
/// Shared JS value carrier from the internal package.
type JsValue = @v.JsValue

///|
/// A disposable resource handle returned by VS Code APIs.
pub type Disposable

///|
/// A value that can expose a VS Code disposable handle.
pub(open) trait AsDisposable {
  fn as_disposable(Self) -> Disposable
}

///|
pub impl AsDisposable for Disposable with fn as_disposable(self) {
  self
}

///|
/// Create a disposable that invokes a callback when disposed.
pub extern "js" fn Disposable::new(call_on_dispose : () -> Unit) -> Disposable =
  #| (callOnDispose) => new (require("vscode").Disposable)(() => callOnDispose())

///|
/// Combine many disposables into one disposable.
pub extern "js" fn Disposable::from(
  disposables : Array[Disposable],
) -> Disposable =
  #| (disposables) => require("vscode").Disposable.from(...disposables)

///|
/// Dispose this object.
pub extern "js" fn Disposable::dispose(self : Disposable) -> Unit =
  #| (disposable) => disposable.dispose()

///|
fn[T] disposable_from_js(value : T) -> Disposable {
  JsValue::make(value).cast()
}

///|
/// VS Code extension host version.
pub extern "js" fn version() -> String =
  #| () => require("vscode").version
