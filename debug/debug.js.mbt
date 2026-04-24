///|
/// VS Code debug namespace bindings for the JS backend.
using @vscode {
  type Breakpoint,
  type BreakpointsChangeEvent,
  type CancellationToken,
  type DebugConfiguration,
  type DebugConsole,
  type DebugSession,
  type DebugSessionCustomEvent,
  type DebugSessionOptions,
  type DebugStackItem,
  type Event,
  type FunctionBreakpoint,
  type Any,
  type SourceBreakpoint,
  type Uri,
  type WorkspaceFolder,
}

///|
/// A DebugProtocolSource is an opaque stand-in type for the [Source](https://microsoft.github.io/debug-adapter-protocol/specification#Types_Source) type defined in the Debug Adapter Protocol.
pub type DebugProtocolSource

///|
/// A debug configuration provider allows to add debug configurations to the debug service
/// and to resolve launch configurations before they are used to start a debug session.
/// A debug configuration provider is registered via {@link debug.registerDebugConfigurationProvider}.
pub type DebugConfigurationProvider

///|
/// Represents a debug adapter executable and optional arguments and runtime options passed to it.
pub type DebugAdapterExecutable

///|
/// A DebugProtocolMessage is an opaque stand-in type for the [ProtocolMessage](https://microsoft.github.io/debug-adapter-protocol/specification#Base_Protocol_ProtocolMessage) type defined in the Debug Adapter Protocol.
pub type DebugProtocolMessage

///|
/// Options for a debug adapter executable.
pub(all) struct DebugAdapterExecutableOptions {
  mut env : Array[(String, String)]?
  mut cwd : String?
}

///|
/// Represents the different types of debug adapters
pub type DebugAdapterDescriptor

///|
/// Represents a debug adapter running as a socket based server.
pub type DebugAdapterServer

///|
/// Represents a debug adapter running as a Named Pipe (on Windows)/UNIX Domain Socket (on non-Windows) based server.
pub type DebugAdapterNamedPipeServer

///|
/// A debug adapter that implements the Debug Adapter Protocol can be registered with the editor if it implements the DebugAdapter interface.
pub struct DebugAdapter {
  on_did_send_message : Event[DebugProtocolMessage]
}

///|
/// A debug adapter descriptor for an inline implementation.
pub type DebugAdapterInlineImplementation

///|
/// A debug adapter factory that creates {@link DebugAdapterDescriptor debug adapter descriptors}.
pub type DebugAdapterDescriptorFactory

///|
/// A Debug Adapter Tracker is a means to track the communication between the editor and a Debug Adapter.
pub type DebugAdapterTracker

///|
/// A debug adapter factory that creates {@link DebugAdapterTracker debug adapter trackers}.
pub type DebugAdapterTrackerFactory

///|
pub(all) enum DebugConfigurationProviderTriggerKind {
  Initial = 1
  Dynamic = 2
} derive(Eq)

///|
fn[T] option_to_js(value : T?) -> @v.JsValue {
  @v.option_to_js(value)
}

///|
fn option_debug_session_options_to_js(
  value : DebugSessionOptions?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => debug_session_options_to_js(value)
  }
}

///|
fn debug_session_options_to_js(value : DebugSessionOptions) -> @v.JsValue {
  debug_session_options_to_js_ffi(
    option_to_js(value.parent_session),
    option_to_js(value.lifecycle_managed_by_parent),
    option_to_js(value.console_mode),
    option_to_js(value.no_debug),
    option_to_js(value.compact),
    option_to_js(value.suppress_save_before_start),
    option_to_js(value.suppress_debug_toolbar),
    option_to_js(value.suppress_debug_statusbar),
    option_to_js(value.suppress_debug_view),
    option_to_js(value.test_run),
  )
}

