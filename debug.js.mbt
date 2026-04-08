///|
/// Debug helpers and constructors.

///|
/// A DebugProtocolBreakpoint is an opaque stand-in type for the [Breakpoint](https://microsoft.github.io/debug-adapter-protocol/specification#Types_Breakpoint) type defined in the Debug Adapter Protocol.
pub struct DebugProtocolBreakpoint {
  json : Any
}

///|
pub fn DebugProtocolBreakpoint::from_json(
  value : Any,
) -> DebugProtocolBreakpoint {
  DebugProtocolBreakpoint::{ json: value }
}

///|
pub fn DebugProtocolBreakpoint::as_json(value : DebugProtocolBreakpoint) -> Any {
  value.json
}

///|
/// The unique ID of the breakpoint.
pub extern "js" fn Breakpoint::id(self : Breakpoint) -> String =
  #| (breakpoint) => breakpoint.id

///|
/// Is breakpoint enabled.
pub extern "js" fn Breakpoint::enabled(self : Breakpoint) -> Bool =
  #| (breakpoint) => breakpoint.enabled

///|
/// An optional expression for conditional breakpoints.
pub fn Breakpoint::condition(self : Breakpoint) -> String? {
  let raw = breakpoint_condition_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An optional expression that controls how many hits of the breakpoint are ignored.
pub fn Breakpoint::hit_condition(self : Breakpoint) -> String? {
  let raw = breakpoint_hit_condition_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An optional message that gets logged when this breakpoint is hit. Embedded expressions within {} are interpolated by the debug adapter.
pub fn Breakpoint::log_message(self : Breakpoint) -> String? {
  let raw = breakpoint_log_message_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Added breakpoints.
pub fn BreakpointsChangeEvent::new(
  added? : Array[Breakpoint] = [],
  removed? : Array[Breakpoint] = [],
  changed? : Array[Breakpoint] = [],
) -> BreakpointsChangeEvent {
  BreakpointsChangeEvent::{ added, removed, changed }
}

///|
/// Added breakpoints.

///|
/// Removed breakpoints.

///|
/// Changed breakpoints.

///|
/// Create a new breakpoint for a source location.
pub fn SourceBreakpoint::new(
  location : Location,
  enabled? : Bool,
  condition? : String,
  hit_condition? : String,
  log_message? : String,
) -> SourceBreakpoint {
  source_breakpoint_ffi(
    location,
    option_to_js(enabled),
    option_to_js(condition),
    option_to_js(hit_condition),
    option_to_js(log_message),
  )
}

///|
/// The source and line position of this breakpoint.
pub extern "js" fn SourceBreakpoint::location(
  self : SourceBreakpoint,
) -> Location =
  #| (breakpoint) => breakpoint.location

///|
/// Create a new function breakpoint.
pub fn FunctionBreakpoint::new(
  function_name : String,
  enabled? : Bool,
  condition? : String,
  hit_condition? : String,
  log_message? : String,
) -> FunctionBreakpoint {
  function_breakpoint_ffi(
    function_name,
    option_to_js(enabled),
    option_to_js(condition),
    option_to_js(hit_condition),
    option_to_js(log_message),
  )
}

///|
/// The name of the function to which this breakpoint is attached.
pub extern "js" fn FunctionBreakpoint::function_name(
  self : FunctionBreakpoint,
) -> String =
  #| (breakpoint) => breakpoint.functionName

///|
pub fn DebugConfiguration::new(
  type_ : String,
  name : String,
  request : String,
  entries? : Array[(String, Any)],
) -> DebugConfiguration {
  debug_configuration_ffi(type_, name, request, option_to_js(entries))
}

///|
pub fn DebugConfiguration::from_json(value : Any) -> DebugConfiguration {
  JsValue::make(value).cast()
}

///|
pub fn DebugConfiguration::as_json(value : DebugConfiguration) -> Any {
  JsValue::make(value).cast()
}

///|
/// Gets a debug-type specific property value.
pub fn DebugConfiguration::get_entry(
  self : DebugConfiguration,
  key : String,
) -> Any? {
  let raw = debug_configuration_get_entry_raw(self, key)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Sets a debug-type specific property value.
pub extern "js" fn DebugConfiguration::set_entry(
  self : DebugConfiguration,
  key : String,
  value : Any,
) -> Unit =
  #| (configuration, key, value) => { configuration[key] = value; }

///|
/// Removes a debug-type specific property.
pub extern "js" fn DebugConfiguration::delete_entry(
  self : DebugConfiguration,
  key : String,
) -> Unit =
  #| (configuration, key) => { delete configuration[key]; }

///|
/// Returns all own properties (including type/name/request) as key-value entries.
pub extern "js" fn DebugConfiguration::entries(
  self : DebugConfiguration,
) -> Array[(String, Any)] =
  #| (configuration) => {
  #|   const entries = [];
  #|   for (const key of Object.keys(configuration)) {
  #|     entries.push([key, configuration[key]]);
  #|   }
  #|   return entries;
  #| }

///|
pub(all) enum DebugConsoleMode {
  Separate = 0
  MergeWithParent = 1
} derive(Eq)

///|
pub fn DebugSessionOptions::new(
  parent_session? : DebugSession,
  lifecycle_managed_by_parent? : Bool,
  console_mode? : DebugConsoleMode,
  no_debug? : Bool,
  compact? : Bool,
  suppress_save_before_start? : Bool,
  suppress_debug_toolbar? : Bool,
  suppress_debug_statusbar? : Bool,
  suppress_debug_view? : Bool,
  test_run? : Any,
) -> DebugSessionOptions {
  DebugSessionOptions::{
    parent_session,
    lifecycle_managed_by_parent,
    console_mode,
    no_debug,
    compact,
    suppress_save_before_start,
    suppress_debug_toolbar,
    suppress_debug_statusbar,
    suppress_debug_view,
    test_run,
  }
}

///|
/// The unique ID of this debug session.
pub extern "js" fn DebugSession::id(self : DebugSession) -> String =
  #| (session) => session.id

///|
/// The debug session's type from the {@link DebugConfiguration debug configuration}.
pub extern "js" fn DebugSession::type_(self : DebugSession) -> String =
  #| (session) => session.type

///|
/// The parent session of this debug session, if it was created as a child.
/// @see DebugSessionOptions.parentSession
pub fn DebugSession::parent_session(self : DebugSession) -> DebugSession? {
  let raw = debug_session_parent_session_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The debug session's name is initially taken from the {@link DebugConfiguration debug configuration}.
/// Any changes will be properly reflected in the UI.
pub extern "js" fn DebugSession::name(self : DebugSession) -> String =
  #| (session) => session.name

///|
/// The debug session's name is initially taken from the {@link DebugConfiguration debug configuration}.
/// Any changes will be properly reflected in the UI.
pub extern "js" fn DebugSession::set_name(
  self : DebugSession,
  value : String,
) -> Unit =
  #| (session, value) => { session.name = value; }

///|
/// The workspace folder of this session or `undefined` for a folderless setup.
pub fn DebugSession::workspace_folder(self : DebugSession) -> WorkspaceFolder? {
  let raw = debug_session_workspace_folder_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The "resolved" {@link DebugConfiguration debug configuration} of this session.
/// "Resolved" means that
/// - all variables have been substituted and
/// - platform specific attribute sections have been "flattened" for the matching platform and removed for non-matching platforms.
pub extern "js" fn DebugSession::configuration(
  self : DebugSession,
) -> DebugConfiguration =
  #| (session) => session.configuration

///|
extern "js" fn DebugSession::custom_request_promise(
  self : DebugSession,
  command : String,
  args : JsValue,
) -> @js_async.Promise[Any] =
  #| (session, command, args) =>
  #|   Promise.resolve(session.customRequest(command, args === undefined || args === null ? undefined : args))

///|
/// Send a custom request to the debug adapter.
pub async fn DebugSession::custom_request(
  self : DebugSession,
  command : String,
  args? : Any,
) -> Any {
  @js_async.Promise::wait(
    DebugSession::custom_request_promise(self, command, option_to_js(args)),
  )
}

///|
extern "js" fn DebugSession::get_debug_protocol_breakpoint_promise(
  self : DebugSession,
  breakpoint : Breakpoint,
) -> @js_async.Promise[JsValue] =
  #| (session, breakpoint) => Promise.resolve(session.getDebugProtocolBreakpoint(breakpoint))

///|
extern "js" fn debug_session_parent_session_raw(
  session : DebugSession,
) -> JsValue =
  #| (session) => session.parentSession

///|
extern "js" fn debug_session_workspace_folder_raw(
  session : DebugSession,
) -> JsValue =
  #| (session) => session.workspaceFolder

///|
/// Maps a breakpoint in the editor to the corresponding Debug Adapter Protocol (DAP) breakpoint that is managed by the debug adapter of the debug session.
/// If no DAP breakpoint exists (either because the editor breakpoint was not yet registered or because the debug adapter is not interested in the breakpoint), the value `undefined` is returned.
///
/// @param breakpoint A {@link Breakpoint} in the editor.
/// @returns A promise that resolves to the Debug Adapter Protocol breakpoint or `undefined`.
pub async fn DebugSession::get_debug_protocol_breakpoint(
  self : DebugSession,
  breakpoint : Breakpoint,
) -> DebugProtocolBreakpoint? {
  let raw = @js_async.Promise::wait(
    DebugSession::get_debug_protocol_breakpoint_promise(self, breakpoint),
  )
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(DebugProtocolBreakpoint::from_json(JsValue::make(raw).cast()))
  }
}

///|
/// Debug session for thread.
pub fn DebugThread::new(session : DebugSession, thread_id : Int) -> DebugThread {
  debug_thread_ffi(session, thread_id)
}

///|
/// Debug session for thread.
pub extern "js" fn DebugThread::session(self : DebugThread) -> DebugSession =
  #| (thread) => thread.session

///|
/// ID of the associated thread in the debug protocol.
pub extern "js" fn DebugThread::thread_id(self : DebugThread) -> Int =
  #| (thread) => thread.threadId

///|
/// Debug session for thread.
pub fn DebugStackFrame::new(
  session : DebugSession,
  thread_id : Int,
  frame_id : Int,
) -> DebugStackFrame {
  debug_stack_frame_ffi(session, thread_id, frame_id)
}

///|
/// Debug session for thread.
pub extern "js" fn DebugStackFrame::session(
  self : DebugStackFrame,
) -> DebugSession =
  #| (frame) => frame.session

///|
/// ID of the associated thread in the debug protocol.
pub extern "js" fn DebugStackFrame::thread_id(self : DebugStackFrame) -> Int =
  #| (frame) => frame.threadId

///|
/// ID of the stack frame in the debug protocol.
pub extern "js" fn DebugStackFrame::frame_id(self : DebugStackFrame) -> Int =
  #| (frame) => frame.frameId

///|
pub fn DebugStackItem::from_thread(value : DebugThread) -> DebugStackItem {
  JsValue::make(value).cast()
}

///|
pub fn DebugStackItem::from_frame(value : DebugStackFrame) -> DebugStackItem {
  JsValue::make(value).cast()
}

///|
pub fn DebugStackItem::as_thread(self : DebugStackItem) -> DebugThread? {
  let raw = debug_stack_item_thread_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn DebugStackItem::as_frame(self : DebugStackItem) -> DebugStackFrame? {
  let raw = debug_stack_item_frame_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
extern "js" fn breakpoint_condition_raw(breakpoint : Breakpoint) -> JsValue =
  #| (breakpoint) => breakpoint.condition

///|
extern "js" fn breakpoint_hit_condition_raw(breakpoint : Breakpoint) -> JsValue =
  #| (breakpoint) => breakpoint.hitCondition

///|
extern "js" fn breakpoint_log_message_raw(breakpoint : Breakpoint) -> JsValue =
  #| (breakpoint) => breakpoint.logMessage

///|
extern "js" fn debug_thread_ffi(
  session : DebugSession,
  thread_id : Int,
) -> DebugThread =
  #| (session, threadId) => ({ session, threadId })

///|
extern "js" fn debug_stack_frame_ffi(
  session : DebugSession,
  thread_id : Int,
  frame_id : Int,
) -> DebugStackFrame =
  #| (session, threadId, frameId) => ({ session, threadId, frameId })

///|
extern "js" fn source_breakpoint_ffi(
  location : Location,
  enabled : JsValue,
  condition : JsValue,
  hit_condition : JsValue,
  log_message : JsValue,
) -> SourceBreakpoint =
  #| (location, enabled, condition, hitCondition, logMessage) =>
  #|   new (require("vscode").SourceBreakpoint)(
  #|     location,
  #|     enabled === undefined || enabled === null ? undefined : enabled,
  #|     condition === undefined || condition === null ? undefined : condition,
  #|     hitCondition === undefined || hitCondition === null ? undefined : hitCondition,
  #|     logMessage === undefined || logMessage === null ? undefined : logMessage
  #|   )

///|
extern "js" fn function_breakpoint_ffi(
  function_name : String,
  enabled : JsValue,
  condition : JsValue,
  hit_condition : JsValue,
  log_message : JsValue,
) -> FunctionBreakpoint =
  #| (functionName, enabled, condition, hitCondition, logMessage) =>
  #|   new (require("vscode").FunctionBreakpoint)(
  #|     functionName,
  #|     enabled === undefined || enabled === null ? undefined : enabled,
  #|     condition === undefined || condition === null ? undefined : condition,
  #|     hitCondition === undefined || hitCondition === null ? undefined : hitCondition,
  #|     logMessage === undefined || logMessage === null ? undefined : logMessage
  #|   )

///|
extern "js" fn debug_configuration_ffi(
  type_ : String,
  name : String,
  request : String,
  entries : JsValue,
) -> DebugConfiguration =
  #| (type, name, request, entries) => {
  #|   const config = { type, name, request };
  #|   if (entries !== undefined && entries !== null) {
  #|     for (const entry of entries) {
  #|       const key = entry._0 ?? entry[0];
  #|       const value = entry._1 ?? entry[1];
  #|       config[key] = value;
  #|     }
  #|   }
  #|   return config;
  #| }

///|
extern "js" fn debug_configuration_get_entry_raw(
  configuration : DebugConfiguration,
  key : String,
) -> JsValue =
  #| (configuration, key) => configuration[key]

///|
extern "js" fn debug_stack_item_thread_raw(item : DebugStackItem) -> JsValue =
  #| (item) => (item && item.frameId === undefined) ? item : undefined

///|
extern "js" fn debug_stack_item_frame_raw(item : DebugStackItem) -> JsValue =
  #| (item) => (item && item.frameId !== undefined) ? item : undefined
