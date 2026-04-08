///|
/// Task helpers.

///|
/// A structure that defines a task kind in the system.
/// The value must be JSON-stringifyable.
pub struct TaskDefinition {
  value : Any
}

///|
/// The scope of a task.
pub(all) enum TaskScope {
  ScopeKind(TaskScopeKind)
  WorkspaceFolderScope(WorkspaceFolder)
}

///|
/// A grouping for tasks. The editor by default supports the
/// 'Clean', 'Build', 'RebuildAll' and 'Test' group.
pub type TaskGroup

///|
pub(all) enum TaskScopeKind {
  Global = 1
  Workspace = 2
} derive(Eq)

///|
fn TaskScope::to_js(self : TaskScope) -> JsValue {
  match self {
    ScopeKind(kind) => JsValue::make(kind)
    WorkspaceFolderScope(folder) => JsValue::make(folder)
  }
}

///|
pub fn TaskGroup::clean() -> TaskGroup {
  task_group_clean_ffi()
}

///|
pub fn TaskGroup::build() -> TaskGroup {
  task_group_build_ffi()
}

///|
pub fn TaskGroup::rebuild() -> TaskGroup {
  task_group_rebuild_ffi()
}

///|
pub fn TaskGroup::test_group() -> TaskGroup {
  task_group_test_ffi()
}

///|
/// The ID of the task group. Is one of TaskGroup.Clean.id, TaskGroup.Build.id, TaskGroup.Rebuild.id, or TaskGroup.Test.id.
pub extern "js" fn TaskGroup::id(self : TaskGroup) -> String =
  #| (value) => value.id

///|
/// Whether the task that is part of this group is the default for the group.
/// This property cannot be set through API, and is controlled by a user's task configurations.
pub fn TaskGroup::is_default(self : TaskGroup) -> Bool? {
  task_js_to_option(task_group_is_default_raw(self))
}

///|
pub fn TaskDefinition::new(
  type_ : String,
  entries? : Array[(String, Any)],
) -> TaskDefinition {
  TaskDefinition::{
    value: task_definition_ffi(type_, option_to_js(entries)).cast(),
  }
}

///|
pub fn TaskDefinition::from_json(value : Any) -> TaskDefinition {
  TaskDefinition::{ value, }
}

///|
pub fn TaskDefinition::as_json(value : TaskDefinition) -> Any {
  value.value
}

///|
fn TaskDefinition::to_js(self : TaskDefinition) -> JsValue {
  JsValue::make(self.value)
}

///|
pub(all) enum TaskRevealKind {
  Always = 1
  Silent = 2
  Never = 3
} derive(Eq)

///|
pub(all) enum TaskPanelKind {
  Shared = 1
  Dedicated = 2
  New = 3
} derive(Eq)

///|
pub(all) enum ShellQuoting {
  Escape = 1
  Strong = 2
  Weak = 3
} derive(Eq)

///|
/// Controls how the task is presented in the UI.
pub(all) struct TaskPresentationOptions {
  mut reveal : TaskRevealKind?
  mut echo : Bool?
  mut focus : Bool?
  mut panel : TaskPanelKind?
  mut show_reuse_message : Bool?
  mut clear : Bool?
  mut close : Bool?
}

///|
/// Options for a process execution
pub(all) struct ProcessExecutionOptions {
  mut cwd : String?
  mut env : Array[(String, String)]?
}

///|
/// The execution of a task happens as an external process
/// without shell interaction.
pub type ProcessExecution

///|
pub(all) enum ShellQuotingEscape {
  EscapeString(String)
  EscapeChars((String, String))
}

///|
/// The shell quoting options.
pub(all) struct ShellQuotingOptions {
  escape : ShellQuotingEscape?
  mut strong : String?
  mut weak : String?
}

///|
/// Options for a shell execution
pub(all) struct ShellExecutionOptions {
  mut executable : String?
  mut shell_args : Array[String]?
  mut shell_quoting : ShellQuotingOptions?
  mut cwd : String?
  mut env : Array[(String, String)]?
}

