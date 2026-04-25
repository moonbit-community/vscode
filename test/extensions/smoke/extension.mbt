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
let document_formatting_language = "vscode-mbt-smoke-document-formatting"

///|
let range_formatting_language = "vscode-mbt-smoke-range-formatting"

///|
let on_type_formatting_language = "vscode-mbt-smoke-on-type-formatting"

///|
let semantic_tokens_language = "vscode-mbt-smoke-semantic-tokens"

///|
let range_semantic_tokens_language = "vscode-mbt-smoke-range-semantic-tokens"

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
let task_provider_type = "vscode-mbt-smoke-task"

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
priv struct SmokeImplementationProvider {
}

///|
priv struct SmokeTypeDefinitionProvider {
}

///|
priv struct SmokeDeclarationProvider {
}

///|
priv struct SmokeDocumentHighlightProvider {
}

///|
priv struct SmokeDocumentLinkProvider {
}

///|
priv struct SmokeDocumentSymbolProvider {
}

///|
priv struct SmokeWorkspaceSymbolProvider {
}

///|
priv struct SmokeHoverProvider {
}

///|
priv struct SmokeReferenceProvider {
}

///|
priv struct SmokeRenameProvider {
}

///|
priv struct SmokeSignatureHelpProvider {
}

///|
priv struct SmokeDocumentFormattingProvider {
}

///|
priv struct SmokeDocumentColorProvider {
}

///|
priv struct SmokeFoldingRangeProvider {
}

///|
priv struct SmokeInlayHintsProvider {
}

///|
priv struct SmokeInlineValuesProvider {
}

///|
priv struct SmokeDocumentSemanticTokensProvider {
}

///|
priv struct SmokeDocumentRangeSemanticTokensProvider {
}

///|
priv struct SmokeCallHierarchyProvider {
}

///|
priv struct SmokeTypeHierarchyProvider {
}

///|
priv struct SmokeSelectionRangeProvider {
}

///|
priv struct SmokeDocumentRangeFormattingProvider {
}

///|
priv struct SmokeOnTypeFormattingProvider {
}

///|
priv struct SmokeTaskProvider {
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
impl @vscode.ImplementationProvider for SmokeImplementationProvider with provide_implementation(
  _self,
  document,
  _position,
  _token,
) {
  Some([
    @vscode.Location::new(
      document.uri(),
      @vscode.Range::new(
        @vscode.Position::new(0, 5),
        @vscode.Position::new(0, 19),
      ),
    ),
  ])
}

///|
impl @vscode.TypeDefinitionProvider for SmokeTypeDefinitionProvider with provide_type_definition(
  _self,
  document,
  _position,
  _token,
) {
  Some([
    @vscode.Location::new(
      document.uri(),
      @vscode.Range::new(
        @vscode.Position::new(0, 5),
        @vscode.Position::new(0, 19),
      ),
    ),
  ])
}

///|
impl @vscode.DeclarationProvider for SmokeDeclarationProvider with provide_declaration(
  _self,
  document,
  _position,
  _token,
) {
  Some([
    @vscode.Location::new(
      document.uri(),
      @vscode.Range::new(
        @vscode.Position::new(0, 5),
        @vscode.Position::new(0, 16),
      ),
    ),
  ])
}

///|
impl @vscode.DocumentHighlightProvider for SmokeDocumentHighlightProvider with provide_document_highlights(
  _self,
  _document,
  _position,
  _token,
) {
  Some([
    @vscode.DocumentHighlight::new(
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 4),
      ),
      kind=@vscode.DocumentHighlightKind::Write,
    ),
  ])
}

///|
impl @vscode.DocumentLinkProvider for SmokeDocumentLinkProvider with provide_document_links(
  _self,
  _document,
  _token,
) {
  Some([
    @vscode.DocumentLink::new(
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 4),
      ),
    ),
  ])
}

///|
impl @vscode.DocumentLinkProvider for SmokeDocumentLinkProvider with resolve_document_link(
  _self,
  link,
  _token,
) {
  link.set_target(@vscode.Uri::parse("https://example.com/moonbit"))
  link.set_tooltip("MoonBit link")
  Some(link)
}

///|
impl @vscode.DocumentSymbolProvider for SmokeDocumentSymbolProvider with provide_document_symbols(
  _self,
  _document,
  _token,
) {
  Some([
    @vscode.DocumentSymbol::new(
      "moonSymbol",
      "MoonBit symbol detail",
      @vscode.SymbolKind::Function,
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 10),
      ),
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 4),
      ),
    ),
  ])
}

