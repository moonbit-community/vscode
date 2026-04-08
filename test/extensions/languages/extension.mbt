///|
/// JS entrypoint for languages namespace binding checks.

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
    _ => @vscode.Uri::file("/tmp/moonbit-languages-fixture")
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
priv struct FixtureLanguageProvider {}

///|
impl @vscode.CompletionItemProvider for FixtureLanguageProvider with provide_completion_items(
  _self,
  _document,
  _position,
  _token,
  _context,
) {
  Some([])
}

///|
impl @vscode.CompletionItemProvider for FixtureLanguageProvider with resolve_completion_item(
  _self,
  _item,
  _token,
) {
  None
}

///|
impl @vscode.InlineCompletionItemProvider for FixtureLanguageProvider with provide_inline_completion_items(
  _self,
  _document,
  _position,
  _context,
  _token,
) {
  Some([])
}

///|
impl @vscode.CodeActionProvider for FixtureLanguageProvider with provide_code_actions(
  _self,
  _document,
  _range,
  _context,
  _token,
) {
  Some([])
}

///|
impl @vscode.CodeActionProvider for FixtureLanguageProvider with resolve_code_action(
  _self,
  _action,
  _token,
) {
  None
}

///|
impl @vscode.CodeLensProvider for FixtureLanguageProvider with provide_code_lenses(
  _self,
  _document,
  _token,
) {
  Some([])
}

///|
impl @vscode.CodeLensProvider for FixtureLanguageProvider with on_did_change_code_lenses(
  _self,
) {
  None
}

///|
impl @vscode.CodeLensProvider for FixtureLanguageProvider with resolve_code_lens(
  _self,
  _lens,
  _token,
) {
  None
}

///|
impl @vscode.DefinitionProvider for FixtureLanguageProvider with provide_definition(
  _self,
  _document,
  _position,
  _token,
) {
  Some([])
}

///|
impl @vscode.ImplementationProvider for FixtureLanguageProvider with provide_implementation(
  _self,
  _document,
  _position,
  _token,
) {
  Some([])
}

///|
impl @vscode.TypeDefinitionProvider for FixtureLanguageProvider with provide_type_definition(
  _self,
  _document,
  _position,
  _token,
) {
  Some([])
}

///|
impl @vscode.DeclarationProvider for FixtureLanguageProvider with provide_declaration(
  _self,
  _document,
  _position,
  _token,
) {
  Some([])
}

///|
impl @vscode.HoverProvider for FixtureLanguageProvider with provide_hover(
  _self,
  _document,
  _position,
  _token,
) {
  None
}

///|
impl @vscode.InlineValuesProvider for FixtureLanguageProvider with provide_inline_values(
  _self,
  _document,
  _range,
  _context,
  _token,
) {
  Some([])
}

///|
impl @vscode.DocumentHighlightProvider for FixtureLanguageProvider with provide_document_highlights(
  _self,
  _document,
  _position,
  _token,
) {
  Some([])
}

///|
impl @vscode.DocumentSymbolProvider for FixtureLanguageProvider with provide_document_symbols(
  _self,
  _document,
  _token,
) {
  Some([])
}

///|
impl @vscode.WorkspaceSymbolProvider for FixtureLanguageProvider with provide_workspace_symbols(
  _self,
  _query,
  _token,
) {
  Some([])
}

///|
impl @vscode.WorkspaceSymbolProvider for FixtureLanguageProvider with resolve_workspace_symbol(
  _self,
  _symbol,
  _token,
) {
  None
}

///|
impl @vscode.ReferenceProvider for FixtureLanguageProvider with provide_references(
  _self,
  _document,
  _position,
  _context,
  _token,
) {
  Some([])
}

///|
impl @vscode.RenameProvider for FixtureLanguageProvider with provide_rename_edits(
  _self,
  _document,
  _position,
  _new_name,
  _token,
) {
  None
}

///|
impl @vscode.RenameProvider for FixtureLanguageProvider with prepare_rename(
  _self,
  _document,
  _position,
  _token,
) {
  None
}

///|
impl @vscode.DocumentSemanticTokensProvider for FixtureLanguageProvider with provide_document_semantic_tokens(
  _self,
  _document,
  _token,
) {
  let builder = @vscode.SemanticTokensBuilder::new()
  builder.build()
}

///|
impl @vscode.DocumentSemanticTokensProvider for FixtureLanguageProvider with provide_document_semantic_tokens_edits(
  _self,
) {
  None
}