///|
/// A string that will be quoted depending on the used shell.
pub(all) struct ShellQuotedString {
  mut value : String
  mut quoting : ShellQuoting
}

///|
pub(all) enum StringOrShellQuotedString {
  Text(String)
  Quoted(ShellQuotedString)
}

///|
/// Represents a task execution that happens inside a shell.
pub type ShellExecution

///|
/// Class used to execute an extension callback as a task.
pub type CustomExecution

///|
/// Run options for a task.
pub(all) struct RunOptions {
  mut reevaluate_on_rerun : Bool?
}

///|
pub(all) enum TaskExecutionValue {
  ProcessExecutionValue(ProcessExecution)
  ShellExecutionValue(ShellExecution)
  CustomExecutionValue(CustomExecution)
}

///|
fn[X] task_js_to_option(raw : JsValue) -> X? {
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
fn process_execution_options_from_js(raw : JsValue) -> ProcessExecutionOptions {
  let env_raw = process_execution_options_env_raw(raw)
  let env : Array[(String, String)]? = if env_raw.is_null_or_undefined() {
    None
  } else {
    Some(task_string_map_to_pairs_ffi(env_raw))
  }
  let cwd : String? = task_js_to_option(process_execution_options_cwd_raw(raw))
  ProcessExecutionOptions::{ cwd, env }
}

///|
fn string_or_shell_quoted_string_from_js(
  raw : JsValue,
) -> StringOrShellQuotedString {
  if task_js_value_is_string_ffi(raw) {
    Text(raw.cast())
  } else {
    Quoted(raw.cast())
  }
}

///|
fn string_or_shell_quoted_string_array_from_js(
  raw : JsValue,
) -> Array[StringOrShellQuotedString] {
  let result : Array[StringOrShellQuotedString] = []
  for value in task_js_value_array_ffi(raw) {
    result.push(string_or_shell_quoted_string_from_js(value))
  }
  result
}

///|
/// Creates a new task.
///
/// @param taskDefinition The task definition as defined in the taskDefinitions extension point.
/// @param scope Specifies the task's scope. It is either a global or a workspace task or a task for a specific workspace folder. Global tasks are currently not supported.
/// @param name The task's name. Is presented in the user interface.
/// @param source The task's source (e.g. 'gulp', 'npm', ...). Is presented in the user interface.
/// @param execution The process or shell execution.
/// @param problemMatchers the names of problem matchers to use, like '$tsc'
///  or '$eslint'. Problem matchers can be contributed by an extension using
///  the `problemMatchers` extension point.
pub fn Task::new(
  definition : TaskDefinition,
  scope : TaskScope,
  name : String,
  source : String,
  execution? : TaskExecutionValue,
  problem_matchers? : Array[String],
) -> Task {
  let execution_value = match execution {
    None => JsValue::make(())
    Some(value) =>
      match value {
        ProcessExecutionValue(value) => JsValue::make(value)
        ShellExecutionValue(value) => JsValue::make(value)
        CustomExecutionValue(value) => JsValue::make(value)
      }
  }
  task_new_ffi(
    definition.to_js(),
    scope.to_js(),
    name,
    source,
    execution_value,
    option_to_js(problem_matchers),
  )
}

///|
/// The task's definition.
pub extern "js" fn Task::definition(self : Task) -> TaskDefinition =
  #| (task) => task.definition

///|
/// The task's definition.
pub extern "js" fn Task::set_definition(
  self : Task,
  value : TaskDefinition,
) -> Unit =
  #| (task, value) => { task.definition = value; }

///|
/// The task's scope.
pub fn Task::scope(self : Task) -> TaskScope? {
  task_js_to_option(task_scope_raw(self))
}

///|
/// The task's name
pub extern "js" fn Task::name(self : Task) -> String =
  #| (task) => task.name

///|
/// The task's name
pub extern "js" fn Task::set_name(self : Task, value : String) -> Unit =
  #| (task, value) => { task.name = value; }

///|
/// A human-readable string describing the source of this shell task, e.g. 'gulp'
/// or 'npm'. Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
pub extern "js" fn Task::source(self : Task) -> String =
  #| (task) => task.source

///|
/// A human-readable string describing the source of this shell task, e.g. 'gulp'
/// or 'npm'. Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
pub extern "js" fn Task::set_source(self : Task, value : String) -> Unit =
  #| (task, value) => { task.source = value; }

///|
/// A human-readable string which is rendered less prominently on a separate line in places
/// where the task's name is displayed. Supports rendering of {@link ThemeIcon theme icons}
/// via the `$(<name>)`-syntax.
pub fn Task::detail(self : Task) -> String? {
  task_js_to_option(task_detail_raw(self))
}

///|
/// A human-readable string which is rendered less prominently on a separate line in places
/// where the task's name is displayed. Supports rendering of {@link ThemeIcon theme icons}
/// via the `$(<name>)`-syntax.
pub fn Task::set_detail(self : Task, value : String?) -> Unit {
  task_set_detail_raw(self, option_to_js(value))
}

///|
/// A human-readable string which is rendered less prominently on a separate line in places
/// where the task's name is displayed. Supports rendering of {@link ThemeIcon theme icons}
/// via the `$(<name>)`-syntax.
pub fn Task::clear_detail(self : Task) -> Unit {
  task_set_detail_raw(self, JsValue::make(()))
}

///|
/// Whether the task is a background task or not.
pub extern "js" fn Task::is_background(self : Task) -> Bool =
  #| (task) => task.isBackground

///|
/// Whether the task is a background task or not.
pub extern "js" fn Task::set_is_background(self : Task, value : Bool) -> Unit =
  #| (task, value) => { task.isBackground = value; }

///|
/// The task group this tasks belongs to. See TaskGroup
/// for a predefined set of available groups.
/// Defaults to undefined meaning that the task doesn't
/// belong to any special group.
pub fn Task::group(self : Task) -> TaskGroup? {
  task_js_to_option(task_group_raw(self))
}

///|
/// The task group this tasks belongs to. See TaskGroup
/// for a predefined set of available groups.
/// Defaults to undefined meaning that the task doesn't
/// belong to any special group.
pub fn Task::set_group(self : Task, value : TaskGroup?) -> Unit {
  task_set_group_raw(self, option_to_js(value))
}

///|
/// The task group this tasks belongs to. See TaskGroup
/// for a predefined set of available groups.
/// Defaults to undefined meaning that the task doesn't
/// belong to any special group.
pub fn Task::clear_group(self : Task) -> Unit {
  task_set_group_raw(self, JsValue::make(()))
}

///|
/// The problem matchers attached to the task. Defaults to an empty
/// array.
pub extern "js" fn Task::problem_matchers(self : Task) -> Array[String] =
  #| (task) => task.problemMatchers

///|
/// The problem matchers attached to the task. Defaults to an empty
/// array.
pub extern "js" fn Task::set_problem_matchers(
  self : Task,
  value : Array[String],
) -> Unit =
  #| (task, value) => { task.problemMatchers = value; }

///|
/// The presentation options. Defaults to an empty literal.
pub extern "js" fn Task::presentation_options(
  self : Task,
) -> TaskPresentationOptions =
  #| (task) => task.presentationOptions

///|
/// The presentation options. Defaults to an empty literal.
pub extern "js" fn Task::set_presentation_options(
  self : Task,
  value : TaskPresentationOptions,
) -> Unit =
  #| (task, value) => { task.presentationOptions = value; }

///|
/// Run options for the task
pub extern "js" fn Task::run_options(self : Task) -> RunOptions =
  #| (task) => task.runOptions

///|
/// Run options for the task
pub extern "js" fn Task::set_run_options(
  self : Task,
  value : RunOptions,
) -> Unit =
  #| (task, value) => { task.runOptions = value; }

///|
pub fn Task::new_typed(
  definition : TaskDefinition,
  scope : TaskScope,
  name : String,
  source : String,
  execution? : TaskExecutionValue,
  problem_matchers? : Array[String],
) -> Task {
  task_new_ffi(
    definition.to_js(),
    scope.to_js(),
    name,
    source,
    option_task_execution_value_to_js(execution),
    option_to_js(problem_matchers),
  )
}

///|
/// The task that got started.
pub extern "js" fn TaskExecution::task(self : TaskExecution) -> Task =
  #| (execution) => execution.task

///|
/// Terminates the task execution.
pub extern "js" fn TaskExecution::terminate(self : TaskExecution) -> Unit =
  #| (execution) => execution.terminate()

///|
extern "js" fn task_scope_raw(task : Task) -> JsValue =
  #| (task) => task.scope

///|
extern "js" fn task_detail_raw(task : Task) -> JsValue =
  #| (task) => task.detail

///|
extern "js" fn task_set_detail_raw(task : Task, value : JsValue) -> Unit =
  #| (task, value) => { task.detail = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn task_group_raw(task : Task) -> JsValue =
  #| (task) => task.group

///|
extern "js" fn task_group_is_default_raw(group : TaskGroup) -> JsValue =
  #| (group) => group.isDefault

///|
extern "js" fn task_set_group_raw(task : Task, value : JsValue) -> Unit =
  #| (task, value) => { task.group = value === undefined || value === null ? undefined : value; }

///|
/// The task item representing the task that got started.
pub fn TaskStartEvent::new(execution : TaskExecution) -> TaskStartEvent {
  TaskStartEvent::{ execution, }
}

///|
/// The task item representing the task that got started.

///|
/// The task item representing the task that finished.
pub fn TaskEndEvent::new(execution : TaskExecution) -> TaskEndEvent {
  TaskEndEvent::{ execution, }
}

///|
/// The task item representing the task that finished.

///|
/// The task execution for which the process got started.
pub fn TaskProcessStartEvent::new(
  execution : TaskExecution,
  process_id : Int,
) -> TaskProcessStartEvent {
  TaskProcessStartEvent::{ execution, processId: process_id }
}

///|
/// The task execution for which the process got started.

///|
/// The underlying process id.

///|
/// The task execution for which the process got started.
pub fn TaskProcessEndEvent::new(
  execution : TaskExecution,
  exit_code? : Int,
) -> TaskProcessEndEvent {
  TaskProcessEndEvent::{ execution, exitCode: exit_code }
}

///|
/// The task execution for which the process got started.

///|
/// The process's exit code. Will be `undefined` when the task is terminated.

///|
pub fn TaskFilter::new(version? : String, type_? : String) -> TaskFilter {
  TaskFilter::{ version, type_ }
}

///|
/// The task version as used in the tasks.json file.
/// The string support the package.json semver notation.

///|
/// The task type to return;

///|
pub fn TaskPresentationOptions::new(
  reveal? : TaskRevealKind,
  echo? : Bool,
  focus? : Bool,
  panel? : TaskPanelKind,
  show_reuse_message? : Bool,
  clear? : Bool,
  close? : Bool,
) -> TaskPresentationOptions {
  TaskPresentationOptions::{
    reveal,
    echo,
    focus,
    panel,
    show_reuse_message,
    clear,
    close,
  }
}

///|
/// Controls whether the task output is reveal in the user interface.
/// Defaults to `RevealKind.Always`.

///|
/// Controls whether the command associated with the task is echoed
/// in the user interface.

///|
/// Controls whether the panel showing the task output is taking focus.

///|
/// Controls if the task panel is used for this task only (dedicated),
/// shared between tasks (shared) or if a new panel is created on
/// every task execution (new). Defaults to `TaskInstanceKind.Shared`

///|
/// Controls whether to show the "Terminal will be reused by tasks, press any key to close it" message.

///|
/// Controls whether the terminal is cleared before executing the task.

///|
/// Controls whether the terminal is closed after executing the task.

///|
pub fn ProcessExecutionOptions::new(
  cwd? : String,
  env? : Array[(String, String)],
) -> ProcessExecutionOptions {
  ProcessExecutionOptions::{ cwd, env }
}

///|
/// The current working directory of the executed program or shell.
/// If omitted the tools current workspace root is used.

///|
/// The additional environment of the executed program or shell. If omitted
/// the parent process' environment is used. If provided it is merged with
/// the parent process' environment.

///|
/// Creates a process execution.
///
/// @param process The process to start.
/// @param options Optional options for the started process.
pub fn ProcessExecution::new(
  process : String,
  options? : ProcessExecutionOptions,
) -> ProcessExecution {
  process_execution_new_ffi(
    process,
    option_process_execution_options_to_js(options),
  )
}

///|
pub fn ProcessExecution::new_with_args(
  process : String,
  args : Array[String],
  options? : ProcessExecutionOptions,
) -> ProcessExecution {
  process_execution_new_with_args_ffi(
    process,
    args,
    option_process_execution_options_to_js(options),
  )
}

///|
/// The process to be executed.
pub extern "js" fn ProcessExecution::process(self : ProcessExecution) -> String =
  #| (value) => value.process

///|
/// The arguments passed to the process. Defaults to an empty array.
pub extern "js" fn ProcessExecution::args(
  self : ProcessExecution,
) -> Array[String] =
  #| (value) => value.args

///|
/// The process options used when the process is executed.
/// Defaults to undefined.
pub fn ProcessExecution::options(
  self : ProcessExecution,
) -> ProcessExecutionOptions? {
  let raw = process_execution_options_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(process_execution_options_from_js(raw))
  }
}

