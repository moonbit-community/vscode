///|
/// MoonBit port of `fsprovider-sample`.
priv struct NoopDisposable {}

impl @vscode.Disposable for NoopDisposable with dispose(_self) {
  ()
}

priv struct MemFsProvider {
  backing_root : @vscode.Uri
  changes : @vscode.EventEmitter[Array[@vscode.FileChangeEvent]]
}

fn normalize_path(path : String) -> String {
  let mut normalized = path.replace(old="\\", new="/")
  if normalized == "" {
    normalized = "/"
  }
  if !normalized.has_prefix("/") {
    normalized = "/\{normalized}"
  }
  while normalized.length() > 1 && normalized.has_suffix("/") {
    normalized = normalized.unsafe_substring(start=0, end=normalized.length() - 1)
  }
  normalized
}

fn relative_path(path : String) -> String {
  let normalized = normalize_path(path)
  if normalized == "/" {
    ""
  } else {
    normalized.unsafe_substring(start=1, end=normalized.length())
  }
}

fn path_segments(path : String) -> Array[String] {
  let segments : Array[String] = []
  for part in path.split("/") {
    let value = part.to_string()
    if value != "" {
      segments.push(value)
    }
  }
  segments
}

fn backing_uri_for_path(root : @vscode.Uri, path : String) -> @vscode.Uri {
  let relative = relative_path(path)
  if relative == "" {
    root
  } else {
    @vscode.Uri::join_path(root, path_segments(relative))
  }
}

fn default_backing_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => @vscode.Uri::join_path(folder.uri(), [".moonbit-memfs-sample"])
    _ => @vscode.Uri::file("/tmp/moonbit-memfs-sample")
  }
}

async fn ensure_backing_root(root : @vscode.Uri) -> Unit {
  @workspace.fs().create_directory(root)
}

async fn reset_backing_root(root : @vscode.Uri) -> Unit {
  try {
    @workspace.fs().delete(root, recursive=true)
  } catch {
    _ => ()
  }
  @workspace.fs().create_directory(root)
}

async fn write_text_file(uri : @vscode.Uri, content : String) -> Unit {
  @workspace.fs().write_file(uri, @workspace.encode(content))
}

async fn init_backing_files(root : @vscode.Uri) -> Unit {
  reset_backing_root(root)

  write_text_file(backing_uri_for_path(root, "/file.txt"), "foo")
  write_text_file(
    backing_uri_for_path(root, "/file.html"),
    "<html><body><h1>Hello</h1></body></html>",
  )
  write_text_file(backing_uri_for_path(root, "/file.js"), "console.log(\"JavaScript\")")
  write_text_file(backing_uri_for_path(root, "/file.json"), "{ \"json\": true }")
  write_text_file(backing_uri_for_path(root, "/file.ts"), "console.log(\"TypeScript\")")
  write_text_file(backing_uri_for_path(root, "/file.md"), "Hello _World_")

  @workspace.fs().create_directory(backing_uri_for_path(root, "/folder"))
  @workspace.fs().create_directory(backing_uri_for_path(root, "/xyz"))
  @workspace.fs().create_directory(backing_uri_for_path(root, "/xyz/abc"))
  @workspace.fs().create_directory(backing_uri_for_path(root, "/xyz/def"))

  write_text_file(backing_uri_for_path(root, "/folder/file.ts"), "let a:number = true;")
  write_text_file(backing_uri_for_path(root, "/xyz/UPPER.txt"), "UPPER")
  write_text_file(backing_uri_for_path(root, "/xyz/upper.txt"), "upper")
}

fn to_backing_uri(provider : MemFsProvider, uri : @vscode.Uri) -> @vscode.Uri {
  backing_uri_for_path(provider.backing_root, uri.path())
}

impl @vscode.FileSystemProvider for MemFsProvider with on_did_change_file(self) {
  self.changes.event()
}

impl @vscode.FileSystemProvider for MemFsProvider with watch(
  _self,
  _uri,
  _recursive,
  _excludes,
) {
  NoopDisposable::{}
}

impl @vscode.FileSystemProvider for MemFsProvider with stat(self, uri) {
  @workspace.fs().stat(to_backing_uri(self, uri))
}

impl @vscode.FileSystemProvider for MemFsProvider with read_directory(self, uri) {
  @workspace.fs().read_directory(to_backing_uri(self, uri))
}

impl @vscode.FileSystemProvider for MemFsProvider with create_directory(self, uri) {
  @workspace.fs().create_directory(to_backing_uri(self, uri))
}

impl @vscode.FileSystemProvider for MemFsProvider with read_file(self, uri) {
  @workspace.fs().read_file(to_backing_uri(self, uri))
}

impl @vscode.FileSystemProvider for MemFsProvider with write_file(
  self,
  uri,
  content,
  _create,
  _overwrite,
) {
  @workspace.fs().write_file(to_backing_uri(self, uri), content)
}

impl @vscode.FileSystemProvider for MemFsProvider with delete(
  self,
  uri,
  recursive,
) {
  @workspace.fs().delete(to_backing_uri(self, uri), recursive=recursive)
}

impl @vscode.FileSystemProvider for MemFsProvider with rename(
  self,
  old_uri,
  new_uri,
  overwrite,
) {
  @workspace.fs().rename(
    to_backing_uri(self, old_uri),
    to_backing_uri(self, new_uri),
    overwrite=overwrite,
  )
}

impl @vscode.FileSystemProvider for MemFsProvider with copy(
  self,
  source,
  destination,
  overwrite,
) {
  @workspace.fs().copy(
    to_backing_uri(self, source),
    to_backing_uri(self, destination),
    overwrite=overwrite,
  )
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let backing_root = default_backing_root()
  let provider = MemFsProvider::{
    backing_root,
    changes: @vscode.EventEmitter::new(),
  }

  subscriptions.push(
    @workspace.register_file_system_provider(
      "memfs",
      provider,
      is_case_sensitive=true,
    ),
  )

  subscriptions.push(
    @commands.register_command("memfs.workspaceInit", fn(_args) {
      ignore(
        @workspace.update_workspace_folders(
          0,
          delete_count=0,
          folders_to_add=[
            @vscode.WorkspaceFolderInput::new(
              @vscode.Uri::parse("memfs:/"),
              name="MemFS - Sample",
            ),
          ],
        ),
      )
    }),
  )

  subscriptions.push(
    @commands.register_command_async("memfs.init", async fn(_args) {
      init_backing_files(backing_root)
    }),
  )

  subscriptions.push(
    @commands.register_command_async("memfs.reset", async fn(_args) {
      reset_backing_root(backing_root)
    }),
  )

  subscriptions.push(
    @commands.register_command_async("memfs.addFile", async fn(_args) {
      ensure_backing_root(backing_root)
      write_text_file(backing_uri_for_path(backing_root, "/file.txt"), "foo")
    }),
  )

  subscriptions.push(
    @commands.register_command_async("memfs.deleteFile", async fn(_args) {
      try {
        @workspace.fs().delete(
          backing_uri_for_path(backing_root, "/file.txt"),
          recursive=false,
        )
      } catch {
        _ => ()
      }
    }),
  )
}

pub fn deactivate() -> Unit {
  ()
}