///|
impl @vscode.DocumentSemanticTokensProvider for FixtureLanguageProvider with on_did_change_semantic_tokens(
  _self,
) {
  None
}

///|
impl @vscode.DocumentRangeSemanticTokensProvider for FixtureLanguageProvider with provide_document_range_semantic_tokens(
  _self,
  _document,
  _range,
  _token,
) {
  let builder = @vscode.SemanticTokensBuilder::new()
  builder.build()
}

///|
impl @vscode.DocumentFormattingEditProvider for FixtureLanguageProvider with provide_document_formatting_edits(
  _self,
  _document,
  _options,
  _token,
) {
  Some([])
}

///|
impl @vscode.DocumentRangeFormattingEditProvider for FixtureLanguageProvider with provide_document_range_formatting_edits(
  _self,
  _document,
  _range,
  _options,
  _token,
) {
  Some([])
}

///|
impl @vscode.OnTypeFormattingEditProvider for FixtureLanguageProvider with provide_on_type_formatting_edits(
  _self,
  _document,
  _position,
  _ch,
  _options,
  _token,
) {
  Some([])
}

///|
impl @vscode.SignatureHelpProvider for FixtureLanguageProvider with provide_signature_help(
  _self,
  _document,
  _position,
  _token,
  _context,
) {
  None
}

///|
impl @vscode.DocumentLinkProvider for FixtureLanguageProvider with provide_document_links(
  _self,
  _document,
  _token,
) {
  Some([])
}

///|
impl @vscode.DocumentLinkProvider for FixtureLanguageProvider with resolve_document_link(
  _self,
  _link,
  _token,
) {
  None
}

///|
impl @vscode.DocumentColorProvider for FixtureLanguageProvider with provide_document_colors(
  _self,
  _document,
  _token,
) {
  Some([])
}

///|
impl @vscode.DocumentColorProvider for FixtureLanguageProvider with provide_color_presentations(
  _self,
  _color,
  _context,
  _token,
) {
  Some([])
}

///|
impl @vscode.InlayHintsProvider for FixtureLanguageProvider with provide_inlay_hints(
  _self,
  _document,
  _range,
  _token,
) {
  Some([])
}

///|
impl @vscode.InlayHintsProvider for FixtureLanguageProvider with resolve_inlay_hint(
  _self,
  _hint,
  _token,
) {
  None
}

///|
impl @vscode.FoldingRangeProvider for FixtureLanguageProvider with provide_folding_ranges(
  _self,
  _document,
  _context,
  _token,
) {
  Some([])
}

///|
impl @vscode.SelectionRangeProvider for FixtureLanguageProvider with provide_selection_ranges(
  _self,
  _document,
  _positions,
  _token,
) {
  Some([])
}

///|
impl @vscode.CallHierarchyProvider for FixtureLanguageProvider with prepare_call_hierarchy(
  _self,
  _document,
  _position,
  _token,
) {
  Some([])
}

///|
impl @vscode.CallHierarchyProvider for FixtureLanguageProvider with provide_call_hierarchy_incoming_calls(
  _self,
  _item,
  _token,
) {
  Some([])
}

///|
impl @vscode.CallHierarchyProvider for FixtureLanguageProvider with provide_call_hierarchy_outgoing_calls(
  _self,
  _item,
  _token,
) {
  Some([])
}

///|
impl @vscode.TypeHierarchyProvider for FixtureLanguageProvider with prepare_type_hierarchy(
  _self,
  _document,
  _position,
  _token,
) {
  Some([])
}

///|
impl @vscode.TypeHierarchyProvider for FixtureLanguageProvider with provide_type_hierarchy_supertypes(
  _self,
  _item,
  _token,
) {
  Some([])
}

///|
impl @vscode.TypeHierarchyProvider for FixtureLanguageProvider with provide_type_hierarchy_subtypes(
  _self,
  _item,
  _token,
) {
  Some([])
}

///|
impl @vscode.LinkedEditingRangeProvider for FixtureLanguageProvider with provide_linked_editing_ranges(
  _self,
  _document,
  _position,
  _token,
) {
  None
}

///|
impl @vscode.DocumentDropEditProvider for FixtureLanguageProvider with provide_document_drop_edits(
  _self,
  _document,
  _position,
  _data_transfer,
  _token,
) {
  None
}

///|
impl @vscode.DocumentDropEditProvider for FixtureLanguageProvider with metadata(_self) {
  None
}

///|
impl @vscode.DocumentPasteEditProvider for FixtureLanguageProvider with provide_document_paste_edits(
  _self,
  _document,
  _ranges,
  _data_transfer,
  _context,
  _token,
) {
  None
}