///|
fn ShellQuotingEscape::to_js(self : ShellQuotingEscape) -> JsValue {
  match self {
    EscapeString(value) => JsValue::make(value)
    EscapeChars((escape_char, chars_to_escape)) =>
      shell_quoting_escape_ffi(escape_char, chars_to_escape)
  }
}

///|
fn option_shell_quoting_escape_to_js(value : ShellQuotingEscape?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
pub fn ShellQuotingOptions::new(
  escape? : ShellQuotingEscape,
  strong? : String,
  weak? : String,
) -> ShellQuotingOptions {
  ShellQuotingOptions::{ escape, strong, weak }
}

///|
/// The character used to do character escaping. If a string is provided only spaces
/// are escaped. If a `{ escapeChar, charsToEscape }` literal is provide all characters
/// in `charsToEscape` are escaped using the `escapeChar`.

///|
/// The character used for strong quoting. The string's length must be 1.

///|
/// The character used for weak quoting. The string's length must be 1.

///|
pub fn ShellExecutionOptions::new(
  executable? : String,
  shell_args? : Array[String],
  shell_quoting? : ShellQuotingOptions,
  cwd? : String,
  env? : Array[(String, String)],
) -> ShellExecutionOptions {
  ShellExecutionOptions::{ executable, shell_args, shell_quoting, cwd, env }
}

///|
/// The shell executable.

///|
/// The arguments to be passed to the shell executable used to run the task. Most shells
/// require special arguments to execute a command. For  example `bash` requires the `-c`
/// argument to execute a command, `PowerShell` requires `-Command` and `cmd` requires both
/// `/d` and `/c`.

///|
/// The shell quotes supported by this shell.

///|
/// The current working directory of the executed shell.
/// If omitted the tools current workspace root is used.

///|
/// The additional environment of the executed shell. If omitted
/// the parent process' environment is used. If provided it is merged with
/// the parent process' environment.

///|
pub fn ShellQuotedString::new(
  value : String,
  quoting : ShellQuoting,
) -> ShellQuotedString {
  ShellQuotedString::{ value, quoting }
}

///|
/// The actual string value.

///|
/// The quoting style to use.

///|
fn StringOrShellQuotedString::to_js(
  self : StringOrShellQuotedString,
) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Quoted(value) => shell_quoted_string_to_js(value)
  }
}

