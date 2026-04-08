///|
/// VS Code tasks namespace bindings for the JS backend.
using @vscode {
  type Event,
  type Task,
  type TaskEndEvent,
  type TaskExecution,
  type TaskFilter,
  type TaskProcessEndEvent,
  type TaskProcessStartEvent,
  type TaskStartEvent,
}

///|
fn[T : @vscode.TaskProvider] task_provider_object(
  provider : T,
) -> @providers.TaskProviderObject {
  @providers.TaskProviderObject::new(
    async fn(token) { provider.provide_tasks(token) },
    resolve_task=async fn(task, token) { provider.resolve_task(task, token) },
  )
}

///|
/// Register a task provider.
///
/// @param type The task kind type this provider is registered for.
/// @param provider A task provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.TaskProvider] register_task_provider(
  type_ : String,
  provider : T,
) -> &@vscode.Disposable {
  tasks_register_task_provider_ffi(type_, task_provider_object(provider))
}

///|
/// Fetches all tasks available in the systems. This includes tasks
/// from `tasks.json` files as well as tasks from task providers
/// contributed through extensions.
///
/// @param filter Optional filter to select tasks of a certain type or version.
/// @returns A thenable that resolves to an array of tasks.
pub async fn fetch_tasks(filter? : TaskFilter) -> Array[Task] {
  @js_async.Promise::wait(tasks_fetch_tasks_ffi(@v.option_to_js(filter)))
}

///|
/// Executes a task that is managed by the editor. The returned
/// task execution can be used to terminate the task.
///
/// @throws When running a ShellExecution or a ProcessExecution
/// task in an environment where a new process cannot be started.
/// In such an environment, only CustomExecution tasks can be run.
///
/// @param task the task to execute
/// @returns A thenable that resolves to a task execution.
pub async fn execute_task(task : Task) -> TaskExecution {
  @js_async.Promise::wait(tasks_execute_task_ffi(task))
}

///|
/// The currently active task executions or an empty array.
pub fn task_executions() -> Array[TaskExecution] {
  tasks_task_executions_ffi()
}

///|
/// Fires when a task starts.
pub fn on_did_start_task() -> Event[TaskStartEvent] {
  tasks_on_did_start_task_ffi()
}

///|
/// Fires when a task ends.
pub fn on_did_end_task() -> Event[TaskEndEvent] {
  tasks_on_did_end_task_ffi()
}

///|
/// Fires when the underlying process has been started.
/// This event will not fire for tasks that don't
/// execute an underlying process.
pub fn on_did_start_task_process() -> Event[TaskProcessStartEvent] {
  tasks_on_did_start_task_process_ffi()
}

///|
/// Fires when the underlying process has ended.
/// This event will not fire for tasks that don't
/// execute an underlying process.
pub fn on_did_end_task_process() -> Event[TaskProcessEndEvent] {
  tasks_on_did_end_task_process_ffi()
}
