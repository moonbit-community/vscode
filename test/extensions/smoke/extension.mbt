///|
let echo_command = "vscode-mbt-tests.echo"

///|
let has_command_command = "vscode-mbt-tests.hasCommand"

///|
let status_bar_command = "vscode-mbt-tests.statusBar"

///|
let workspace_edit_command = "vscode-mbt-tests.workspaceEdit"

///|
fn echo(args : @commands.CommandArgs) -> String {
  let value : String? = args.get(0)
  match value {
    Some(value) => "moonbit:\{value}"
    None => "moonbit:"
  }
}

///|
async fn has_command(args : @commands.CommandArgs) -> Bool {
  let command : String? = args.get(0)
  match command {
    Some(command) => @commands.get_commands_contains(command)
    None => false
  }
}

///|
fn status_bar_value(item : @vscode.StatusBarItem) -> String {
  item.set_text("MoonBit binding smoke")
  item.show()
  "\{item.id()}|\{item.text()}"
}

///|
async fn apply_workspace_edit(args : @commands.CommandArgs) -> String {
  let path : String? = args.get(0)
  match path {
    None => "missing path"
    Some(path) => {
      let document = @workspace.open_text_document_path(path)
      let edit = @vscode.WorkspaceEdit::new()
      edit.insert(document.uri(), @vscode.Position::new(0, 0), "moonbit:")
      let applied = @workspace.apply_edit(edit)
      if applied {
        document.get_text()
      } else {
        "apply_edit:false"
      }
    }
  }
}

///|
pub fn activate(_ctx : @vscode.ExtensionContext) -> Unit {
  let status = @window.create_status_bar_item_with_id(
    "vscode-mbt-tests.status",
    alignment=@vscode.StatusBarAlignment::Left,
    priority=100,
  )
  ignore(@commands.register_command(echo_command, echo))
  ignore(@commands.register_command_async(has_command_command, has_command))
  ignore(
    @commands.register_command(status_bar_command, fn(_args) {
      status_bar_value(status)
    }),
  )
  ignore(
    @commands.register_command_async(workspace_edit_command, apply_workspace_edit),
  )
}

///|
pub fn deactivate() -> Unit {
  ()
}