///|
impl @vscode.WorkspaceSymbolProvider for SmokeWorkspaceSymbolProvider with provide_workspace_symbols(
  _self,
  query,
  _token,
) {
  if query == "moon" {
    Some([
      @vscode.SymbolInformation::new(
        "moonWorkspaceSymbol",
        @vscode.SymbolKind::Function,
        "MoonBit container",
        @vscode.Location::new(
          @vscode.Uri::parse("file:///moonbit-workspace-symbol.mbt"),
          @vscode.Range::new(
            @vscode.Position::new(0, 0),
            @vscode.Position::new(0, 4),
          ),
        ),
      ),
    ])
  } else {
    Some([])
  }
}

///|
impl @vscode.WorkspaceSymbolProvider for SmokeWorkspaceSymbolProvider with resolve_workspace_symbol(
  _self,
  symbol,
  _token,
) {
  Some(symbol)
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
impl @vscode.ReferenceProvider for SmokeReferenceProvider with provide_references(
  _self,
  document,
  _position,
  _context,
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
impl @vscode.RenameProvider for SmokeRenameProvider with provide_rename_edits(
  _self,
  document,
  _position,
  new_name,
  _token,
) {
  let edit = @vscode.WorkspaceEdit::new()
  edit.replace(
    document.uri(),
    @vscode.Range::new(
      @vscode.Position::new(0, 0),
      @vscode.Position::new(0, 4),
    ),
    new_name,
  )
  Some(edit)
}

///|
impl @vscode.RenameProvider for SmokeRenameProvider with prepare_rename(
  _self,
  _document,
  _position,
  _token,
) {
  Some(
    @vscode.Range::new(
      @vscode.Position::new(0, 0),
      @vscode.Position::new(0, 4),
    ),
  )
}

///|
impl @vscode.SignatureHelpProvider for SmokeSignatureHelpProvider with provide_signature_help(
  _self,
  _document,
  _position,
  _token,
  _context,
) {
  let signature = @vscode.SignatureInformation::new(
    "moon(value: String)",
    documentation=@vscode.MarkdownStringValue::Text("signature from MoonBit"),
  )
  signature.set_parameters([
    @vscode.ParameterInformation::new(
      @vscode.ParameterLabel::Text("value"),
      documentation=@vscode.MarkdownStringValue::Text("parameter from MoonBit"),
    ),
  ])
  signature.set_active_parameter(0)
  let help = @vscode.SignatureHelp::new()
  help.set_signatures([signature])
  help.set_active_signature(0)
  help.set_active_parameter(0)
  Some(help)
}

///|
impl @vscode.DocumentFormattingEditProvider for SmokeDocumentFormattingProvider with provide_document_formatting_edits(
  _self,
  _document,
  options,
  _token,
) {
  let indent = if options.insert_spaces { "spaces" } else { "tabs" }
  Some([
    @vscode.TextEdit::insert(
      @vscode.Position::new(0, 0),
      "doc:\{options.tab_size}:\{indent}:",
    ),
  ])
}

///|
impl @vscode.DocumentColorProvider for SmokeDocumentColorProvider with provide_document_colors(
  _self,
  _document,
  _token,
) {
  Some([
    @vscode.ColorInformation::new(
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 7),
      ),
      @vscode.Color::new(0.1, 0.2, 0.3, 0.4),
    ),
  ])
}

///|
impl @vscode.DocumentColorProvider for SmokeDocumentColorProvider with provide_color_presentations(
  _self,
  _color,
  context,
  _token,
) {
  let presentation = @vscode.ColorPresentation::new("moon-color")
  presentation.set_text_edit(@vscode.TextEdit::replace(context.range, "#123456"))
  presentation.set_additional_text_edits([
    @vscode.TextEdit::insert(@vscode.Position::new(0, 7), " from MoonBit"),
  ])
  Some([presentation])
}

///|
impl @vscode.InlayHintsProvider for SmokeInlayHintsProvider with provide_inlay_hints(
  _self,
  _document,
  range,
  _token,
) {
  Some([
    @vscode.InlayHint::new(
      range.start(),
      @vscode.InlayHintLabelValue::Text(": MoonBit"),
      kind=@vscode.InlayHintKind::Type,
    ),
  ])
}

///|
impl @vscode.InlayHintsProvider for SmokeInlayHintsProvider with resolve_inlay_hint(
  _self,
  hint,
  _token,
) {
  hint.set_label(@vscode.InlayHintLabelValue::Text(": ResolvedMoonBit"))
  Some(hint)
}

///|
impl @vscode.InlineValuesProvider for SmokeInlineValuesProvider with provide_inline_values(
  _self,
  _document,
  _range,
  context,
  _token,
) {
  Some([
    @vscode.InlineValue::Text(
      @vscode.InlineValueText::new(
        @vscode.Range::new(
          @vscode.Position::new(0, 0),
          @vscode.Position::new(0, 5),
        ),
        "frame:\{context.frame_id}",
      ),
    ),
  ])
}