///|
impl @vscode.DocumentPasteEditProvider for FixtureLanguageProvider with metadata(_self) {
  None
}

///|
async fn run_check_languages(root : @vscode.Uri) -> Unit {
  let diagnostics_changed = @languages.on_did_change_diagnostics().subscribe(_ => ())
  let collection = @languages.create_diagnostic_collection(
    name=fresh_id("moonbit-languages-diagnostics"),
  )

  let document = @workspace.open_text_document_untitled(
    language="plaintext",
    content="let moonbit_language_test = 1",
  )

  let selector = @vscode.DocumentSelector::Language("markdown")
  let before_match = @languages.match_document(selector, document)
  let markdown_document = @languages.set_text_document_language(document, "markdown")
  let after_match = @languages.match_document(selector, markdown_document)

  let uri = markdown_document.uri()
  let start = @vscode.Position::new(0, 0)
  let end_ = @vscode.Position::new(0, 3)
  let range = @vscode.Range::new(start, end_)
  let diagnostic = @vscode.Diagnostic::new(range, "moonbit-languages-diagnostic")
  let related = @vscode.DiagnosticRelatedInformation::new(
    @vscode.Location::new(uri, range),
    "moonbit-related",
  )
  diagnostic.set_related_information([related])
  diagnostic.set_tags([@vscode.DiagnosticTag::Deprecated])
  collection.set(uri, [diagnostic])

  let block_pair = @languages.CharacterPair::new("/*", "*/")
  let configured = @languages.LanguageConfiguration::new(
    comments=@languages.CommentRule::new(
      line_comment="//",
      block_comment=block_pair,
    ),
    brackets=[
      @languages.CharacterPair::new("{", "}"),
      @languages.CharacterPair::new("[", "]"),
    ],
    word_pattern=@vscode.RegExp::new("[A-Za-z_][A-Za-z0-9_]*"),
    indentation_rules=@languages.IndentationRule::new(
      @vscode.RegExp::new("^\\s*\\}"),
      @vscode.RegExp::new("^\\s*\\{"),
      indent_next_line_pattern=@vscode.RegExp::new(".*\\{\\s*$"),
    ),
    on_enter_rules=[
      @languages.OnEnterRule::new(
        @vscode.RegExp::new(".*"),
        @languages.EnterAction::new(
          @languages.IndentAction::Indent,
          append_text="// ",
        ),
      ),
    ],
    auto_closing_pairs=[
      @languages.AutoClosingPair::new(
        "{",
        "}",
        not_in=[@languages.SyntaxTokenType::String],
      ),
    ],
  )

  let status_item = @languages.create_language_status_item(
    fresh_id("moonbit-languages-status"),
    selector,
  )

  let fixture_provider = FixtureLanguageProvider::{  }
  let completion_provider = fixture_provider
  let inline_completion_provider = fixture_provider
  let code_action_provider = fixture_provider
  let code_lens_provider = fixture_provider
  let definition_provider = fixture_provider
  let implementation_provider = fixture_provider
  let type_definition_provider = fixture_provider
  let declaration_provider = fixture_provider
  let hover_provider = fixture_provider
  let evaluatable_provider = @languages.EvaluatableExpressionProvider::new(
    fn(_document, position, _token) {
      Some(
        @languages.EvaluatableExpression::new(
          @vscode.Range::new(position, position),
        ),
      )
    },
  )
  let inline_values_provider = fixture_provider
  let document_highlight_provider = fixture_provider
  let document_symbol_provider = fixture_provider
  let workspace_symbol_provider = fixture_provider
  let reference_provider = fixture_provider
  let rename_provider = fixture_provider
  let semantic_provider = fixture_provider
  let semantic_range_provider = fixture_provider
  let document_formatting_provider = fixture_provider
  let range_formatting_provider = fixture_provider
  let on_type_formatting_provider = fixture_provider
  let signature_help_provider = fixture_provider
  let document_link_provider = fixture_provider
  let color_provider = fixture_provider
  let inlay_hints_provider = fixture_provider
  let folding_provider = fixture_provider
  let selection_range_provider = fixture_provider
  let call_hierarchy_provider = fixture_provider
  let type_hierarchy_provider = fixture_provider
  let linked_editing_provider = fixture_provider
  let document_drop_provider = fixture_provider
  let document_paste_provider = fixture_provider

  let registrations : Array[&@vscode.Disposable] = [
    @languages.register_completion_item_provider(
      selector,
      completion_provider,
      trigger_characters=["."],
    ),
    @languages.register_inline_completion_item_provider(
      selector,
      inline_completion_provider,
    ),
    @languages.register_code_actions_provider(
      selector,
      code_action_provider,
      metadata=@vscode.CodeActionProviderMetadata::new(),
    ),
    @languages.register_code_lens_provider(selector, code_lens_provider),
    @languages.register_definition_provider(selector, definition_provider),
    @languages.register_implementation_provider(selector, implementation_provider),
    @languages.register_type_definition_provider(selector, type_definition_provider),
    @languages.register_declaration_provider(selector, declaration_provider),
    @languages.register_hover_provider(selector, hover_provider),
    @languages.register_evaluatable_expression_provider(selector, evaluatable_provider),
    @languages.register_inline_values_provider(selector, inline_values_provider),
    @languages.register_document_highlight_provider(
      selector,
      document_highlight_provider,
    ),
    @languages.register_document_symbol_provider(
      selector,
      document_symbol_provider,
      metadata=@vscode.DocumentSymbolProviderMetadata::new(),
    ),
    @languages.register_workspace_symbol_provider(workspace_symbol_provider),
    @languages.register_reference_provider(selector, reference_provider),
    @languages.register_rename_provider(selector, rename_provider),
    @languages.register_document_semantic_tokens_provider(
      selector,
      semantic_provider,
      @vscode.SemanticTokensLegend::new(["keyword"]),
    ),
    @languages.register_document_range_semantic_tokens_provider(
      selector,
      semantic_range_provider,
      @vscode.SemanticTokensLegend::new(["keyword"]),
    ),
    @languages.register_document_formatting_edit_provider(
      selector,
      document_formatting_provider,
    ),
    @languages.register_document_range_formatting_edit_provider(
      selector,
      range_formatting_provider,
    ),
    @languages.register_on_type_formatting_edit_provider(
      selector,
      on_type_formatting_provider,
      ";",
      more_trigger_characters=["}"],
    ),
    @languages.register_signature_help_provider(
      selector,
      signature_help_provider,
      trigger_characters=["("],
    ),
    @languages.register_signature_help_provider_metadata(
      selector,
      signature_help_provider,
      @vscode.SignatureHelpProviderMetadata::new(["("], retrigger_characters=[","]),
    ),
    @languages.register_document_link_provider(selector, document_link_provider),
    @languages.register_color_provider(selector, color_provider),
    @languages.register_inlay_hints_provider(selector, inlay_hints_provider),
    @languages.register_folding_range_provider(selector, folding_provider),
    @languages.register_selection_range_provider(selector, selection_range_provider),
    @languages.register_call_hierarchy_provider(selector, call_hierarchy_provider),
    @languages.register_type_hierarchy_provider(selector, type_hierarchy_provider),
    @languages.register_linked_editing_range_provider(selector, linked_editing_provider),
    @languages.register_document_drop_edit_provider(
      selector,
      document_drop_provider,
      metadata=@vscode.DocumentDropEditProviderMetadata::new(["text/plain"]),
    ),
    @languages.register_document_paste_edit_provider(
      selector,
      document_paste_provider,
      @vscode.DocumentPasteProviderMetadata::new([
        @vscode.DocumentDropOrPasteEditKind::Text,
      ]),
    ),
    @languages.set_language_configuration(
      "moonbit-language-test",
      configured,
    ),
  ]

  let uri_diagnostics = @languages.get_diagnostics(uri)
  let all_diagnostics = @languages.get_all_diagnostics()
  let known_languages = @languages.get_languages()
  let tag_count = match diagnostic.tags() {
    Some(tags) => tags.length()
    None => 0
  }
  let related_count = match diagnostic.related_information() {
    Some(values) => values.length()
    None => 0
  }
  let pair_preview = "\{block_pair.open}\{block_pair.close}"

  for registration in registrations {
    registration.dispose()
  }

  status_item.dispose()
  diagnostics_changed.dispose()
  collection.delete(uri)
  collection.dispose()

  write_result(
    root,
    "languages-result.txt",
    "languages ok before_match=\{before_match} after_match=\{after_match} uri_diagnostics=\{uri_diagnostics.length()} all_diagnostics=\{all_diagnostics.length()} language=\{markdown_document.language_id()} known_languages=\{known_languages.length()} registrations=\{registrations.length()} tags=\{tag_count} related=\{related_count} pair=\{pair_preview}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.languages.checkBindings",
    async fn(_args) {
      run_check_languages(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
