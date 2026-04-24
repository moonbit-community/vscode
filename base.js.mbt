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
/// Dispose a resource returned by VS Code or implemented as a MoonBit trait object.
pub fn disposable_dispose(disposable : &Disposable) -> Unit {
  disposable_dispose_ffi(disposable_to_js_ffi(disposable))
}

///|
/// Create a disposable that invokes a callback when disposed.
pub fn disposable_new(call_on_dispose : () -> Unit) -> &Disposable {
  disposable_new_ffi(call_on_dispose)
}

///|
/// Combine many disposables into one disposable.
pub fn disposable_from(disposables : Array[&Disposable]) -> &Disposable {
  disposable_from_ffi(disposables.map(disposable_to_js_ffi))
}

///|
extern "js" fn disposable_new_ffi(call_on_dispose : () -> Unit) -> &Disposable =
  #| (callOnDispose) => new (require("vscode").Disposable)(() => callOnDispose())

///|
extern "js" fn disposable_from_ffi(disposables : Array[JsValue]) -> &Disposable =
  #| (disposables) => require("vscode").Disposable.from(...disposables)

///|
extern "js" fn disposable_dispose_ffi(disposable : JsValue) -> Unit =
  #| (disposable) => disposable.dispose()

///|
extern "js" fn disposable_to_js_ffi(disposable : &Disposable) -> JsValue =
  #| (disposable) => {
  #|   const value =
  #|     disposable && typeof disposable.dispose === "function"
  #|       ? disposable
  #|       : disposable &&
  #|           disposable.self !== undefined &&
  #|           disposable.method_table &&
  #|           typeof disposable.method_table.method_0 === "function"
  #|         ? { dispose: () => disposable.method_table.method_0(disposable.self) }
  #|         : disposable;
  #|   return value;
  #| }

///|
/// VS Code extension host version.
pub extern "js" fn version() -> String =
  #| () => require("vscode").version
