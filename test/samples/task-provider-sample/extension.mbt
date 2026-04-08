///|
/// MoonBit port of `task-provider-sample`.
fn workspace_root_folder() -> @vscode.WorkspaceFolder? {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => Some(folder)
    _ => None
  }
}

fn make_shell_task(
  folder : @vscode.WorkspaceFolder,
  task_type : String,
  name : String,
  command_line : String,
) -> @vscode.Task {
  @vscode.Task::new_typed(
    @vscode.TaskDefinition::new(task_type),
    @vscode.TaskScope::WorkspaceFolderScope(folder),
    name,
    "moonbit",
    execution=@vscode.TaskExecutionValue::ShellExecutionValue(
      @vscode.ShellExecution::new_command_line(command_line),
    ),
  )
}

priv struct RakeTaskProvider {
  folder : @vscode.WorkspaceFolder
}

impl @vscode.TaskProvider for RakeTaskProvider with provide_tasks(
  self,
  _token,
) {
  Some([
    make_shell_task(self.folder, "rake", "rake build", "echo rake build"),
    make_shell_task(self.folder, "rake", "rake test", "echo rake test"),
  ])
}

impl @vscode.TaskProvider for RakeTaskProvider with resolve_task(
  _self,
  _task,
  _token,
) {
  None
}

priv struct CustomTaskProvider {
  folder : @vscode.WorkspaceFolder
}

impl @vscode.TaskProvider for CustomTaskProvider with provide_tasks(
  self,
  _token,
) {
  Some([
    make_shell_task(
      self.folder,
      "custombuildscript",
      "custom build",
      "echo custom build",
    ),
  ])
}

impl @vscode.TaskProvider for CustomTaskProvider with resolve_task(
  _self,
  _task,
  _token,
) {
  None
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  match workspace_root_folder() {
    None => ()
    Some(folder) => {
      let rake_provider : RakeTaskProvider = { folder, }
      subscriptions.push(@tasks.register_task_provider("rake", rake_provider))

      let custom_provider : CustomTaskProvider = { folder, }
      subscriptions.push(
        @tasks.register_task_provider("custombuildscript", custom_provider),
      )
    }
  }
}

pub fn deactivate() -> Unit {
  ()
}
