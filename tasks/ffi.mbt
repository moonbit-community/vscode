///|
/// JS FFI bindings for VS Code tasks namespace.

///|
extern "js" fn tasks_register_task_provider_ffi(
  type_ : String,
  provider : @providers.TaskProviderObject,
) -> &@vscode.Disposable =
  #| (type, provider) => require("vscode").tasks.registerTaskProvider(type, provider)

///|
extern "js" fn tasks_fetch_tasks_ffi(
  filter : @v.JsValue,
) -> @js_async.Promise[Array[Task]] =
  #| (filter) => {
  #|   const tasks = require("vscode").tasks;
  #|   return filter === undefined || filter === null
  #|     ? tasks.fetchTasks()
  #|     : tasks.fetchTasks(filter);
  #| }

///|
extern "js" fn tasks_execute_task_ffi(
  task : Task,
) -> @js_async.Promise[TaskExecution] =
  #| (task) => require("vscode").tasks.executeTask(task)

///|
extern "js" fn tasks_task_executions_ffi() -> Array[TaskExecution] =
  #| () => require("vscode").tasks.taskExecutions

///|
extern "js" fn tasks_on_did_start_task_ffi() -> Event[TaskStartEvent] =
  #| () => require("vscode").tasks.onDidStartTask

///|
extern "js" fn tasks_on_did_end_task_ffi() -> Event[TaskEndEvent] =
  #| () => require("vscode").tasks.onDidEndTask

///|
extern "js" fn tasks_on_did_start_task_process_ffi() -> Event[
  TaskProcessStartEvent,
] =
  #| () => require("vscode").tasks.onDidStartTaskProcess

///|
extern "js" fn tasks_on_did_end_task_process_ffi() -> Event[TaskProcessEndEvent] =
  #| () => require("vscode").tasks.onDidEndTaskProcess