///|
extern "js" fn debug_session_options_to_js_ffi(
  parent_session : @v.JsValue,
  lifecycle_managed_by_parent : @v.JsValue,
  console_mode : @v.JsValue,
  no_debug : @v.JsValue,
  compact : @v.JsValue,
  suppress_save_before_start : @v.JsValue,
  suppress_debug_toolbar : @v.JsValue,
  suppress_debug_statusbar : @v.JsValue,
  suppress_debug_view : @v.JsValue,
  test_run : @v.JsValue,
) -> @v.JsValue =
  #| (parentSession, lifecycleManagedByParent, consoleMode, noDebug, compact, suppressSaveBeforeStart, suppressDebugToolbar, suppressDebugStatusbar, suppressDebugView, testRun) => {
  #|   const options = {};
  #|   if (parentSession !== undefined && parentSession !== null) options.parentSession = parentSession;
  #|   if (lifecycleManagedByParent !== undefined && lifecycleManagedByParent !== null) {
  #|     options.lifecycleManagedByParent = lifecycleManagedByParent;
  #|   }
  #|   if (consoleMode !== undefined && consoleMode !== null) options.consoleMode = consoleMode;
  #|   if (noDebug !== undefined && noDebug !== null) options.noDebug = noDebug;
  #|   if (compact !== undefined && compact !== null) options.compact = compact;
  #|   if (suppressSaveBeforeStart !== undefined && suppressSaveBeforeStart !== null) {
  #|     options.suppressSaveBeforeStart = suppressSaveBeforeStart;
  #|   }
  #|   if (suppressDebugToolbar !== undefined && suppressDebugToolbar !== null) {
  #|     options.suppressDebugToolbar = suppressDebugToolbar;
  #|   }
  #|   if (suppressDebugStatusbar !== undefined && suppressDebugStatusbar !== null) {
  #|     options.suppressDebugStatusbar = suppressDebugStatusbar;
  #|   }
  #|   if (suppressDebugView !== undefined && suppressDebugView !== null) {
  #|     options.suppressDebugView = suppressDebugView;
  #|   }
  #|   if (testRun !== undefined && testRun !== null) options.testRun = testRun;
  #|   return options;
  #| }

///|
fn map_string_string_pairs(values : Array[(String, String)]?) -> @v.JsValue {
  match values {
    None => @v.JsValue::make(())
    Some(entries) => debug_string_map_ffi(entries)
  }
}

///|
fn debug_adapter_executable_options_from_js(
  raw : @v.JsValue,
) -> DebugAdapterExecutableOptions {
  let env_raw = debug_adapter_executable_options_env_raw(raw)
  let env : Array[(String, String)]? = if env_raw.is_null_or_undefined() {
    None
  } else {
    Some(debug_string_map_to_pairs_ffi(env_raw))
  }
  let cwd : String? = js_to_option(
    debug_adapter_executable_options_cwd_raw(raw),
  )
  DebugAdapterExecutableOptions::{ env, cwd }
}

///|
fn[X] js_to_option(raw : @v.JsValue) -> X? {
  @v.js_to_option(raw)
}

///|
pub fn[T] DebugProtocolSource::from_value(value : T) -> DebugProtocolSource {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] DebugProtocolSource::as_value(value : DebugProtocolSource) -> T {
  @v.JsValue::make(value).cast()
}

///|
pub fn DebugProtocolSource::from_path(path : String) -> DebugProtocolSource {
  debug_protocol_source_from_path_ffi(path)
}

///|
pub fn DebugProtocolMessage::from_json(value : Any) -> DebugProtocolMessage {
  @v.JsValue::make(value).cast()
}

///|
pub fn DebugProtocolMessage::as_json(value : DebugProtocolMessage) -> Any {
  @v.JsValue::make(value).cast()
}

///|
pub fn DebugAdapterExecutableOptions::new(
  env? : Array[(String, String)],
  cwd? : String,
) -> DebugAdapterExecutableOptions {
  debug_adapter_executable_options_ffi(
    map_string_string_pairs(env),
    option_to_js(cwd),
  )
}

///|
/// The additional environment of the executed program or shell. If omitted
/// the parent process' environment is used. If provided it is merged with
/// the parent process' environment.

///|
/// The current working directory for the executed debug adapter.

///|
/// Creates a description for a debug adapter based on an executable program.
///
/// @param command The command or executable path that implements the debug adapter.
/// @param args Optional arguments to be passed to the command or executable.
/// @param options Optional options to be used when starting the command or executable.
pub fn DebugAdapterExecutable::new(
  command : String,
  args? : Array[String],
  options? : DebugAdapterExecutableOptions,
) -> DebugAdapterExecutable {
  debug_adapter_executable_new_ffi(
    command,
    option_to_js(args),
    option_to_js(options),
  )
}

