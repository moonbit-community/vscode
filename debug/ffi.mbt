///|
/// JS FFI bindings for VS Code debug namespace.

///|
extern "js" fn debug_protocol_source_from_path_ffi(
  path : String,
) -> DebugProtocolSource =
  #| (path) => ({ path })

///|
extern "js" fn debug_adapter_executable_options_ffi(
  env : @v.JsValue,
  cwd : @v.JsValue,
) -> DebugAdapterExecutableOptions =
  #| (env, cwd) => {
  #|   const options = {};
  #|   if (env !== undefined && env !== null) options.env = env;
  #|   if (cwd !== undefined && cwd !== null) options.cwd = cwd;
  #|   return options;
  #| }

///|
extern "js" fn debug_adapter_executable_new_ffi(
  command : String,
  args : @v.JsValue,
  options : @v.JsValue,
) -> DebugAdapterExecutable =
  #| (command, args, options) =>
  #|   new (require("vscode").DebugAdapterExecutable)(
  #|     command,
  #|     args === undefined || args === null ? undefined : args,
  #|     options === undefined || options === null ? undefined : options
  #|   )

///|
extern "js" fn debug_adapter_executable_options_raw(
  value : DebugAdapterExecutable,
) -> @v.JsValue =
  #| (value) => value.options

///|
extern "js" fn debug_adapter_executable_options_env_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value.env

///|
extern "js" fn debug_adapter_executable_options_cwd_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value.cwd

///|
extern "js" fn debug_adapter_server_new_ffi(
  port : Int,
  host : @v.JsValue,
) -> DebugAdapterServer =
  #| (port, host) =>
  #|   new (require("vscode").DebugAdapterServer)(
  #|     port,
  #|     host === undefined || host === null ? undefined : host
  #|   )

///|
extern "js" fn debug_adapter_server_host_raw(
  value : DebugAdapterServer,
) -> @v.JsValue =
  #| (value) => value.host

///|
extern "js" fn debug_adapter_ffi(
  on_did_send_message : Event[DebugProtocolMessage],
  handle_message : (DebugProtocolMessage) -> Unit,
  dispose : @v.JsValue,
) -> DebugAdapter =
  #| (onDidSendMessage, handleMessage, dispose) => {
  #|   const adapter = { onDidSendMessage, handleMessage };
  #|   if (dispose !== undefined && dispose !== null) {
  #|     adapter.dispose = dispose;
  #|   } else {
  #|     adapter.dispose = () => {};
  #|   }
  #|   return adapter;
  #| }

///|
extern "js" fn debug_string_map_ffi(
  entries : Array[(String, String)],
) -> @v.JsValue =
  #| (entries) => {
  #|   const value = {};
  #|   for (const entry of entries) {
  #|     const k = entry._0 ?? entry[0];
  #|     const v = entry._1 ?? entry[1];
  #|     value[k] = v;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn debug_string_map_to_pairs_ffi(
  value : @v.JsValue,
) -> Array[(String, String)] =
  #| (value) => {
  #|   if (value === undefined || value === null) {
  #|     return [];
  #|   }
  #|   return Object.entries(value);
  #| }