///|
impl @vscode.DocumentSemanticTokensProvider for SmokeDocumentSemanticTokensProvider with provide_document_semantic_tokens(
  _self,
  _document,
  _token,
) {
  @vscode.SemanticTokens::new([0, 0, 4, 0, 0], result_id="moon-full")
}

///|
impl @vscode.DocumentSemanticTokensProvider for SmokeDocumentSemanticTokensProvider with provide_document_semantic_tokens_edits(
  _self,
) {
  None
}

///|
impl @vscode.DocumentSemanticTokensProvider for SmokeDocumentSemanticTokensProvider with on_did_change_semantic_tokens(
  _self,
) {
  None
}

///|
impl @vscode.DocumentRangeSemanticTokensProvider for SmokeDocumentRangeSemanticTokensProvider with provide_document_range_semantic_tokens(
  _self,
  _document,
  _range,
  _token,
) {
  @vscode.SemanticTokens::new([0, 1, 3, 0, 0], result_id="moon-range")
}

///|
impl @vscode.CallHierarchyProvider for SmokeCallHierarchyProvider with prepare_call_hierarchy(
  _self,
  document,
  _position,
  _token,
) {
  Some([
    @vscode.CallHierarchyItem::new(
      @vscode.SymbolKind::Function,
      "moonCall",
      "MoonBit call detail",
      document.uri(),
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 8),
      ),
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 4),
      ),
    ),
  ])
}

///|
impl @vscode.CallHierarchyProvider for SmokeCallHierarchyProvider with provide_call_hierarchy_incoming_calls(
  _self,
  item,
  _token,
) {
  Some([
    @vscode.CallHierarchyIncomingCall::new(
      @vscode.CallHierarchyItem::new(
        @vscode.SymbolKind::Function,
        "incoming-\{item.name()}",
        "MoonBit incoming detail",
        item.uri(),
        item.range(),
        item.selection_range(),
      ),
      [@vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 4),
      )],
    ),
  ])
}

///|
impl @vscode.CallHierarchyProvider for SmokeCallHierarchyProvider with provide_call_hierarchy_outgoing_calls(
  _self,
  item,
  _token,
) {
  Some([
    @vscode.CallHierarchyOutgoingCall::new(
      @vscode.CallHierarchyItem::new(
        @vscode.SymbolKind::Function,
        "outgoing-\{item.name()}",
        "MoonBit outgoing detail",
        item.uri(),
        item.range(),
        item.selection_range(),
      ),
      [@vscode.Range::new(
        @vscode.Position::new(0, 4),
        @vscode.Position::new(0, 8),
      )],
    ),
  ])
}

///|
impl @vscode.TypeHierarchyProvider for SmokeTypeHierarchyProvider with prepare_type_hierarchy(
  _self,
  document,
  _position,
  _token,
) {
  Some([
    @vscode.TypeHierarchyItem::new(
      @vscode.SymbolKind::Class,
      "MoonType",
      "MoonBit type detail",
      document.uri(),
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 8),
      ),
      @vscode.Range::new(
        @vscode.Position::new(0, 0),
        @vscode.Position::new(0, 4),
      ),
    ),
  ])
}

///|
impl @vscode.TypeHierarchyProvider for SmokeTypeHierarchyProvider with provide_type_hierarchy_supertypes(
  _self,
  item,
  _token,
) {
  Some([
    @vscode.TypeHierarchyItem::new(
      @vscode.SymbolKind::Class,
      "Super\{item.name()}",
      "MoonBit supertype detail",
      item.uri(),
      item.range(),
      item.selection_range(),
    ),
  ])
}

///|
impl @vscode.TypeHierarchyProvider for SmokeTypeHierarchyProvider with provide_type_hierarchy_subtypes(
  _self,
  item,
  _token,
) {
  Some([
    @vscode.TypeHierarchyItem::new(
      @vscode.SymbolKind::Class,
      "Sub\{item.name()}",
      "MoonBit subtype detail",
      item.uri(),
      item.range(),
      item.selection_range(),
    ),
  ])
}

///|
impl @vscode.FoldingRangeProvider for SmokeFoldingRangeProvider with provide_folding_ranges(
  _self,
  _document,
  _context,
  _token,
) {
  Some([
    @vscode.FoldingRange::new(0, 2, kind=@vscode.FoldingRangeKind::Region),
  ])
}

///|
impl @vscode.SelectionRangeProvider for SmokeSelectionRangeProvider with provide_selection_ranges(
  _self,
  _document,
  positions,
  _token,
) {
  match positions.get(0) {
    None => Some([])
    Some(position) => {
      let parent = @vscode.SelectionRange::new(
        @vscode.Range::new(
          @vscode.Position::new(position.line(), 0),
          @vscode.Position::new(position.line(), 9),
        ),
      )
      Some([
        @vscode.SelectionRange::new(
          @vscode.Range::new(position, @vscode.Position::new(position.line(), 4)),
          parent=parent,
        ),
      ])
    }
  }
}