///|
pub fn ShellExecution::new_command_line(
  command_line : String,
  options? : ShellExecutionOptions,
) -> ShellExecution {
  shell_execution_new_command_line_ffi(
    command_line,
    option_shell_execution_options_to_js(options),
  )
}

///|
pub fn ShellExecution::new_command(
  command : StringOrShellQuotedString,
  args : Array[StringOrShellQuotedString],
  options? : ShellExecutionOptions,
) -> ShellExecution {
  let args_js : Array[JsValue] = []
  for argument in args {
    args_js.push(argument.to_js())
  }
  shell_execution_new_command_ffi(
    command.to_js(),
    args_js,
    option_shell_execution_options_to_js(options),
  )
}

///|
/// The shell command line. Is `undefined` if created with a command and arguments.
pub fn ShellExecution::command_line(self : ShellExecution) -> String? {
  task_js_to_option(shell_execution_command_line_raw(self))
}

///|
/// The shell command. Is `undefined` if created with a full command line.
pub fn ShellExecution::command(
  self : ShellExecution,
) -> StringOrShellQuotedString? {
  let raw = shell_execution_command_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(string_or_shell_quoted_string_from_js(raw))
  }
}

///|
/// The shell args. Is `undefined` if created with a full command line.
pub fn ShellExecution::args(
  self : ShellExecution,
) -> Array[StringOrShellQuotedString]? {
  let raw = shell_execution_args_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(string_or_shell_quoted_string_array_from_js(raw))
  }
}

