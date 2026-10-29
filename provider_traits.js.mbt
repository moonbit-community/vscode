///|
/// Core provider traits (runtime carrier impls live in @internal).

///|
pub(open) trait CompletionItemProvider {
  async fn provide_completion_items(
    Self,
    TextDocument,
    Position,
    CancellationToken,
    CompletionContext,
  ) -> Array[CompletionItem]?
  async fn resolve_completion_item(Self, CompletionItem, CancellationToken) -> CompletionItem?
}

///|
pub(open) trait InlineCompletionItemProvider {
  async fn provide_inline_completion_items(
    Self,
    TextDocument,
    Position,
    InlineCompletionContext,
    CancellationToken,
  ) -> Array[InlineCompletionItem]?
}

///|
pub(open) trait CodeActionProvider {
  async fn provide_code_actions(
    Self,
    TextDocument,
    Range,
    CodeActionContext,
    CancellationToken,
  ) -> Array[CodeAction]?
  async fn resolve_code_action(Self, CodeAction, CancellationToken) -> CodeAction?
}

///|
pub(open) trait CodeLensProvider {
  fn on_did_change_code_lenses(Self) -> Event[Unit]?
  async fn provide_code_lenses(Self, TextDocument, CancellationToken) -> Array[
    CodeLens,
  ]?
  async fn resolve_code_lens(Self, CodeLens, CancellationToken) -> CodeLens?
}

///|
pub(open) trait DefinitionProvider {
  async fn provide_definition(Self, TextDocument, Position, CancellationToken) -> Array[
    Location,
  ]?
}

///|
pub(open) trait ImplementationProvider {
  async fn provide_implementation(
    Self,
    TextDocument,
    Position,
    CancellationToken,
  ) -> Array[Location]?
}

///|
pub(open) trait TypeDefinitionProvider {
  async fn provide_type_definition(
    Self,
    TextDocument,
    Position,
    CancellationToken,
  ) -> Array[Location]?
}

///|
pub(open) trait DeclarationProvider {
  async fn provide_declaration(Self, TextDocument, Position, CancellationToken) -> Array[
    Location,
  ]?
}

///|
pub(open) trait HoverProvider {
  async fn provide_hover(Self, TextDocument, Position, CancellationToken) -> Hover?
}

///|
pub(open) trait InlineValuesProvider {
  async fn provide_inline_values(
    Self,
    TextDocument,
    Range,
    InlineValueContext,
    CancellationToken,
  ) -> Array[InlineValue]?
}

///|
pub(open) trait DocumentHighlightProvider {
  async fn provide_document_highlights(
    Self,
    TextDocument,
    Position,
    CancellationToken,
  ) -> Array[DocumentHighlight]?
}

///|
pub(open) trait DocumentSymbolProvider {
  async fn provide_document_symbols(Self, TextDocument, CancellationToken) -> Array[
    DocumentSymbol,
  ]?
}

///|
pub(open) trait WorkspaceSymbolProvider {
  async fn provide_workspace_symbols(Self, String, CancellationToken) -> Array[
    SymbolInformation,
  ]?
  async fn resolve_workspace_symbol(Self, SymbolInformation, CancellationToken) -> SymbolInformation?
}

///|
pub(open) trait ReferenceProvider {
  async fn provide_references(
    Self,
    TextDocument,
    Position,
    ReferenceContext,
    CancellationToken,
  ) -> Array[Location]?
}

///|
pub(open) trait RenameProvider {
  async fn provide_rename_edits(
    Self,
    TextDocument,
    Position,
    String,
    CancellationToken,
  ) -> WorkspaceEdit?
  async fn prepare_rename(Self, TextDocument, Position, CancellationToken) -> Range?
}

///|
pub(open) trait DocumentSemanticTokensProvider {
  async fn provide_document_semantic_tokens(
    Self,
    TextDocument,
    CancellationToken,
  ) -> SemanticTokens
  fn provide_document_semantic_tokens_edits(Self) -> (async (
    TextDocument,
    String,
    CancellationToken,
  ) -> SemanticTokensEdits)?
  fn on_did_change_semantic_tokens(Self) -> Event[Unit]?
}

///|
pub(open) trait DocumentRangeSemanticTokensProvider {
  async fn provide_document_range_semantic_tokens(
    Self,
    TextDocument,
    Range,
    CancellationToken,
  ) -> SemanticTokens
}

///|
pub(open) trait DocumentFormattingEditProvider {
  async fn provide_document_formatting_edits(
    Self,
    TextDocument,
    FormattingOptions,
    CancellationToken,
  ) -> Array[TextEdit]?
}

///|
pub(open) trait DocumentRangeFormattingEditProvider {
  async fn provide_document_range_formatting_edits(
    Self,
    TextDocument,
    Range,
    FormattingOptions,
    CancellationToken,
  ) -> Array[TextEdit]?
}

///|
pub(open) trait OnTypeFormattingEditProvider {
  async fn provide_on_type_formatting_edits(
    Self,
    TextDocument,
    Position,
    String,
    FormattingOptions,
    CancellationToken,
  ) -> Array[TextEdit]?
}

///|
pub(open) trait SignatureHelpProvider {
  async fn provide_signature_help(
    Self,
    TextDocument,
    Position,
    CancellationToken,
    SignatureHelpContext,
  ) -> SignatureHelp?
}