///|
impl @vscode.DocumentRangeFormattingEditProvider for SmokeDocumentRangeFormattingProvider with provide_document_range_formatting_edits(
  _self,
  _document,
  range,
  options,
  _token,
) {
  let indent = if options.insert_spaces { "spaces" } else { "tabs" }
  Some([@vscode.TextEdit::replace(range, "range:\{options.tab_size}:\{indent}")])
}

///|
impl @vscode.OnTypeFormattingEditProvider for SmokeOnTypeFormattingProvider with provide_on_type_formatting_edits(
  _self,
  _document,
  position,
  ch,
  options,
  _token,
) {
  let indent = if options.insert_spaces { "spaces" } else { "tabs" }
  Some([
    @vscode.TextEdit::insert(
      position,
      "type:\{ch}:\{options.tab_size}:\{indent}",
    ),
  ])
}

///|
impl @vscode.TaskProvider for SmokeTaskProvider with provide_tasks(
  _self,
  _token,
) {
  let task = @vscode.Task::new(
    @vscode.TaskDefinition::new(
      task_provider_type,
      entries=[
        ("script", @vscode.Any::from("smoke")),
        ("fromMoonBit", @vscode.Any::from(true)),
      ],
    ),
    @vscode.TaskScope::ScopeKind(@vscode.TaskScopeKind::Workspace),
    "MoonBit smoke task",
    "MoonBit",
    execution=@vscode.TaskExecutionValue::ShellExecutionValue(
      @vscode.ShellExecution::new_command_line("echo moonbit-task"),
    ),
    problem_matchers=[],
  )
  task.set_detail(Some("provided by MoonBit"))
  task.set_group(Some(@vscode.TaskGroup::test_group()))
  Some([task])
}

///|
impl @vscode.TaskProvider for SmokeTaskProvider with resolve_task(
  _self,
  task,
  _token,
) {
  task.set_detail(Some("resolved by MoonBit"))
  Some(task)
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
    @languages.register_implementation_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeImplementationProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_type_definition_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeTypeDefinitionProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_declaration_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeDeclarationProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_document_highlight_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeDocumentHighlightProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_document_link_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeDocumentLinkProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_document_symbol_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeDocumentSymbolProvider::{},
      metadata=@vscode.DocumentSymbolProviderMetadata::new(
        label="MoonBit Symbols",
      ),
    ),
  )
  ctx.subscribe(
    @languages.register_workspace_symbol_provider(SmokeWorkspaceSymbolProvider::{}),
  )
  ctx.subscribe(
    @languages.register_hover_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeHoverProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_reference_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeReferenceProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_rename_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeRenameProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_signature_help_provider_metadata(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeSignatureHelpProvider::{},
      @vscode.SignatureHelpProviderMetadata::new(
        ["("],
        retrigger_characters=[","],
      ),
    ),
  )
  ctx.subscribe(
    @languages.register_document_formatting_edit_provider(
      @vscode.DocumentSelector::Language(document_formatting_language),
      SmokeDocumentFormattingProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_color_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeDocumentColorProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_folding_range_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeFoldingRangeProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_inlay_hints_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeInlayHintsProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_inline_values_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeInlineValuesProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_document_semantic_tokens_provider(
      @vscode.DocumentSelector::Language(semantic_tokens_language),
      SmokeDocumentSemanticTokensProvider::{},
      @vscode.SemanticTokensLegend::new(["function"]),
    ),
  )
  ctx.subscribe(
    @languages.register_document_range_semantic_tokens_provider(
      @vscode.DocumentSelector::Language(range_semantic_tokens_language),
      SmokeDocumentRangeSemanticTokensProvider::{},
      @vscode.SemanticTokensLegend::new(["function"]),
    ),
  )
  ctx.subscribe(
    @languages.register_call_hierarchy_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeCallHierarchyProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_type_hierarchy_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeTypeHierarchyProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_selection_range_provider(
      @vscode.DocumentSelector::Language(language_provider_language),
      SmokeSelectionRangeProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_document_range_formatting_edit_provider(
      @vscode.DocumentSelector::Language(range_formatting_language),
      SmokeDocumentRangeFormattingProvider::{},
    ),
  )
  ctx.subscribe(
    @languages.register_on_type_formatting_edit_provider(
      @vscode.DocumentSelector::Language(on_type_formatting_language),
      SmokeOnTypeFormattingProvider::{},
      "}",
      more_trigger_characters=[";"],
    ),
  )
  ctx.subscribe(@tasks.register_task_provider(task_provider_type, SmokeTaskProvider::{}))
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
