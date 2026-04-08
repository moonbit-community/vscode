///|
/// JS entrypoint for tasks namespace binding checks.

///|
priv struct State {
  mut next_id : Int
}

///|
let state : State = { next_id: 0 }

///|
fn fresh_id(prefix : String) -> String {
  let id = state.next_id
  state.next_id = id + 1
  "\{prefix}-\{id}"
}

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-tasks-fixture")
  }
}

///|
fn fixture_uri(root : @vscode.Uri, name : String) -> @vscode.Uri {
  @vscode.Uri::join_path(root, [name])
}

///|
async fn write_result(
  root : @vscode.Uri,
  name : String,
  content : String,
) -> Unit {
  let fs = @workspace.fs()
  fs.write_file(fixture_uri(root, name), @workspace.encode(content))
}

///|
priv struct FixtureTaskProvider {}

///|
impl @vscode.TaskProvider for FixtureTaskProvider with provide_tasks(
  _self,
  _token,
) {
  Some([])
}

///|
impl @vscode.TaskProvider for FixtureTaskProvider with resolve_task(
  _self,
  task,
  _token,
) {
  Some(task)
}

///|
async fn run_check_tasks(root : @vscode.Uri) -> Unit {
  let provider_type = fresh_id("moonbit-tasks-provider")
  let provider = FixtureTaskProvider::{  }
  let registration = @tasks.register_task_provider(
    provider_type,
    provider,
  )
  let all_tasks = @tasks.fetch_tasks()
  let filtered_tasks = @tasks.fetch_tasks(
    filter=@vscode.TaskFilter::new(type_=provider_type),
  )
  let running = @tasks.task_executions()
  let start_task_event = @tasks.on_did_start_task().subscribe(_ => ())
  let end_task_event = @tasks.on_did_end_task().subscribe(_ => ())
  let start_task_process_event = @tasks.on_did_start_task_process().subscribe(_ => ())
  let end_task_process_event = @tasks.on_did_end_task_process().subscribe(_ => ())

  let process_options = @vscode.ProcessExecutionOptions::new(
    cwd="/tmp",
    env=[("MOONBIT_TASK_BINDING", "1")],
  )
  let process_execution = @vscode.ProcessExecution::new_with_args(
    "echo",
    ["moonbit-task"],
    options=process_options,
  )
  let process_env_count = match process_execution.options() {
    Some(options) => match options.env {
      Some(env_entries) => env_entries.length()
      None => 0
    }
    None => 0
  }

  let shell_quoted = @vscode.ShellQuotedString::new(
    "moonbit shell arg",
    @vscode.ShellQuoting::Strong,
  )
  let shell_options = @vscode.ShellExecutionOptions::new(
    executable="bash",
    shell_args=["-lc"],
    shell_quoting=@vscode.ShellQuotingOptions::new(
      escape=@vscode.ShellQuotingEscape::EscapeChars(("\\", " ")),
      strong="'",
      weak="\"",
    ),
    cwd="/tmp",
    env=[("MOONBIT_SHELL_BINDING", "1")],
  )
  let shell_execution = @vscode.ShellExecution::new_command(
    @vscode.StringOrShellQuotedString::Text("echo"),
    [
      @vscode.StringOrShellQuotedString::Quoted(shell_quoted),
    ],
    options=shell_options,
  )

  let output_emitter : @vscode.EventEmitter[String] = @vscode.EventEmitter::new()
  let pty = @vscode.Pseudoterminal::new(
    output_emitter.event(),
    _ => (),
    () => (),
  )
  let custom_execution = @vscode.CustomExecution::new(
    fn(_resolved_definition) {
      pty
    },
  )
  output_emitter.dispose()

  let task = @vscode.Task::new_typed(
    @vscode.TaskDefinition::new("moonbit-task-definition"),
    @vscode.TaskScope::ScopeKind(@vscode.TaskScopeKind::Workspace),
    "MoonBit Task Typed",
    "moonbit",
    execution=@vscode.TaskExecutionValue::ProcessExecutionValue(process_execution),
  )
  task.set_presentation_options(@vscode.TaskPresentationOptions::new(
      reveal=@vscode.TaskRevealKind::Silent,
      panel=@vscode.TaskPanelKind::Dedicated,
      show_reuse_message=true,
      clear=true,
    ))
  task.set_run_options(@vscode.RunOptions::new(reevaluate_on_rerun=true))
  let reveal_kind = match task.presentation_options().reveal {
    Some(value) => value
    None => @vscode.TaskRevealKind::Always
  }
  let reveal_text = match reveal_kind {
    @vscode.TaskRevealKind::Always => "always"
    @vscode.TaskRevealKind::Silent => "silent"
    @vscode.TaskRevealKind::Never => "never"
  }
  let run_reevaluate = match task.run_options().reevaluate_on_rerun {
    Some(value) => value
    None => false
  }
  let shell_args_count = match shell_execution.args() {
    Some(args) => args.length()
    None => 0
  }
  let rerun_text = if run_reevaluate {
    "true"
  } else {
    "false"
  }

  let typed_task_shell = @vscode.Task::new_typed(
    @vscode.TaskDefinition::new("moonbit-shell-task-definition"),
    @vscode.TaskScope::ScopeKind(@vscode.TaskScopeKind::Workspace),
    "MoonBit Shell Task",
    "moonbit",
    execution=@vscode.TaskExecutionValue::ShellExecutionValue(shell_execution),
  )
  let typed_task_custom = @vscode.Task::new_typed(
    @vscode.TaskDefinition::new("moonbit-custom-task-definition"),
    @vscode.TaskScope::ScopeKind(@vscode.TaskScopeKind::Workspace),
    "MoonBit Custom Task",
    "moonbit",
    execution=@vscode.TaskExecutionValue::CustomExecutionValue(custom_execution),
  )
  let execute_state = try {
    let execution = @tasks.execute_task(task)
    let task_name = execution.task().name()
    execution.terminate()
    "ok:\{task_name}"
  } catch {
    _ => "error"
  }

  end_task_process_event.dispose()
  start_task_process_event.dispose()
  end_task_event.dispose()
  start_task_event.dispose()
  registration.dispose()

  write_result(
    root,
    "tasks-result.txt",
    "tasks ok all=\{all_tasks.length()} filtered=\{filtered_tasks.length()} running=\{running.length()} execute=\{execute_state} process=\{process_execution.process()} env=\{process_env_count} shell_args=\{shell_args_count} reveal=\{reveal_text} rerun=\{rerun_text} typed_names=\{typed_task_shell.name()}+\{typed_task_custom.name()}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.tasks.checkBindings",
    async fn(_args) {
      run_check_tasks(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
