///|
/// JS FFI bindings for VS Code env namespace.

///|
extern "js" fn env_app_name_ffi() -> String =
  #| () => require("vscode").env.appName

///|
extern "js" fn env_app_root_ffi() -> String =
  #| () => require("vscode").env.appRoot

///|
extern "js" fn env_app_host_ffi() -> String =
  #| () => require("vscode").env.appHost

///|
extern "js" fn env_uri_scheme_ffi() -> String =
  #| () => require("vscode").env.uriScheme

///|
extern "js" fn env_language_ffi() -> String =
  #| () => require("vscode").env.language

///|
extern "js" fn env_clipboard_ffi() -> Clipboard =
  #| () => require("vscode").env.clipboard

///|
extern "js" fn env_machine_id_ffi() -> String =
  #| () => require("vscode").env.machineId

///|
extern "js" fn env_session_id_ffi() -> String =
  #| () => require("vscode").env.sessionId

///|
extern "js" fn env_is_new_app_install_ffi() -> Bool =
  #| () => require("vscode").env.isNewAppInstall

///|
extern "js" fn env_is_telemetry_enabled_ffi() -> Bool =
  #| () => require("vscode").env.isTelemetryEnabled

///|
extern "js" fn env_on_did_change_telemetry_enabled_ffi() -> Event[Bool] =
  #| () => require("vscode").env.onDidChangeTelemetryEnabled

///|
extern "js" fn env_on_did_change_shell_ffi() -> Event[String] =
  #| () => require("vscode").env.onDidChangeShell

///|
extern "js" fn env_create_telemetry_logger_ffi(
  sender : TelemetrySender,
  options : @v.JsValue,
) -> TelemetryLogger =
  #| (sender, options) => require("vscode").env.createTelemetryLogger(sender, options)

///|
extern "js" fn env_remote_name_ffi() -> @v.JsValue =
  #| () => require("vscode").env.remoteName

///|
extern "js" fn env_shell_ffi() -> String =
  #| () => require("vscode").env.shell

///|
extern "js" fn env_ui_kind_ffi() -> UIKind =
  #| () => require("vscode").env.uiKind

///|
extern "js" fn env_open_external_ffi(target : Uri) -> @js_async.Promise[Bool] =
  #| (target) => require("vscode").env.openExternal(target)

///|
extern "js" fn env_as_external_uri_ffi(target : Uri) -> @js_async.Promise[Uri] =
  #| (target) => require("vscode").env.asExternalUri(target)

///|
extern "js" fn env_log_level_ffi() -> LogLevel =
  #| () => require("vscode").env.logLevel

///|
extern "js" fn env_on_did_change_log_level_ffi() -> Event[LogLevel] =
  #| () => require("vscode").env.onDidChangeLogLevel