///|
extern "js" fn debug_configuration_provider_ffi(
  provide : @v.JsValue,
  resolve : @v.JsValue,
  resolve_with_substituted : @v.JsValue,
) -> DebugConfigurationProvider =
  #| (provide, resolve, resolveWithSubstituted) => {
  #|   const provider = {};
  #|   if (provide !== undefined && provide !== null) {
  #|     provider.provideDebugConfigurations = (folder, token) => provide(folder, token);
  #|   }
  #|   if (resolve !== undefined && resolve !== null) {
  #|     provider.resolveDebugConfiguration = (folder, configuration, token) =>
  #|       resolve(folder, configuration, token);
  #|   }
  #|   if (resolveWithSubstituted !== undefined && resolveWithSubstituted !== null) {
  #|     provider.resolveDebugConfigurationWithSubstitutedVariables =
  #|       (folder, configuration, token) =>
  #|         resolveWithSubstituted(folder, configuration, token);
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn debug_adapter_descriptor_factory_ffi(
  create_descriptor : (DebugSession, @v.JsValue) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> DebugAdapterDescriptorFactory =
  #| (createDebugAdapterDescriptor) => ({ createDebugAdapterDescriptor })

///|
extern "js" fn debug_adapter_tracker_ffi(
  on_will_start_session : @v.JsValue,
  on_will_receive_message : @v.JsValue,
  on_did_send_message : @v.JsValue,
  on_will_stop_session : @v.JsValue,
  on_error : @v.JsValue,
  on_exit : @v.JsValue,
) -> DebugAdapterTracker =
  #| (
  #|   onWillStartSession,
  #|   onWillReceiveMessage,
  #|   onDidSendMessage,
  #|   onWillStopSession,
  #|   onError,
  #|   onExit,
  #| ) => {
  #|   const tracker = {};
  #|   if (onWillStartSession !== undefined && onWillStartSession !== null) {
  #|     tracker.onWillStartSession = onWillStartSession;
  #|   }
  #|   if (onWillReceiveMessage !== undefined && onWillReceiveMessage !== null) {
  #|     tracker.onWillReceiveMessage = (message) => onWillReceiveMessage(String(message));
  #|   }
  #|   if (onDidSendMessage !== undefined && onDidSendMessage !== null) {
  #|     tracker.onDidSendMessage = (message) => onDidSendMessage(String(message));
  #|   }
  #|   if (onWillStopSession !== undefined && onWillStopSession !== null) {
  #|     tracker.onWillStopSession = onWillStopSession;
  #|   }
  #|   if (onError !== undefined && onError !== null) {
  #|     tracker.onError = (error) => onError(String(error));
  #|   }
  #|   if (onExit !== undefined && onExit !== null) {
  #|     tracker.onExit = (code, signal) => onExit(code, signal);
  #|   }
  #|   return tracker;
  #| }

///|
extern "js" fn debug_adapter_tracker_factory_ffi(
  create_tracker : (DebugSession) -> @js_async.Promise[@v.JsValue],
) -> DebugAdapterTrackerFactory =
  #| (createDebugAdapterTracker) => ({ createDebugAdapterTracker })

///|
extern "js" fn debug_breakpoints_ffi() -> Array[Breakpoint] =
  #| () => require("vscode").debug.breakpoints

///|
extern "js" fn debug_active_debug_session_ffi() -> @v.JsValue =
  #| () => require("vscode").debug.activeDebugSession

///|
extern "js" fn debug_active_debug_console_ffi() -> DebugConsole =
  #| () => require("vscode").debug.activeDebugConsole

///|
extern "js" fn debug_active_stack_item_ffi() -> @v.JsValue =
  #| () => require("vscode").debug.activeStackItem

///|
extern "js" fn debug_on_did_change_active_debug_session_ffi() -> Event[
  DebugSession?,
] =
  #| () => require("vscode").debug.onDidChangeActiveDebugSession

///|
extern "js" fn debug_on_did_start_debug_session_ffi() -> Event[DebugSession] =
  #| () => require("vscode").debug.onDidStartDebugSession

///|
extern "js" fn debug_on_did_receive_debug_session_custom_event_ffi() -> Event[
  DebugSessionCustomEvent,
] =
  #| () => require("vscode").debug.onDidReceiveDebugSessionCustomEvent

///|
extern "js" fn debug_on_did_terminate_debug_session_ffi() -> Event[DebugSession] =
  #| () => require("vscode").debug.onDidTerminateDebugSession

///|
extern "js" fn debug_on_did_change_breakpoints_ffi() -> Event[
  BreakpointsChangeEvent,
] =
  #| () => require("vscode").debug.onDidChangeBreakpoints

///|
extern "js" fn debug_on_did_change_active_stack_item_ffi() -> Event[
  DebugStackItem?,
] =
  #| () => require("vscode").debug.onDidChangeActiveStackItem

///|
extern "js" fn debug_register_debug_configuration_provider_ffi(
  debug_type : String,
  provider : DebugConfigurationProvider,
  trigger_kind : @v.JsValue,
) -> @vscode.Disposable =
  #| (debugType, provider, triggerKind) =>
  #|   require("vscode").debug.registerDebugConfigurationProvider(
  #|     debugType,
  #|     provider,
  #|     triggerKind === undefined || triggerKind === null ? undefined : triggerKind
  #|   )

///|
extern "js" fn debug_register_debug_adapter_descriptor_factory_ffi(
  debug_type : String,
  factory : DebugAdapterDescriptorFactory,
) -> @vscode.Disposable =
  #| (debugType, factory) =>
  #|   require("vscode").debug.registerDebugAdapterDescriptorFactory(debugType, factory)

///|
extern "js" fn debug_register_debug_adapter_tracker_factory_ffi(
  debug_type : String,
  factory : DebugAdapterTrackerFactory,
) -> @vscode.Disposable =
  #| (debugType, factory) =>
  #|   require("vscode").debug.registerDebugAdapterTrackerFactory(debugType, factory)

///|
extern "js" fn debug_as_debug_source_uri_ffi(
  source : DebugProtocolSource,
  session : @v.JsValue,
) -> Uri =
  #| (source, session) =>
  #|   require("vscode").debug.asDebugSourceUri(
  #|     source,
  #|     session === undefined || session === null ? undefined : session
  #|   )

///|
extern "js" fn debug_add_breakpoints_ffi(
  breakpoints : Array[Breakpoint],
) -> Unit =
  #| (breakpoints) => require("vscode").debug.addBreakpoints(breakpoints)

///|
extern "js" fn debug_remove_breakpoints_ffi(
  breakpoints : Array[Breakpoint],
) -> Unit =
  #| (breakpoints) => require("vscode").debug.removeBreakpoints(breakpoints)

///|
extern "js" fn debug_add_source_breakpoints_ffi(
  breakpoints : Array[SourceBreakpoint],
) -> Unit =
  #| (breakpoints) => require("vscode").debug.addBreakpoints(breakpoints)

///|
extern "js" fn debug_remove_source_breakpoints_ffi(
  breakpoints : Array[SourceBreakpoint],
) -> Unit =
  #| (breakpoints) => require("vscode").debug.removeBreakpoints(breakpoints)

///|
extern "js" fn debug_add_function_breakpoints_ffi(
  breakpoints : Array[FunctionBreakpoint],
) -> Unit =
  #| (breakpoints) => require("vscode").debug.addBreakpoints(breakpoints)

///|
extern "js" fn debug_remove_function_breakpoints_ffi(
  breakpoints : Array[FunctionBreakpoint],
) -> Unit =
  #| (breakpoints) => require("vscode").debug.removeBreakpoints(breakpoints)

///|
extern "js" fn debug_start_debugging_name_ffi(
  folder : @v.JsValue,
  name : String,
  parent_session : @v.JsValue,
) -> @js_async.Promise[Bool] =
  #| (folder, name, parentSession) => {
  #|   const debug = require("vscode").debug;
  #|   return debug.startDebugging(
  #|     folder === undefined || folder === null ? undefined : folder,
  #|     name,
  #|     parentSession === undefined || parentSession === null ? undefined : parentSession
  #|   );
  #| }

///|
extern "js" fn debug_start_debugging_name_with_options_ffi(
  folder : @v.JsValue,
  name : String,
  options : @v.JsValue,
) -> @js_async.Promise[Bool] =
  #| (folder, name, options) => {
  #|   const debug = require("vscode").debug;
  #|   return debug.startDebugging(
  #|     folder === undefined || folder === null ? undefined : folder,
  #|     name,
  #|     options === undefined || options === null ? undefined : options
  #|   );
  #| }

///|
extern "js" fn debug_start_debugging_configuration_ffi(
  folder : @v.JsValue,
  configuration : DebugConfiguration,
  parent_session : @v.JsValue,
) -> @js_async.Promise[Bool] =
  #| (folder, configuration, parentSession) => {
  #|   const debug = require("vscode").debug;
  #|   return debug.startDebugging(
  #|     folder === undefined || folder === null ? undefined : folder,
  #|     configuration,
  #|     parentSession === undefined || parentSession === null ? undefined : parentSession
  #|   );
  #| }

///|
extern "js" fn debug_start_debugging_configuration_with_options_ffi(
  folder : @v.JsValue,
  configuration : DebugConfiguration,
  options : @v.JsValue,
) -> @js_async.Promise[Bool] =
  #| (folder, configuration, options) => {
  #|   const debug = require("vscode").debug;
  #|   return debug.startDebugging(
  #|     folder === undefined || folder === null ? undefined : folder,
  #|     configuration,
  #|     options === undefined || options === null ? undefined : options
  #|   );
  #| }

///|
extern "js" fn debug_stop_debugging_ffi(
  session : @v.JsValue,
) -> @js_async.Promise[Unit] =
  #| (session) =>
  #|   require("vscode").debug.stopDebugging(
  #|     session === undefined || session === null ? undefined : session
  #|   )
