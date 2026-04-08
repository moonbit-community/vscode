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
extern "js" fn l10n_t_args_ffi(message : String, args : Array[Any]) -> String =
  #| (message, args) => require("vscode").l10n.t(message, ...args)

///|
extern "js" fn l10n_t_named_ffi(
  message : String,
  args : Array[(String, Any)],
) -> String =
  #| (message, args) => require("vscode").l10n.t(message, Object.fromEntries(args))
