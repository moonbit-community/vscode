///|
let echo_command = "vscode-mbt-tests.echo"

///|
let has_command_command = "vscode-mbt-tests.hasCommand"

///|
let status_bar_command = "vscode-mbt-tests.statusBar"

///|
let workspace_edit_command = "vscode-mbt-tests.workspaceEdit"

///|
let event_command = "vscode-mbt-tests.event"

///|
let content_provider_uri_command = "vscode-mbt-tests.contentProviderUri"

///|
let content_provider_scheme = "vscode-mbt-smoke"

///|
let language_provider_language = "vscode-mbt-smoke-language"

///|
let file_system_provider_uri_command = "vscode-mbt-tests.fileSystemProviderUri"

///|
let file_system_read_directory_command = "vscode-mbt-tests.fileSystemReadDirectory"

///|
let file_system_provider_scheme = "vscode-mbt-fs"

///|
let file_system_file_name = "hello.txt"

///|
let file_system_file_path = "/hello.txt"

///|
let file_system_file_content = "moonbit file system provider"

///|
priv struct SmokeDisposable {
  disposable : @vscode.Disposable
}

///|
priv struct SmokeTextDocumentContentProvider {
}

///|
priv struct SmokeCompletionProvider {
}

///|
priv struct SmokeCodeActionProvider {
}

///|
priv struct SmokeCodeLensProvider {
}

///|
priv struct SmokeDefinitionProvider {
}

///|
priv struct SmokeHoverProvider {
}

///|
priv struct SmokeFileSystemProvider {
  changes : @vscode.EventEmitter[Array[@vscode.FileChangeEvent]]
}

///|
priv struct EventState {
  mut sync_value : String
  mut sync_count : Int
  mut async_value : String
  mut async_count : Int
}

///|
impl @vscode.AsDisposable for SmokeDisposable with as_disposable(self) {
  self.disposable
}

///|
impl @vscode.TextDocumentContentProvider for SmokeTextDocumentContentProvider with on_did_change(
  _self,
) {
  None
}

///|
impl @vscode.TextDocumentContentProvider for SmokeTextDocumentContentProvider with provide_text_document_content(
  _self,
  uri,
  _token,
) {
  "moonbit-provider|\{uri.path()}|\{uri.query()}"
}

///|
impl @vscode.CompletionItemProvider for SmokeCompletionProvider with provide_completion_items(
  _self,
  _document,
  _position,
  _token,
  _context,
) {
  let item = @vscode.CompletionItem::from_text(
    "moonbit-completion",
    kind=@vscode.CompletionItemKind::Function,
  )
  item.set_insert_text(@vscode.StringOrSnippetString::Text("moonbitInserted"))
  item.set_commit_characters([";"])
  Some([item])
}

///|
impl @vscode.CompletionItemProvider for SmokeCompletionProvider with resolve_completion_item(
  _self,
  item,
  _token,
) {
  item.set_documentation(
    @vscode.MarkdownStringValue::Text("resolved by MoonBit"),
  )
  Some(item)
}

///|
impl @vscode.CodeActionProvider for SmokeCodeActionProvider with provide_code_actions(
  _self,
  _document,
  _range,
  _context,
  _token,
) {
  let action = @vscode.CodeAction::new(
    "MoonBit quick fix",
    kind=@vscode.CodeActionKind::QuickFix,
  )
  action.set_is_preferred(true)
  Some([action])
}

///|
impl @vscode.CodeActionProvider for SmokeCodeActionProvider with resolve_code_action(
  _self,
  action,
  _token,
) {
  action.set_command(@vscode.Command::new("Apply MoonBit fix", echo_command))
  Some(action)
}

///|
impl @vscode.CodeLensProvider for SmokeCodeLensProvider with on_did_change_code_lenses(
  _self,
) {
  None
}

///|
impl @vscode.CodeLensProvider for SmokeCodeLensProvider with provide_code_lenses(
  _self,
  _document,
  _token,
) {
  Some([
    @vscode.CodeLens::new(
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 4),
      ),
    ),
  ])
}