///|
/// The shell options used when the command line is executed in a shell.
/// Defaults to undefined.
pub fn ShellExecution::options(self : ShellExecution) -> ShellExecutionOptions? {
  task_js_to_option(shell_execution_options_raw(self))
}

///|
/// Constructs a CustomExecution task object. The callback will be executed when the task is run, at which point the
/// extension should return the Pseudoterminal it will "run in". The task should wait to do further execution until
/// {@link Pseudoterminal.open} is called. Task cancellation should be handled using
/// {@link Pseudoterminal.close}. When the task is complete fire
/// {@link Pseudoterminal.onDidClose}.
/// @param callback The callback that will be called when the task is started by a user. Any ${} style variables that
/// were in the task definition will be resolved and passed into the callback as `resolvedDefinition`.
pub fn CustomExecution::new(
  callback : async (TaskDefinition) -> Pseudoterminal,
) -> CustomExecution {
  custom_execution_ffi(definition => {
    @js_async.Promise::from_async(() => {
      callback(TaskDefinition::from_json(definition.cast()))
    })
  })
}

///|
pub fn RunOptions::new(reevaluate_on_rerun? : Bool) -> RunOptions {
  RunOptions::{ reevaluate_on_rerun, }
}

///|
/// Controls whether task variables are re-evaluated on rerun.

