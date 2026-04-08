///|
/// MoonBit port of `nodefs-provider-sample`.
priv struct NoopDisposable {}

impl @vscode.Disposable for NoopDisposable with dispose(_self) {
  ()
}

priv struct NodeFsProvider {
  changes : @vscode.EventEmitter[Array[@vscode.FileChangeEvent]]
}

fn normalize_path(path : String) -> String {
  if path == "" {
    "/"
  } else {
    path
  }
}

fn to_file_uri(uri : @vscode.Uri) -> @vscode.Uri {
  @vscode.Uri::file(normalize_path(uri.path()))
}

impl @vscode.FileSystemProvider for NodeFsProvider with on_did_change_file(self) {
  self.changes.event()
}

impl @vscode.FileSystemProvider for NodeFsProvider with watch(
  _self,
  _uri,
  _recursive,
  _excludes,
) {
  NoopDisposable::{}
}

impl @vscode.FileSystemProvider for NodeFsProvider with stat(_self, uri) {
  @workspace.fs().stat(to_file_uri(uri))
}

impl @vscode.FileSystemProvider for NodeFsProvider with read_directory(_self, uri) {
  @workspace.fs().read_directory(to_file_uri(uri))
}

impl @vscode.FileSystemProvider for NodeFsProvider with create_directory(_self, uri) {
  @workspace.fs().create_directory(to_file_uri(uri))
}

impl @vscode.FileSystemProvider for NodeFsProvider with read_file(_self, uri) {
  @workspace.fs().read_file(to_file_uri(uri))
}

impl @vscode.FileSystemProvider for NodeFsProvider with write_file(
  _self,
  uri,
  content,
  _create,
  _overwrite,
) {
  @workspace.fs().write_file(to_file_uri(uri), content)
}

impl @vscode.FileSystemProvider for NodeFsProvider with delete(
  _self,
  uri,
  recursive,
) {
  @workspace.fs().delete(to_file_uri(uri), recursive=recursive)
}

impl @vscode.FileSystemProvider for NodeFsProvider with rename(
  _self,
  old_uri,
  new_uri,
  overwrite,
) {
  @workspace.fs().rename(to_file_uri(old_uri), to_file_uri(new_uri), overwrite=overwrite)
}

impl @vscode.FileSystemProvider for NodeFsProvider with copy(
  _self,
  source,
  destination,
  overwrite,
) {
  @workspace.fs().copy(
    to_file_uri(source),
    to_file_uri(destination),
    overwrite=overwrite,
  )
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  subscriptions.push(
    @workspace.register_file_system_provider(
      "datei",
      NodeFsProvider::{
        changes: @vscode.EventEmitter::new(),
      },
      is_case_sensitive=true,
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
