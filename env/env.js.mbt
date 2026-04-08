///|
/// VS Code env namespace bindings for the JS backend.
using @vscode {
  type Clipboard,
  type Event,
  type Any,
  type LogLevel,
  type TelemetryLogger,
  type TelemetryLoggerOptions,
  type TelemetrySender,
  type UIKind,
  type Uri,
}

///|
fn option_telemetry_logger_options_to_js(
  value : TelemetryLoggerOptions?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => telemetry_logger_options_to_js(value)
  }
}

///|
fn telemetry_logger_options_to_js(value : TelemetryLoggerOptions) -> @v.JsValue {
  env_telemetry_logger_options_to_js_ffi(
    @v.option_to_js(value.ignore_built_in_common_properties),
    @v.option_to_js(value.ignore_unhandled_errors),
    map_string_json_pairs(value.additional_common_properties),
  )
}

///|
fn map_string_json_pairs(values : Array[(String, Any)]?) -> @v.JsValue {
  match values {
    None => @v.JsValue::make(())
    Some(entries) => env_string_json_map_ffi(entries)
  }
}

///|
extern "js" fn env_telemetry_logger_options_to_js_ffi(
  ignore_built_in_common_properties : @v.JsValue,
  ignore_unhandled_errors : @v.JsValue,
  additional_common_properties : @v.JsValue,
) -> @v.JsValue =
  #| (ignoreBuiltInCommonProperties, ignoreUnhandledErrors, additionalCommonProperties) => {
  #|   const options = {};
  #|   if (ignoreBuiltInCommonProperties !== undefined && ignoreBuiltInCommonProperties !== null) {
  #|     options.ignoreBuiltInCommonProperties = ignoreBuiltInCommonProperties;
  #|   }
  #|   if (ignoreUnhandledErrors !== undefined && ignoreUnhandledErrors !== null) {
  #|     options.ignoreUnhandledErrors = ignoreUnhandledErrors;
  #|   }
  #|   if (additionalCommonProperties !== undefined && additionalCommonProperties !== null) {
  #|     options.additionalCommonProperties = additionalCommonProperties;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn env_string_json_map_ffi(
  entries : Array[(String, Any)],
) -> @v.JsValue =
  #| (pairs) => {
  #|   const result = {};
  #|   for (const pair of pairs) {
  #|     const key = pair._0 ?? pair[0];
  #|     const value = pair._1 ?? pair[1];
  #|     result[key] = value;
  #|   }
  #|   return result;
  #| }

///|
/// The application name of the editor, like 'VS Code'.
pub fn app_name() -> String {
  env_app_name_ffi()
}

///|
/// The application root folder from which the editor is running.
///
/// *Note* that the value is the empty string when running in an
/// environment that has no representation of an application root folder.
pub fn app_root() -> String {
  env_app_root_ffi()
}

///|
/// The hosted location of the application
/// On desktop this is 'desktop'
/// In the web this is the specified embedder i.e. 'github.dev', 'codespaces', or 'web' if the embedder
/// does not provide that information
pub fn app_host() -> String {
  env_app_host_ffi()
}

///|
/// The custom uri scheme the editor registers to in the operating system.
pub fn uri_scheme() -> String {
  env_uri_scheme_ffi()
}

///|
/// Represents the preferred user-language, like `de-CH`, `fr`, or `en-US`.
pub fn language() -> String {
  env_language_ffi()
}

///|
/// The system clipboard.
pub fn clipboard() -> Clipboard {
  env_clipboard_ffi()
}

///|
/// A unique identifier for the computer.
pub fn machine_id() -> String {
  env_machine_id_ffi()
}

///|
/// A unique identifier for the current session.
/// Changes each time the editor is started.
pub fn session_id() -> String {
  env_session_id_ffi()
}

///|
/// Indicates that this is a fresh install of the application.
/// `true` if within the first day of installation otherwise `false`.
pub fn is_new_app_install() -> Bool {
  env_is_new_app_install_ffi()
}

///|
/// Indicates whether the users has telemetry enabled.
/// Can be observed to determine if the extension should send telemetry.
pub fn is_telemetry_enabled() -> Bool {
  env_is_telemetry_enabled_ffi()
}

///|
/// An {@link Event} which fires when the user enabled or disables telemetry.
/// `true` if the user has enabled telemetry or `false` if the user has disabled telemetry.
pub fn on_did_change_telemetry_enabled() -> Event[Bool] {
  env_on_did_change_telemetry_enabled_ffi()
}

///|
/// An {@link Event} which fires when the default shell changes. This fires with the new
/// shell path.
pub fn on_did_change_shell() -> Event[String] {
  env_on_did_change_shell_ffi()
}