///|
impl @vscode.CodeLensProvider for SmokeCodeLensProvider with resolve_code_lens(
  _self,
  lens,
  _token,
) {
  lens.set_command(
    @vscode.Command::new(
      "MoonBit CodeLens",
      echo_command,
      tooltip="resolved by MoonBit",
    ),
  )
  Some(lens)
}

///|
impl @vscode.DefinitionProvider for SmokeDefinitionProvider with provide_definition(
  _self,
  document,
  _position,
  _token,
) {
  Some([
    @vscode.Location::new(
      document.uri(),
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 4),
      ),
    ),
  ])
}

///|
impl @vscode.HoverProvider for SmokeHoverProvider with provide_hover(
  _self,
  _document,
  _position,
  _token,
) {
  Some(
    @vscode.Hover::new_single(
      @vscode.HoverContent::Markdown(
        @vscode.MarkdownString::new(value="hover from MoonBit"),
      ),
      range=@vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 4),
      ),
    ),
  )
}

///|
fn SmokeFileSystemProvider::new() -> SmokeFileSystemProvider {
  SmokeFileSystemProvider::{ changes: @vscode.EventEmitter::new() }
}

///|
fn SmokeFileSystemProvider::is_root(uri : @vscode.Uri) -> Bool {
  let path = uri.path()
  path == "" || path == "/"
}

