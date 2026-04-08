///|
/// JS entrypoint for scm namespace binding checks.

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
    _ => @vscode.Uri::file("/tmp/moonbit-scm-fixture")
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
async fn run_check_scm(root : @vscode.Uri) -> Unit {
  match @scm.input_box() {
    Some(input) => input.set_value("moonbit-scm")
    None => ()
  }

  let source = @scm.create_source_control(
    fresh_id("moonbit-scm"),
    "MoonBit SCM",
  )
  source.input_box().set_value("moonbit-scm-source")
  let group = source.create_resource_group("changes", "Changes")
  group.dispose()
  source.dispose()

  let with_root = @scm.create_source_control(
    fresh_id("moonbit-scm-root"),
    "MoonBit SCM Root",
    root_uri=root,
  )
  with_root.dispose()

  write_result(
    root,
    "scm-result.txt",
    "scm ok",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.scm.checkBindings",
    async fn(_args) {
      run_check_scm(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