///|
/// The command or path of the debug adapter executable.
/// A command must be either an absolute path of an executable or the name of an command to be looked up via the PATH environment variable.
/// The special value 'node' will be mapped to the editor's built-in Node.js runtime.
pub extern "js" fn DebugAdapterExecutable::command(
  self : DebugAdapterExecutable,
) -> String =
  #| (value) => value.command

///|
/// The arguments passed to the debug adapter executable. Defaults to an empty array.
pub extern "js" fn DebugAdapterExecutable::args(
  self : DebugAdapterExecutable,
) -> Array[String] =
  #| (value) => value.args

///|
/// Optional options to be used when the debug adapter is started.
/// Defaults to undefined.
pub fn DebugAdapterExecutable::options(
  self : DebugAdapterExecutable,
) -> DebugAdapterExecutableOptions? {
  let raw = debug_adapter_executable_options_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(debug_adapter_executable_options_from_js(raw))
  }
}

///|
/// Create a description for a debug adapter running as a socket based server.
pub fn DebugAdapterServer::new(
  port : Int,
  host? : String,
) -> DebugAdapterServer {
  debug_adapter_server_new_ffi(port, option_to_js(host))
}

///|
/// The port.
pub extern "js" fn DebugAdapterServer::port(self : DebugAdapterServer) -> Int =
  #| (value) => value.port