///|
fn SmokeFileSystemProvider::is_file(uri : @vscode.Uri) -> Bool {
  uri.path() == file_system_file_path
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with on_did_change_file(
  self,
) {
  self.changes.event()
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with watch(
  _self,
  _uri,
  _recursive,
  _excludes,
) {
  write_disposable_marker("fs-watch")
  @vscode.Disposable::new(fn() {
    write_disposable_marker("fs-watch-disposable")
  })
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with stat(
  _self,
  uri,
) {
  if SmokeFileSystemProvider::is_root(uri) {
    @vscode.FileStat::new(@vscode.FileType::Directory, 0, 0, 0)
  } else {
    @vscode.FileStat::new(
      @vscode.FileType::File,
      0,
      0,
      file_system_file_content.length(),
      permissions=@vscode.FilePermission::Readonly,
    )
  }
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with read_directory(
  _self,
  _uri,
) {
  [@vscode.DirectoryEntry::new(file_system_file_name, @vscode.FileType::File)]
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with create_directory(
  _self,
  _uri,
) {
  ()
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with read_file(
  _self,
  uri,
) {
  if SmokeFileSystemProvider::is_file(uri) {
    @workspace.encode(file_system_file_content)
  } else {
    @workspace.encode("")
  }
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with write_file(
  _self,
  _uri,
  _content,
  _create,
  _overwrite,
) {
  ()
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with delete(
  _self,
  _uri,
  _recursive,
) {
  ()
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with rename(
  _self,
  _old_uri,
  _new_uri,
  _overwrite,
) {
  ()
}

///|
impl @vscode.FileSystemProvider for SmokeFileSystemProvider with copy(
  _self,
  _source,
  _destination,
  _overwrite,
) {
  ()
}

///|
fn SmokeDisposable::new(name : String) -> SmokeDisposable {
  SmokeDisposable::{
    disposable: @vscode.Disposable::new(fn() {
      write_disposable_marker(name)
    }),
  }
}

///|
extern "js" fn write_disposable_marker(name : String) -> Unit =
  #| (name) => {
  #|   const marker = process.env.VSCODE_MBT_SMOKE_DISPOSE_MARKER;
  #|   if (marker) {
  #|     require("fs").appendFileSync(marker, `${name}\n`, "utf8");
  #|   }
  #| }

///|
// EventEmitter::fire does not wait for async listeners. Yield one JS turn so
// the subscribe_async callback can finish before the smoke command reports.
extern "js" fn wait_next_tick_ffi() -> @js_async.Promise[Unit] =
  #| () => new Promise(resolve => setTimeout(resolve, 0))

///|
async fn wait_next_tick() -> Unit {
  @js_async.Promise::wait(wait_next_tick_ffi())
}

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
async fn event_behavior(_args : @commands.CommandArgs) -> String {
  let emitter : @vscode.EventEmitter[String] = @vscode.EventEmitter::new()
  let state = EventState::{
    sync_value: "none",
    sync_count: 0,
    async_value: "none",
    async_count: 0,
  }
  let sync_subscription = emitter.event().subscribe(value => {
    state.sync_value = value
    state.sync_count = state.sync_count + 1
  })
  emitter.fire("sync-1")
  sync_subscription.dispose()
  emitter.fire("sync-ignored")
  let async_subscription = emitter.event().subscribe_async(async fn(value) {
    wait_next_tick()
    state.async_value = value
    state.async_count = state.async_count + 1
  })
  emitter.fire("async-1")
  wait_next_tick()
  wait_next_tick()
  async_subscription.dispose()
  emitter.fire("async-ignored")
  wait_next_tick()
  wait_next_tick()
  emitter.dispose()
  "\{state.sync_count}|\{state.sync_value}|\{state.async_count}|\{state.async_value}"
}

///|
fn content_provider_uri(_args : @commands.CommandArgs) -> String {
  "\{content_provider_scheme}:/provider-resource?source=moonbit"
}

///|
fn file_system_provider_uri(_args : @commands.CommandArgs) -> String {
  "\{file_system_provider_scheme}:\{file_system_file_path}"
}

///|
async fn file_system_read_directory(_args : @commands.CommandArgs) -> String {
  let entries = @workspace.fs().read_directory(
    @vscode.Uri::parse("\{file_system_provider_scheme}:/"),
  )
  match entries.get(0) {
    None => "missing"
    Some(entry) => {
      let file_type = if entry.file_type == @vscode.FileType::File {
        "file"
      } else {
        "other"
      }
      "\{entry.name}|\{file_type}"
    }
  }
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let status = @window.create_status_bar_item_with_id(
    "vscode-mbt-tests.status",
    alignment=@vscode.StatusBarAlignment::Left,
    priority=100,
  )
  ctx.subscribe(SmokeDisposable::new("as-disposable"))
  ctx.subscribe(@vscode.Disposable::new(fn() {
    write_disposable_marker("callback-disposable")
  }))
  ctx.subscribe(
    @vscode.Disposable::from([
      @vscode.Disposable::new(fn() {
        write_disposable_marker("combined-callback-disposable")
      }),
      SmokeDisposable::new("combined-as-disposable").as_disposable(),
    ]),
  )
  ctx.subscribe(status)
  ctx.subscribe(@commands.register_command(echo_command, echo))
  ctx.subscribe(@commands.register_command_async(has_command_command, has_command))
  ctx.subscribe(
    @commands.register_command(status_bar_command, fn(_args) {
      status_bar_value(status)
    }),
  )
  ctx.subscribe(
    @commands.register_command_async(workspace_edit_command, apply_workspace_edit),
  )
  ctx.subscribe(@commands.register_command_async(event_command, event_behavior))
  ctx.subscribe(
    @commands.register_command(content_provider_uri_command, content_provider_uri),
  )
  ctx.subscribe(
    @workspace.register_text_document_content_provider(
      content_provider_scheme,
      SmokeTextDocumentContentProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_completion_item_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeCompletionProvider::{},
      trigger_characters=["."],
    ),
  )
  ctx.subscribe(
    @languages.register_code_actions_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeCodeActionProvider::{},
      metadata=@vscode.CodeActionProviderMetadata::new(
        provided_kinds=[@vscode.CodeActionKind::QuickFix],
      ),
    ),
  )
  ctx.subscribe(
    @languages.register_code_lens_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeCodeLensProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_definition_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeDefinitionProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_hover_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeHoverProvider::{},
    ),
  )
  let file_system_provider = SmokeFileSystemProvider::new()
  ctx.subscribe(
    @workspace.register_file_system_provider(
      file_system_provider_scheme,
      file_system_provider,
      is_readonly=true,
    ),
  )
  ctx.subscribe(
    @commands.register_command(
      file_system_provider_uri_command, file_system_provider_uri,
    ),
  )
  ctx.subscribe(
    @commands.register_command_async(
      file_system_read_directory_command, file_system_read_directory,
    ),
  )
}

///|
pub fn deactivate() -> Unit {
  ()
}