///|
fn process_execution_options_to_js(value : ProcessExecutionOptions) -> JsValue {
  process_execution_options_to_js_ffi(
    option_to_js(value.cwd),
    map_string_string_pairs(value.env),
  )
}

///|
fn option_process_execution_options_to_js(
  value : ProcessExecutionOptions?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(options) => process_execution_options_to_js(options)
  }
}

///|
fn shell_quoting_options_to_js(value : ShellQuotingOptions) -> JsValue {
  shell_quoting_options_to_js_ffi(
    option_shell_quoting_escape_to_js(value.escape),
    option_to_js(value.strong),
    option_to_js(value.weak),
  )
}

///|
fn shell_execution_options_to_js(value : ShellExecutionOptions) -> JsValue {
  let shell_quoting = match value.shell_quoting {
    None => JsValue::make(())
    Some(options) => shell_quoting_options_to_js(options)
  }
  shell_execution_options_to_js_ffi(
    option_to_js(value.executable),
    option_to_js(value.shell_args),
    shell_quoting,
    option_to_js(value.cwd),
    map_string_string_pairs(value.env),
  )
}

///|
fn option_shell_execution_options_to_js(
  value : ShellExecutionOptions?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(options) => shell_execution_options_to_js(options)
  }
}

///|
fn shell_quoted_string_to_js(value : ShellQuotedString) -> JsValue {
  shell_quoted_string_to_js_ffi(value.value, value.quoting)
}