///|
/// Creates a new {@link TelemetryLogger telemetry logger}.
///
/// @param sender The telemetry sender that is used by the telemetry logger.
/// @param options Options for the telemetry logger.
/// @returns A new telemetry logger
pub fn create_telemetry_logger(
  sender : TelemetrySender,
  options? : TelemetryLoggerOptions,
) -> TelemetryLogger {
  env_create_telemetry_logger_ffi(
    sender,
    option_telemetry_logger_options_to_js(options),
  )
}

///|
/// The name of a remote. Defined by extensions, popular samples are `wsl` for the Windows
/// Subsystem for Linux or `ssh-remote` for remotes using a secure shell.
///
/// *Note* that the value is `undefined` when there is no remote extension host but that the
/// value is defined in all extension hosts (local and remote) in case a remote extension host
/// exists. Use {@link Extension.extensionKind} to know if
/// a specific extension runs remote or not.
pub fn remote_name() -> String? {
  let value = env_remote_name_ffi()
  if value.is_null_or_undefined() {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// The detected default shell for the extension host, this is overridden by the
/// `terminal.integrated.defaultProfile` setting for the extension host's platform. Note that in
/// environments that do not support a shell the value is the empty string.
pub fn shell() -> String {
  env_shell_ffi()
}

///|
/// The UI kind property indicates from which UI extensions
/// are accessed from. For example, extensions could be accessed
/// from a desktop application or a web browser.
pub fn ui_kind() -> UIKind {
  env_ui_kind_ffi()
}

///|
/// Opens a link externally using the default application. Depending on the
/// used scheme this can be:
/// * a browser (`http:`, `https:`)
/// * a mail client (`mailto:`)
/// * VSCode itself (`vscode:` from `vscode.env.uriScheme`)
///
/// *Note* that {@linkcode window.showTextDocument showTextDocument} is the right
/// way to open a text document inside the editor, not this function.
///
/// @param target The uri that should be opened.
/// @returns A promise indicating if open was successful.
pub async fn open_external(target : Uri) -> Bool {
  @js_async.Promise::wait(env_open_external_ffi(target))
}

///|
/// Resolves a uri to a form that is accessible externally.
///
/// #### `http:` or `https:` scheme
///
/// Resolves an *external* uri, such as a `http:` or `https:` link, from where the extension is running to a
/// uri to the same resource on the client machine.
///
/// This is a no-op if the extension is running on the client machine.
///
/// If the extension is running remotely, this function automatically establishes a port forwarding tunnel
/// from the local machine to `target` on the remote and returns a local uri to the tunnel. The lifetime of
/// the port forwarding tunnel is managed by the editor and the tunnel can be closed by the user.
///
/// *Note* that uris passed through `openExternal` are automatically resolved and you should not call `asExternalUri` on them.
///
/// #### `vscode.env.uriScheme`
///
/// Creates a uri that - if opened in a browser (e.g. via `openExternal`) - will result in a registered {@link UriHandler}
/// to trigger.
///
/// Extensions should not make any assumptions about the resulting uri and should not alter it in any way.
/// Rather, extensions can e.g. use this uri in an authentication flow, by adding the uri as callback query
/// argument to the server to authenticate to.
///
/// *Note* that if the server decides to add additional query parameters to the uri (e.g. a token or secret), it
/// will appear in the uri that is passed to the {@link UriHandler}.
///
/// **Example** of an authentication flow:
/// ```typescript
/// vscode.window.registerUriHandler({
///   handleUri(uri: vscode.Uri): vscode.ProviderResult<void> {
///     if (uri.path === '/did-authenticate') {
///       console.log(uri.toString());
///     }
///   }
/// });
///
/// const callableUri = await vscode.env.asExternalUri(vscode.Uri.parse(vscode.env.uriScheme + '://my.extension/did-authenticate'));
/// await vscode.env.openExternal(callableUri);
/// ```
///
/// *Note* that extensions should not cache the result of `asExternalUri` as the resolved uri may become invalid due to
/// a system or user action — for example, in remote cases, a user may close a port forwarding tunnel that was opened by
/// `asExternalUri`.
///
/// #### Any other scheme
///
/// Any other scheme will be handled as if the provided URI is a workspace URI. In that case, the method will return
/// a URI which, when handled, will make the editor open the workspace.
///
/// @returns A uri that can be used on the client machine.
pub async fn as_external_uri(target : Uri) -> Uri {
  @js_async.Promise::wait(env_as_external_uri_ffi(target))
}

///|
/// The current log level of the editor.
pub fn log_level() -> LogLevel {
  env_log_level_ffi()
}

///|
/// An {@link Event} which fires when the log level of the editor changes.
pub fn on_did_change_log_level() -> Event[LogLevel] {
  env_on_did_change_log_level_ffi()
}
