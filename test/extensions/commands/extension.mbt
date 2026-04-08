///|
/// JS entrypoint for the VS Code extension host.

///|
priv struct CommandState {
  mut status : @vscode.StatusBarItem?
}

///|
let command_state : CommandState = {
  status: None,
}

///|
fn status_item() -> @vscode.StatusBarItem {
  match command_state.status {
    Some(item) => item
    None => {
      let item = @window.create_status_bar_item(
        alignment=@vscode.StatusBarAlignment::Left,
        priority=210,
      )
      command_state.status = Some(item)
      item
    }
  }
}

///|
fn set_status(text : String) -> Unit {
  let item = status_item()
  item.set_text(text)
  item.show()
}

///|
fn use_command_args_helpers() -> Unit {
  let empty_args = @commands.command_args()
  let one_arg = @commands.command_args1("moonbit")
  let two_args = @commands.command_args2("moon", "bit")
  let three_args = @commands.command_args3("moon", "bit", "mbt")
  let from_array = @commands.command_args_from_array(["x", "y"])
  ignore(empty_args.length())
  ignore(one_arg.length())
  ignore(two_args.length())
  ignore(three_args.length())
  ignore(from_array.length())
}

///|
async fn open_editor() -> Unit {
  let root = match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp")
  }
  let uri = @vscode.Uri::join_path(root, ["moonbit-commands-editor.txt"])
  @workspace.fs().write_file(uri, @workspace.encode("MoonBit command editor ok\n"))
  let doc = @workspace.open_text_document_uri(uri, encoding="utf8")
  ignore(@window.show_text_document(doc))
}

///|
async fn run_nested_open_editor() -> Unit {
  let _ : Unit = @commands.execute_command("moonbit.commands.openEditor")
}

///|
async fn mark_commands_ok() -> Unit {
  use_command_args_helpers()
  let commands = @commands.get_commands()
  if commands.length() > 0 {
    set_status("Commands ok")
  } else {
    set_status("No commands")
  }
}

///|
async fn ensure_open_editor_command() -> Unit {
  let ok = @commands.get_commands_contains("moonbit.commands.openEditor")
  if ok {
    set_status("Command exists")
  } else {
    set_status("Command missing")
  }
}

///|
fn show_status_ready() -> Unit {
  set_status("MoonBit commands ready")
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let status_disposable = @commands.register_command(
    "moonbit.commands.showStatus",
    fn(_args) {
      show_status_ready()
    },
  )
  subscriptions.push(status_disposable)

  let editor_disposable = @commands.register_command_async(
    "moonbit.commands.openEditor",
    async fn(_args) {
      open_editor()
    },
  )
  subscriptions.push(editor_disposable)

  let nested_disposable = @commands.register_command_async(
    "moonbit.commands.runNestedOpenEditor",
    async fn(_args) {
      run_nested_open_editor()
    },
  )
  subscriptions.push(nested_disposable)

  let count_disposable = @commands.register_command_async(
    "moonbit.commands.showCommandCount",
    async fn(_args) {
      mark_commands_ok()
    },
  )
  subscriptions.push(count_disposable)

  let exists_disposable = @commands.register_command_async(
    "moonbit.commands.ensureCommand",
    async fn(_args) {
      ensure_open_editor_command()
    },
  )
  subscriptions.push(exists_disposable)

  let edit_disposable = @commands.register_text_editor_command(
    "moonbit.commands.insertText",
    fn(_editor, edit, _args) {
      edit.insert(@vscode.Position::new(0, 0), "MoonBit edit ok\n")
    },
  )
  subscriptions.push(edit_disposable)

  let async_edit_disposable = @commands.register_text_editor_command_async(
    "moonbit.commands.insertTextAsync",
    fn(_editor, edit, _args) {
      edit.insert(@vscode.Position::new(0, 0), "MoonBit async edit ok\n")
    },
  )
  subscriptions.push(async_edit_disposable)
}

///|
pub fn deactivate() -> Unit {
  match command_state.status {
    None => ()
    Some(item) => {
      item.dispose()
      command_state.status = None
    }
  }
}