///|
fn TaskExecutionValue::to_js(self : TaskExecutionValue) -> JsValue {
  match self {
    ProcessExecutionValue(value) => JsValue::make(value)
    ShellExecutionValue(value) => JsValue::make(value)
    CustomExecutionValue(value) => JsValue::make(value)
  }
}

///|
fn option_task_execution_value_to_js(value : TaskExecutionValue?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
extern "js" fn task_group_clean_ffi() -> TaskGroup =
  #| () => require("vscode").TaskGroup.Clean

///|
extern "js" fn task_group_build_ffi() -> TaskGroup =
  #| () => require("vscode").TaskGroup.Build

///|
extern "js" fn task_group_rebuild_ffi() -> TaskGroup =
  #| () => require("vscode").TaskGroup.Rebuild

///|
extern "js" fn task_group_test_ffi() -> TaskGroup =
  #| () => require("vscode").TaskGroup.Test

///|
extern "js" fn task_definition_ffi(
  type_ : String,
  entries : JsValue,
) -> JsValue =
  #| (type, entries) => {
  #|   const definition = { type };
  #|   if (entries !== undefined && entries !== null) {
  #|     for (const entry of entries) {
  #|       const key = entry._0 ?? entry[0];
  #|       const value = entry._1 ?? entry[1];
  #|       definition[key] = value;
  #|     }
  #|   }
  #|   return definition;
  #| }

///|
extern "js" fn task_new_ffi(
  definition : JsValue,
  scope : JsValue,
  name : String,
  source : String,
  execution : JsValue,
  problem_matchers : JsValue,
) -> Task =
  #| (definition, scope, name, source, execution, problemMatchers) =>
  #|   new (require("vscode").Task)(
  #|     definition,
  #|     scope,
  #|     name,
  #|     source,
  #|     execution === undefined || execution === null ? undefined : execution,
  #|     problemMatchers === undefined || problemMatchers === null ? undefined : problemMatchers
  #|   )

///|
extern "js" fn process_execution_options_to_js_ffi(
  cwd : JsValue,
  env : JsValue,
) -> JsValue =
  #| (cwd, env) => {
  #|   const options = {};
  #|   if (cwd !== undefined && cwd !== null) options.cwd = cwd;
  #|   if (env !== undefined && env !== null) options.env = env;
  #|   return options;
  #| }

///|
extern "js" fn process_execution_new_ffi(
  process : String,
  options : JsValue,
) -> ProcessExecution =
  #| (process, options) =>
  #|   new (require("vscode").ProcessExecution)(
  #|     process,
  #|     options === undefined || options === null ? undefined : options
  #|   )

///|
extern "js" fn process_execution_new_with_args_ffi(
  process : String,
  args : Array[String],
  options : JsValue,
) -> ProcessExecution =
  #| (process, args, options) =>
  #|   new (require("vscode").ProcessExecution)(
  #|     process,
  #|     args,
  #|     options === undefined || options === null ? undefined : options
  #|   )

///|
extern "js" fn process_execution_options_raw(
  value : ProcessExecution,
) -> JsValue =
  #| (value) => value.options

///|
extern "js" fn process_execution_options_env_raw(value : JsValue) -> JsValue =
  #| (value) => value.env

///|
extern "js" fn process_execution_options_cwd_raw(value : JsValue) -> JsValue =
  #| (value) => value.cwd

///|
extern "js" fn shell_quoting_escape_ffi(
  escape_char : String,
  chars_to_escape : String,
) -> JsValue =
  #| (escapeChar, charsToEscape) => ({ escapeChar, charsToEscape })

///|
extern "js" fn shell_quoting_options_to_js_ffi(
  escape : JsValue,
  strong : JsValue,
  weak : JsValue,
) -> JsValue =
  #| (escape, strong, weak) => {
  #|   const options = {};
  #|   if (escape !== undefined && escape !== null) options.escape = escape;
  #|   if (strong !== undefined && strong !== null) options.strong = strong;
  #|   if (weak !== undefined && weak !== null) options.weak = weak;
  #|   return options;
  #| }

///|
extern "js" fn shell_execution_options_to_js_ffi(
  executable : JsValue,
  shell_args : JsValue,
  shell_quoting : JsValue,
  cwd : JsValue,
  env : JsValue,
) -> JsValue =
  #| (executable, shellArgs, shellQuoting, cwd, env) => {
  #|   const options = {};
  #|   if (executable !== undefined && executable !== null) options.executable = executable;
  #|   if (shellArgs !== undefined && shellArgs !== null) options.shellArgs = shellArgs;
  #|   if (shellQuoting !== undefined && shellQuoting !== null) options.shellQuoting = shellQuoting;
  #|   if (cwd !== undefined && cwd !== null) options.cwd = cwd;
  #|   if (env !== undefined && env !== null) options.env = env;
  #|   return options;
  #| }

///|
extern "js" fn shell_quoted_string_to_js_ffi(
  value : String,
  quoting : ShellQuoting,
) -> JsValue =
  #| (value, quoting) => ({ value, quoting })

///|
extern "js" fn shell_execution_new_command_line_ffi(
  command_line : String,
  options : JsValue,
) -> ShellExecution =
  #| (commandLine, options) =>
  #|   new (require("vscode").ShellExecution)(
  #|     commandLine,
  #|     options === undefined || options === null ? undefined : options
  #|   )

///|
extern "js" fn shell_execution_new_command_ffi(
  command : JsValue,
  args : Array[JsValue],
  options : JsValue,
) -> ShellExecution =
  #| (command, args, options) =>
  #|   new (require("vscode").ShellExecution)(
  #|     command,
  #|     args,
  #|     options === undefined || options === null ? undefined : options
  #|   )

///|
extern "js" fn shell_execution_command_line_raw(
  value : ShellExecution,
) -> JsValue =
  #| (value) => value.commandLine

///|
extern "js" fn shell_execution_command_raw(value : ShellExecution) -> JsValue =
  #| (value) => value.command

///|
extern "js" fn shell_execution_args_raw(value : ShellExecution) -> JsValue =
  #| (value) => value.args

///|
extern "js" fn shell_execution_options_raw(value : ShellExecution) -> JsValue =
  #| (value) => value.options

///|
extern "js" fn task_js_value_is_string_ffi(value : JsValue) -> Bool =
  #| (value) => typeof value === "string"

///|
extern "js" fn task_js_value_array_ffi(value : JsValue) -> Array[JsValue] =
  #| (value) => value

///|
extern "js" fn custom_execution_ffi(
  callback : (JsValue) -> @js_async.Promise[Pseudoterminal],
) -> CustomExecution =
  #| (callback) => new (require("vscode").CustomExecution)((resolvedDefinition) => callback(resolvedDefinition))

///|
extern "js" fn task_string_map_ffi(
  entries : Array[(String, String)],
) -> JsValue =
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
extern "js" fn task_string_map_to_pairs_ffi(
  value : JsValue,
) -> Array[(String, String)] =
  #| (value) => {
  #|   if (value === undefined || value === null) {
  #|     return [];
  #|   }
  #|   return Object.entries(value);
  #| }

///|
fn map_string_string_pairs(values : Array[(String, String)]?) -> JsValue {
  match values {
    None => JsValue::make(())
    Some(entries) => task_string_map_ffi(entries)
  }
}
