///|
/// JS entrypoint for l10n namespace binding checks.

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-l10n-fixture")
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
async fn run_check_l10n(root : @vscode.Uri) -> Unit {
  let message = @l10n.t("moonbit l10n check")
  let positional = @l10n.t_args("moonbit l10n args {0}", [@vscode.Any::from("ok")])
  let named = @l10n.t_named(
    "moonbit l10n named {name}",
    [("name", @vscode.Any::from("ok"))],
  )

  let has_bundle = match @l10n.bundle() {
    Some(_) => "true"
    None => "false"
  }

  let has_uri = match @l10n.uri() {
    Some(value) => value.to_string()
    None => ""
  }

  write_result(
    root,
    "l10n-result.txt",
    "l10n ok message=\{message} positional=\{positional} named=\{named} has_bundle=\{has_bundle} uri=\{has_uri}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.l10n.checkBindings",
    async fn(_args) {
      run_check_l10n(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