///|
/// The host.
pub fn DebugAdapterServer::host(self : DebugAdapterServer) -> String? {
  let raw = debug_adapter_server_host_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Create a description for a debug adapter running as a Named Pipe (on Windows)/UNIX Domain Socket (on non-Windows) based server.
pub extern "js" fn DebugAdapterNamedPipeServer::new(
  path : String,
) -> DebugAdapterNamedPipeServer =
  #| (path) => new (require("vscode").DebugAdapterNamedPipeServer)(path)

///|
/// The path to the NamedPipe/UNIX Domain Socket.
pub extern "js" fn DebugAdapterNamedPipeServer::path(
  self : DebugAdapterNamedPipeServer,
) -> String =
  #| (value) => value.path

///|
pub fn DebugAdapter::new(
  on_did_send_message : Event[DebugProtocolMessage],
  handle_message : (DebugProtocolMessage) -> Unit,
  dispose? : () -> Unit,
) -> DebugAdapter {
  debug_adapter_ffi(on_did_send_message, handle_message, option_to_js(dispose))
}

///|
/// An event which fires after the debug adapter has sent a Debug Adapter Protocol message to the editor.
/// Messages can be requests, responses, or events.

///|
/// Handle a Debug Adapter Protocol message.
/// Messages can be requests, responses, or events.
/// Results or errors are returned via onSendMessage events.
/// @param message A Debug Adapter Protocol message
pub extern "js" fn DebugAdapter::handle_message(
  self : DebugAdapter,
  message : DebugProtocolMessage,
) -> Unit =
  #| (adapter, message) => adapter.handleMessage(message)

///|
extern "js" fn debug_adapter_dispose_raw(adapter : DebugAdapter) -> Unit =
  #| (adapter) => adapter.dispose()

///|
pub fn DebugAdapter::dispose(self : DebugAdapter) -> Unit {
  debug_adapter_dispose_raw(self)
}

///|
pub impl @vscode.AsDisposable for DebugAdapter with as_disposable(self) {
  @v.JsValue::make(self).cast()
}

///|
/// Create a descriptor for an inline implementation of a debug adapter.
pub extern "js" fn DebugAdapterInlineImplementation::new(
  implementation : DebugAdapter,
) -> DebugAdapterInlineImplementation =
  #| (implementation) =>
  #|   new (require("vscode").DebugAdapterInlineImplementation)(implementation)

///|
pub fn DebugAdapterDescriptor::from_executable(
  value : DebugAdapterExecutable,
) -> DebugAdapterDescriptor {
  @v.JsValue::make(value).cast()
}

///|
pub fn DebugAdapterDescriptor::from_server(
  value : DebugAdapterServer,
) -> DebugAdapterDescriptor {
  @v.JsValue::make(value).cast()
}

///|
pub fn DebugAdapterDescriptor::from_named_pipe_server(
  value : DebugAdapterNamedPipeServer,
) -> DebugAdapterDescriptor {
  @v.JsValue::make(value).cast()
}

///|
pub fn DebugAdapterDescriptor::from_inline_implementation(
  value : DebugAdapterInlineImplementation,
) -> DebugAdapterDescriptor {
  @v.JsValue::make(value).cast()
}

///|
pub fn DebugConfigurationProvider::new(
  provide_debug_configurations? : async (WorkspaceFolder?, CancellationToken?) -> Array[
    DebugConfiguration,
  ]?,
  resolve_debug_configuration? : async (
    WorkspaceFolder?,
    DebugConfiguration,
    CancellationToken?,
  ) -> DebugConfiguration?,
  resolve_debug_configuration_with_substituted_variables? : async (
    WorkspaceFolder?,
    DebugConfiguration,
    CancellationToken?,
  ) -> DebugConfiguration?,
) -> DebugConfigurationProvider {
  let provide_callback : ((@v.JsValue, @v.JsValue) -> @js_async.Promise[
    @v.JsValue,
  ])? = match provide_debug_configurations {
    None => None
    Some(value) =>
      Some((folder_raw, token_raw) => {
        @js_async.Promise::from_async(async fn() {
          option_to_js(value(js_to_option(folder_raw), js_to_option(token_raw)))
        })
      })
  }
  let resolve_callback : ((@v.JsValue, DebugConfiguration, @v.JsValue) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_debug_configuration {
    None => None
    Some(value) =>
      Some((folder_raw, configuration, token_raw) => {
        @js_async.Promise::from_async(async fn() {
          option_to_js(
            value(
              js_to_option(folder_raw),
              configuration,
              js_to_option(token_raw),
            ),
          )
        })
      })
  }
  let resolve_with_substituted_callback : ((
    @v.JsValue,
    DebugConfiguration,
    @v.JsValue,
  ) -> @js_async.Promise[@v.JsValue])? = match
    resolve_debug_configuration_with_substituted_variables {
    None => None
    Some(value) =>
      Some((folder_raw, configuration, token_raw) => {
        @js_async.Promise::from_async(async fn() {
          option_to_js(
            value(
              js_to_option(folder_raw),
              configuration,
              js_to_option(token_raw),
            ),
          )
        })
      })
  }
  debug_configuration_provider_ffi(
    option_to_js(provide_callback),
    option_to_js(resolve_callback),
    option_to_js(resolve_with_substituted_callback),
  )
}

///|
pub fn DebugAdapterDescriptorFactory::new(
  create_debug_adapter_descriptor : async (
    DebugSession,
    DebugAdapterExecutable?,
  ) -> DebugAdapterDescriptor?,
) -> DebugAdapterDescriptorFactory {
  debug_adapter_descriptor_factory_ffi((session, executable_raw) => {
    @js_async.Promise::from_async(async fn() {
      option_to_js(
        create_debug_adapter_descriptor(session, js_to_option(executable_raw)),
      )
    })
  })
}

///|
pub fn DebugAdapterTracker::new(
  on_will_start_session? : () -> Unit,
  on_will_receive_message? : (String) -> Unit,
  on_did_send_message? : (String) -> Unit,
  on_will_stop_session? : () -> Unit,
  on_error? : (String) -> Unit,
  on_exit? : (Int?, String?) -> Unit,
) -> DebugAdapterTracker {
  let exit_callback : ((@v.JsValue, @v.JsValue) -> Unit)? = match on_exit {
    None => None
    Some(value) =>
      Some((code_raw, signal_raw) => {
        value(js_to_option(code_raw), js_to_option(signal_raw))
      })
  }
  debug_adapter_tracker_ffi(
    option_to_js(on_will_start_session),
    option_to_js(on_will_receive_message),
    option_to_js(on_did_send_message),
    option_to_js(on_will_stop_session),
    option_to_js(on_error),
    option_to_js(exit_callback),
  )
}

///|
pub fn DebugAdapterTrackerFactory::new(
  create_debug_adapter_tracker : async (DebugSession) -> DebugAdapterTracker?,
) -> DebugAdapterTrackerFactory {
  debug_adapter_tracker_factory_ffi(session => {
    @js_async.Promise::from_async(async fn() {
      option_to_js(create_debug_adapter_tracker(session))
    })
  })
}

///|
/// List of breakpoints.
pub fn breakpoints() -> Array[Breakpoint] {
  debug_breakpoints_ffi()
}

///|
/// The currently active {@link DebugSession debug session} or `undefined`. The active debug session is the one
/// represented by the debug action floating window or the one currently shown in the drop down menu of the debug action floating window.
/// If no debug session is active, the value is `undefined`.
pub fn active_debug_session() -> DebugSession? {
  let raw = debug_active_debug_session_ffi()
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The currently active {@link DebugConsole debug console}.
/// If no debug session is active, output sent to the debug console is not shown.
pub fn active_debug_console() -> DebugConsole {
  debug_active_debug_console_ffi()
}

///|
/// The currently focused thread or stack frame, or `undefined` if no
/// thread or stack is focused. A thread can be focused any time there is
/// an active debug session, while a stack frame can only be focused when
/// a session is paused and the call stack has been retrieved.
pub fn active_stack_item() -> DebugStackItem? {
  let raw = debug_active_stack_item_ffi()
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An {@link Event} which fires when the {@link debug.activeDebugSession active debug session}
/// has changed. *Note* that the event also fires when the active debug session changes
/// to `undefined`.
pub fn on_did_change_active_debug_session() -> Event[DebugSession?] {
  debug_on_did_change_active_debug_session_ffi()
}

///|
/// An {@link Event} which fires when a new {@link DebugSession debug session} has been started.
pub fn on_did_start_debug_session() -> Event[DebugSession] {
  debug_on_did_start_debug_session_ffi()
}

///|
/// An {@link Event} which fires when a custom DAP event is received from the {@link DebugSession debug session}.
pub fn on_did_receive_debug_session_custom_event() -> Event[
  DebugSessionCustomEvent,
] {
  debug_on_did_receive_debug_session_custom_event_ffi()
}

///|
/// An {@link Event} which fires when a {@link DebugSession debug session} has terminated.
pub fn on_did_terminate_debug_session() -> Event[DebugSession] {
  debug_on_did_terminate_debug_session_ffi()
}

///|
/// An {@link Event} that is emitted when the set of breakpoints is added, removed, or changed.
pub fn on_did_change_breakpoints() -> Event[BreakpointsChangeEvent] {
  debug_on_did_change_breakpoints_ffi()
}

///|
/// An event which fires when the {@link debug.activeStackItem} has changed.
pub fn on_did_change_active_stack_item() -> Event[DebugStackItem?] {
  debug_on_did_change_active_stack_item_ffi()
}

///|
/// Register a {@link DebugConfigurationProvider debug configuration provider} for a specific debug type.
/// The optional {@link DebugConfigurationProviderTriggerKind triggerKind} can be used to specify when the `provideDebugConfigurations` method of the provider is triggered.
/// Currently two trigger kinds are possible: with the value `Initial` (or if no trigger kind argument is given) the `provideDebugConfigurations` method is used to provide the initial debug configurations to be copied into a newly created launch.json.
/// With the trigger kind `Dynamic` the `provideDebugConfigurations` method is used to dynamically determine debug configurations to be presented to the user (in addition to the static configurations from the launch.json).
/// Please note that the `triggerKind` argument only applies to the `provideDebugConfigurations` method: so the `resolveDebugConfiguration` methods are not affected at all.
/// Registering a single provider with resolve methods for different trigger kinds, results in the same resolve methods called multiple times.
/// More than one provider can be registered for the same type.
///
/// @param debugType The debug type for which the provider is registered.
/// @param provider The {@link DebugConfigurationProvider debug configuration provider} to register.
/// @param triggerKind The {@link DebugConfigurationProviderTriggerKind trigger} for which the 'provideDebugConfiguration' method of the provider is registered. If `triggerKind` is missing, the value `DebugConfigurationProviderTriggerKind.Initial` is assumed.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn register_debug_configuration_provider(
  debug_type : String,
  provider : DebugConfigurationProvider,
  trigger_kind? : DebugConfigurationProviderTriggerKind,
) -> @vscode.Disposable {
  debug_register_debug_configuration_provider_ffi(
    debug_type,
    provider,
    option_to_js(trigger_kind),
  )
}

///|
/// Register a {@link DebugAdapterDescriptorFactory debug adapter descriptor factory} for a specific debug type.
/// An extension is only allowed to register a DebugAdapterDescriptorFactory for the debug type(s) defined by the extension. Otherwise an error is thrown.
/// Registering more than one DebugAdapterDescriptorFactory for a debug type results in an error.
///
/// @param debugType The debug type for which the factory is registered.
/// @param factory The {@link DebugAdapterDescriptorFactory debug adapter descriptor factory} to register.
/// @returns A {@link Disposable} that unregisters this factory when being disposed.
pub fn register_debug_adapter_descriptor_factory(
  debug_type : String,
  factory : DebugAdapterDescriptorFactory,
) -> @vscode.Disposable {
  debug_register_debug_adapter_descriptor_factory_ffi(debug_type, factory)
}

///|
/// Register a debug adapter tracker factory for the given debug type.
///
/// @param debugType The debug type for which the factory is registered or '*' for matching all debug types.
/// @param factory The {@link DebugAdapterTrackerFactory debug adapter tracker factory} to register.
/// @returns A {@link Disposable} that unregisters this factory when being disposed.
pub fn register_debug_adapter_tracker_factory(
  debug_type : String,
  factory : DebugAdapterTrackerFactory,
) -> @vscode.Disposable {
  debug_register_debug_adapter_tracker_factory_ffi(debug_type, factory)
}

///|
/// Converts a "Source" descriptor object received via the Debug Adapter Protocol into a Uri that can be used to load its contents.
/// If the source descriptor is based on a path, a file Uri is returned.
/// If the source descriptor uses a reference number, a specific debug Uri (scheme 'debug') is constructed that requires a corresponding ContentProvider and a running debug session
///
/// If the "Source" descriptor has insufficient information for creating the Uri, an error is thrown.
///
/// @param source An object conforming to the [Source](https://microsoft.github.io/debug-adapter-protocol/specification#Types_Source) type defined in the Debug Adapter Protocol.
/// @param session An optional debug session that will be used when the source descriptor uses a reference number to load the contents from an active debug session.
/// @returns A uri that can be used to load the contents of the source.
pub fn as_debug_source_uri(
  source : DebugProtocolSource,
  session? : DebugSession,
) -> Uri {
  debug_as_debug_source_uri_ffi(source, option_to_js(session))
}

///|
/// Add breakpoints.
/// @param breakpoints The breakpoints to add.
pub fn add_breakpoints(breakpoints : Array[Breakpoint]) -> Unit {
  debug_add_breakpoints_ffi(breakpoints)
}

///|
/// Remove breakpoints.
/// @param breakpoints The breakpoints to remove.
pub fn remove_breakpoints(breakpoints : Array[Breakpoint]) -> Unit {
  debug_remove_breakpoints_ffi(breakpoints)
}

///|
pub fn add_source_breakpoints(breakpoints : Array[SourceBreakpoint]) -> Unit {
  debug_add_source_breakpoints_ffi(breakpoints)
}

///|
pub fn remove_source_breakpoints(breakpoints : Array[SourceBreakpoint]) -> Unit {
  debug_remove_source_breakpoints_ffi(breakpoints)
}

///|
pub fn add_function_breakpoints(
  breakpoints : Array[FunctionBreakpoint],
) -> Unit {
  debug_add_function_breakpoints_ffi(breakpoints)
}

///|
pub fn remove_function_breakpoints(
  breakpoints : Array[FunctionBreakpoint],
) -> Unit {
  debug_remove_function_breakpoints_ffi(breakpoints)
}

///|
/// Start debugging by using either a named launch or named compound configuration,
/// or by directly passing a {@link DebugConfiguration}.
/// The named configurations are looked up in '.vscode/launch.json' found in the given folder.
/// Before debugging starts, all unsaved files are saved and the launch configurations are brought up-to-date.
/// Folder specific variables used in the configuration (e.g. '${workspaceFolder}') are resolved against the given folder.
/// @param folder The {@link WorkspaceFolder workspace folder} for looking up named configurations and resolving variables or `undefined` for a non-folder setup.
/// @param nameOrConfiguration Either the name of a debug or compound configuration or a {@link DebugConfiguration} object.
/// @param parentSessionOrOptions Debug session options. When passed a parent {@link DebugSession debug session}, assumes options with just this parent session.
/// @returns A thenable that resolves when debugging could be successfully started.
pub async fn start_debugging_name(
  folder? : WorkspaceFolder,
  name : String,
  parent_session? : DebugSession,
) -> Bool {
  @js_async.Promise::wait(
    debug_start_debugging_name_ffi(
      option_to_js(folder),
      name,
      option_to_js(parent_session),
    ),
  )
}

///|
/// Start debugging by using either a named launch or named compound configuration,
/// or by directly passing a {@link DebugConfiguration}.
/// The named configurations are looked up in '.vscode/launch.json' found in the given folder.
/// Before debugging starts, all unsaved files are saved and the launch configurations are brought up-to-date.
/// Folder specific variables used in the configuration (e.g. '${workspaceFolder}') are resolved against the given folder.
/// @param folder The {@link WorkspaceFolder workspace folder} for looking up named configurations and resolving variables or `undefined` for a non-folder setup.
/// @param nameOrConfiguration Either the name of a debug or compound configuration or a {@link DebugConfiguration} object.
/// @param parentSessionOrOptions Debug session options. When passed a parent {@link DebugSession debug session}, assumes options with just this parent session.
/// @returns A thenable that resolves when debugging could be successfully started.
pub async fn start_debugging_name_with_options(
  folder? : WorkspaceFolder,
  name : String,
  options? : DebugSessionOptions,
) -> Bool {
  @js_async.Promise::wait(
    debug_start_debugging_name_with_options_ffi(
      option_to_js(folder),
      name,
      option_debug_session_options_to_js(options),
    ),
  )
}

///|
/// Start debugging by using either a named launch or named compound configuration,
/// or by directly passing a {@link DebugConfiguration}.
/// The named configurations are looked up in '.vscode/launch.json' found in the given folder.
/// Before debugging starts, all unsaved files are saved and the launch configurations are brought up-to-date.
/// Folder specific variables used in the configuration (e.g. '${workspaceFolder}') are resolved against the given folder.
/// @param folder The {@link WorkspaceFolder workspace folder} for looking up named configurations and resolving variables or `undefined` for a non-folder setup.
/// @param nameOrConfiguration Either the name of a debug or compound configuration or a {@link DebugConfiguration} object.
/// @param parentSessionOrOptions Debug session options. When passed a parent {@link DebugSession debug session}, assumes options with just this parent session.
/// @returns A thenable that resolves when debugging could be successfully started.
pub async fn start_debugging_configuration(
  folder? : WorkspaceFolder,
  configuration : DebugConfiguration,
  parent_session? : DebugSession,
) -> Bool {
  @js_async.Promise::wait(
    debug_start_debugging_configuration_ffi(
      option_to_js(folder),
      configuration,
      option_to_js(parent_session),
    ),
  )
}

///|
/// Start debugging by using either a named launch or named compound configuration,
/// or by directly passing a {@link DebugConfiguration}.
/// The named configurations are looked up in '.vscode/launch.json' found in the given folder.
/// Before debugging starts, all unsaved files are saved and the launch configurations are brought up-to-date.
/// Folder specific variables used in the configuration (e.g. '${workspaceFolder}') are resolved against the given folder.
/// @param folder The {@link WorkspaceFolder workspace folder} for looking up named configurations and resolving variables or `undefined` for a non-folder setup.
/// @param nameOrConfiguration Either the name of a debug or compound configuration or a {@link DebugConfiguration} object.
/// @param parentSessionOrOptions Debug session options. When passed a parent {@link DebugSession debug session}, assumes options with just this parent session.
/// @returns A thenable that resolves when debugging could be successfully started.
pub async fn start_debugging_configuration_with_options(
  folder? : WorkspaceFolder,
  configuration : DebugConfiguration,
  options? : DebugSessionOptions,
) -> Bool {
  @js_async.Promise::wait(
    debug_start_debugging_configuration_with_options_ffi(
      option_to_js(folder),
      configuration,
      option_debug_session_options_to_js(options),
    ),
  )
}

///|
/// Stop the given debug session or stop all debug sessions if session is omitted.
///
/// @param session The {@link DebugSession debug session} to stop; if omitted all sessions are stopped.
/// @returns A thenable that resolves when the session(s) have been stopped.
pub async fn stop_debugging(session? : DebugSession) -> Unit {
  @js_async.Promise::wait(debug_stop_debugging_ffi(option_to_js(session)))
}