///|
pub(open) trait DocumentLinkProvider {
  async fn provide_document_links(Self, TextDocument, CancellationToken) -> Array[
    DocumentLink,
  ]?
  async fn resolve_document_link(Self, DocumentLink, CancellationToken) -> DocumentLink?
}

///|
pub(open) trait DocumentColorProvider {
  async fn provide_document_colors(Self, TextDocument, CancellationToken) -> Array[
    ColorInformation,
  ]?
  async fn provide_color_presentations(
    Self,
    Color,
    ColorPresentationContext,
    CancellationToken,
  ) -> Array[ColorPresentation]?
}

///|
pub(open) trait InlayHintsProvider {
  async fn provide_inlay_hints(Self, TextDocument, Range, CancellationToken) -> Array[
    InlayHint,
  ]?
  async fn resolve_inlay_hint(Self, InlayHint, CancellationToken) -> InlayHint?
}

///|
pub(open) trait FoldingRangeProvider {
  async fn provide_folding_ranges(
    Self,
    TextDocument,
    FoldingContext,
    CancellationToken,
  ) -> Array[FoldingRange]?
}

///|
pub(open) trait SelectionRangeProvider {
  async fn provide_selection_ranges(
    Self,
    TextDocument,
    Array[Position],
    CancellationToken,
  ) -> Array[SelectionRange]?
}

///|
pub(open) trait CallHierarchyProvider {
  async fn prepare_call_hierarchy(
    Self,
    TextDocument,
    Position,
    CancellationToken,
  ) -> Array[CallHierarchyItem]?
  async fn provide_call_hierarchy_incoming_calls(
    Self,
    CallHierarchyItem,
    CancellationToken,
  ) -> Array[CallHierarchyIncomingCall]?
  async fn provide_call_hierarchy_outgoing_calls(
    Self,
    CallHierarchyItem,
    CancellationToken,
  ) -> Array[CallHierarchyOutgoingCall]?
}

///|
pub(open) trait TypeHierarchyProvider {
  async fn prepare_type_hierarchy(
    Self,
    TextDocument,
    Position,
    CancellationToken,
  ) -> Array[TypeHierarchyItem]?
  async fn provide_type_hierarchy_supertypes(
    Self,
    TypeHierarchyItem,
    CancellationToken,
  ) -> Array[TypeHierarchyItem]?
  async fn provide_type_hierarchy_subtypes(
    Self,
    TypeHierarchyItem,
    CancellationToken,
  ) -> Array[TypeHierarchyItem]?
}

///|
pub(open) trait LinkedEditingRangeProvider {
  async fn provide_linked_editing_ranges(
    Self,
    TextDocument,
    Position,
    CancellationToken,
  ) -> LinkedEditingRanges?
}

///|
pub(open) trait DocumentDropEditProvider {
  async fn provide_document_drop_edits(
    Self,
    TextDocument,
    Position,
    DataTransfer,
    CancellationToken,
  ) -> Array[DocumentDropEdit]?
  fn metadata(Self) -> DocumentDropEditProviderMetadata?
}

///|
pub(open) trait DocumentPasteEditProvider {
  async fn provide_document_paste_edits(
    Self,
    TextDocument,
    Array[Range],
    DataTransfer,
    DocumentPasteEditContext,
    CancellationToken,
  ) -> Array[DocumentPasteEdit]?
  fn metadata(Self) -> DocumentPasteProviderMetadata?
}

///|
pub(open) trait QuickDiffProvider {
  async fn provide_original_resource(Self, Uri, CancellationToken) -> Uri?
}

///|
pub(open) trait CommentingRangeProvider {
  async fn provide_commenting_ranges(Self, TextDocument, CancellationToken) -> CommentingRanges?
}

///|
pub(open) trait TextDocumentContentProvider {
  fn on_did_change(Self) -> Event[Uri]?
  async fn provide_text_document_content(Self, Uri, CancellationToken) -> String
}

///|
pub(open) trait FileSystemProvider {
  fn on_did_change_file(Self) -> Event[Array[FileChangeEvent]]
  fn watch(Self, Uri, Bool, Array[String]) -> Disposable
  async fn stat(Self, Uri) -> FileStat
  async fn read_directory(Self, Uri) -> Array[DirectoryEntry]
  async fn create_directory(Self, Uri) -> Unit
  async fn read_file(Self, Uri) -> Bytes
  async fn write_file(Self, Uri, Bytes, Bool, Bool) -> Unit
  async fn delete(Self, Uri, Bool) -> Unit
  async fn rename(Self, Uri, Uri, Bool) -> Unit
  async fn copy(Self, Uri, Uri, Bool) -> Unit
}

///|
pub(open) trait WebviewViewProvider {
  async fn resolve_webview_view(
    Self,
    WebviewView,
    WebviewViewResolveContext,
    CancellationToken,
  ) -> Unit
}

///|
pub(open) trait TerminalLinkProvider {
  async fn provide_terminal_links(Self, TerminalLinkContext, CancellationToken) -> Array[
    TerminalLink,
  ]?
  async fn handle_terminal_link(Self, TerminalLink) -> Unit
}

///|
pub(open) trait TerminalProfileProvider {
  async fn provide_terminal_profile(Self, CancellationToken) -> TerminalProfile?
}

///|
pub(open) trait FileDecorationProvider {
  fn on_did_change_file_decorations(Self) -> Event[FileDecorationChange]?
  async fn provide_file_decoration(Self, Uri, CancellationToken) -> FileDecoration?
}
