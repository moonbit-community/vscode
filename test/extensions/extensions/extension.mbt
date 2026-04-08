///|
/// JS entrypoint for extensions namespace binding checks.

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
    _ => @vscode.Uri::file("/tmp/moonbit-extensions-fixture")
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
async fn run_check_extensions(root : @vscode.Uri) -> Unit {
  let all_extensions = @extensions.all()
  let self_extension : @vscode.Extension[Unit]? = @extensions.get_extension(
    "moonbit.extensions-test",
  )
  let self_extension_state = match self_extension {
    Some(extension) => "some:\{extension.id()}"
    None => "none"
  }
  let changed = @extensions.on_did_change().subscribe(_ => ())
  changed.dispose()

  let controller = @extensions.create_comment_controller(
    fresh_id("moonbit-extensions-comments"),
    "MoonBit Extensions Comments",
  )
  controller.dispose()

  write_result(
    root,
    "extensions-result.txt",
    "extensions ok all=\{all_extensions.length()} self=\{self_extension_state}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.extensions.checkBindings",
    async fn(_args) {
      run_check_extensions(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
