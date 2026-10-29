///|
/// JS FFI bindings for VS Code l10n namespace.

///|
extern "js" fn l10n_bundle_ffi() -> @v.JsValue =
  #| () => require("vscode").l10n.bundle

///|
extern "js" fn l10n_uri_ffi() -> @v.JsValue =
  #| () => require("vscode").l10n.uri

///|
extern "js" fn l10n_t_ffi(message : String) -> String =
  #| (message) => require("vscode").l10n.t(message)

///|
fn l10n_t_args_ffi(message : String, args : Array[Any]) -> String {
  l10n_t_args_ffi_fixedarray_ffi(message, FixedArray::from_array(args[:]))
}

///|
extern "js" fn l10n_t_args_ffi_fixedarray_ffi(
  message : String,
  args : FixedArray[Any],
) -> String =
  #| (message, args) => require("vscode").l10n.t(message, ...args)

///|
fn l10n_t_named_ffi(message : String, args : Array[(String, Any)]) -> String {
  l10n_t_named_ffi_fixedarray_ffi(message, FixedArray::from_array(args[:]))
}

///|
extern "js" fn l10n_t_named_ffi_fixedarray_ffi(
  message : String,
  args : FixedArray[(String, Any)],
) -> String =
  #| (message, args) => require("vscode").l10n.t(message, Object.fromEntries(args))
