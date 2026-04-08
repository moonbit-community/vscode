///|
/// JS FFI bindings for VS Code languages namespace.

///|
extern "js" fn languages_evaluatable_expression_ffi(
  range : Range,
  expression : @v.JsValue,
) -> EvaluatableExpression =
  #| (range, expression) => {
  #|   const EvaluatableExpression = require("vscode").EvaluatableExpression;
  #|   return expression === undefined || expression === null
  #|     ? new EvaluatableExpression(range)
  #|     : new EvaluatableExpression(range, expression);
  #| }

///|
extern "js" fn languages_evaluatable_expression_provider_ffi(
  provide_expression : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> EvaluatableExpressionProvider =
  #| (provideEvaluatableExpression) => ({ provideEvaluatableExpression })

///|
extern "js" fn character_pair_ffi(open : String, close : String) -> @v.JsValue =
  #| (open, close) => [open, close]

///|
extern "js" fn comment_rule_ffi(
  line_comment : @v.JsValue,
  block_comment : @v.JsValue,
) -> @v.JsValue =
  #| (lineComment, blockComment) => {
  #|   const rule = {};
  #|   if (lineComment !== undefined && lineComment !== null) {
  #|     rule.lineComment = lineComment;
  #|   }
  #|   if (blockComment !== undefined && blockComment !== null) {
  #|     rule.blockComment = blockComment;
  #|   }
  #|   return rule;
  #| }

///|
extern "js" fn indentation_rule_ffi(
  decrease_indent_pattern : RegExp,
  increase_indent_pattern : RegExp,
  indent_next_line_pattern : @v.JsValue,
  un_indented_line_pattern : @v.JsValue,
) -> @v.JsValue =
  #| (
  #|   decreaseIndentPattern,
  #|   increaseIndentPattern,
  #|   indentNextLinePattern,
  #|   unIndentedLinePattern
  #| ) => {
  #|   const rule = { decreaseIndentPattern, increaseIndentPattern };
  #|   if (indentNextLinePattern !== undefined && indentNextLinePattern !== null) {
  #|     rule.indentNextLinePattern = indentNextLinePattern;
  #|   }
  #|   if (unIndentedLinePattern !== undefined && unIndentedLinePattern !== null) {
  #|     rule.unIndentedLinePattern = unIndentedLinePattern;
  #|   }
  #|   return rule;
  #| }

///|
extern "js" fn enter_action_ffi(
  indent_action : IndentAction,
  append_text : @v.JsValue,
  remove_text : @v.JsValue,
) -> @v.JsValue =
  #| (indentAction, appendText, removeText) => {
  #|   const action = { indentAction };
  #|   if (appendText !== undefined && appendText !== null) {
  #|     action.appendText = appendText;
  #|   }
  #|   if (removeText !== undefined && removeText !== null) {
  #|     action.removeText = removeText;
  #|   }
  #|   return action;
  #| }

///|
extern "js" fn on_enter_rule_ffi(
  before_text : RegExp,
  after_text : @v.JsValue,
  previous_line_text : @v.JsValue,
  action : @v.JsValue,
) -> @v.JsValue =
  #| (beforeText, afterText, previousLineText, action) => {
  #|   const rule = { beforeText, action };
  #|   if (afterText !== undefined && afterText !== null) {
  #|     rule.afterText = afterText;
  #|   }
  #|   if (previousLineText !== undefined && previousLineText !== null) {
  #|     rule.previousLineText = previousLineText;
  #|   }
  #|   return rule;
  #| }

///|
extern "js" fn auto_closing_pair_ffi(
  open : String,
  close : String,
  not_in : @v.JsValue,
) -> @v.JsValue =
  #| (open, close, notIn) => {
  #|   const pair = { open, close };
  #|   if (notIn !== undefined && notIn !== null) {
  #|     pair.notIn = notIn;
  #|   }
  #|   return pair;
  #| }

///|
extern "js" fn language_configuration_with_parts_ffi(
  comments : @v.JsValue,
  brackets : @v.JsValue,
  word_pattern : @v.JsValue,
  indentation_rules : @v.JsValue,
  on_enter_rules : @v.JsValue,
  auto_closing_pairs : @v.JsValue,
) -> @v.JsValue =
  #| (
  #|   comments,
  #|   brackets,
  #|   wordPattern,
  #|   indentationRules,
  #|   onEnterRules,
  #|   autoClosingPairs
  #| ) => {
  #|   const configuration = {};
  #|   if (comments !== undefined && comments !== null) configuration.comments = comments;
  #|   if (brackets !== undefined && brackets !== null) configuration.brackets = brackets;
  #|   if (wordPattern !== undefined && wordPattern !== null) configuration.wordPattern = wordPattern;
  #|   if (indentationRules !== undefined && indentationRules !== null) {
  #|     configuration.indentationRules = indentationRules;
  #|   }
  #|   if (onEnterRules !== undefined && onEnterRules !== null) {
  #|     configuration.onEnterRules = onEnterRules;
  #|   }
  #|   if (autoClosingPairs !== undefined && autoClosingPairs !== null) {
  #|     configuration.autoClosingPairs = autoClosingPairs;
  #|   }
  #|   return configuration;
  #| }

///|
extern "js" fn languages_get_languages_ffi() -> @js_async.Promise[Array[String]] =
  #| () => require("vscode").languages.getLanguages()

///|
extern "js" fn languages_create_diagnostic_collection_ffi(
  name : @v.JsValue,
) -> DiagnosticCollection =
  #| (name) => {
  #|   const languages = require("vscode").languages;
  #|   return name === undefined || name === null
  #|     ? languages.createDiagnosticCollection()
  #|     : languages.createDiagnosticCollection(name);
  #| }

///|
extern "js" fn languages_on_did_change_diagnostics_ffi() -> Event[
  DiagnosticChangeEvent,
] =
  #| () => require("vscode").languages.onDidChangeDiagnostics

///|
extern "js" fn languages_get_diagnostics_ffi(uri : Uri) -> Array[Diagnostic] =
  #| (uri) => require("vscode").languages.getDiagnostics(uri)

///|
extern "js" fn languages_get_all_diagnostics_ffi() -> Array[
  (Uri, Array[Diagnostic]),
] =
  #| () => require("vscode").languages.getDiagnostics()

///|
extern "js" fn languages_create_language_status_item_ffi(
  id : String,
  selector : @v.JsValue,
) -> LanguageStatusItem =
  #| (id, selector) => require("vscode").languages.createLanguageStatusItem(id, selector)

///|
extern "js" fn languages_match_ffi(
  selector : @v.JsValue,
  document : TextDocument,
) -> Int =
  #| (selector, document) => require("vscode").languages.match(selector, document)

///|
extern "js" fn languages_set_text_document_language_ffi(
  document : TextDocument,
  language_id : String,
) -> @js_async.Promise[TextDocument] =
  #| (document, languageId) =>
  #|   require("vscode").languages.setTextDocumentLanguage(document, languageId)

///|
extern "js" fn languages_register_completion_item_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.CompletionItemProviderObject[@vscode.CompletionItem],
  trigger_characters : @v.JsValue,
) -> &@vscode.Disposable =
  #| (selector, provider, triggerCharacters) => {
  #|   const chars = triggerCharacters === undefined || triggerCharacters === null
  #|     ? []
  #|     : triggerCharacters;
  #|   return require("vscode").languages.registerCompletionItemProvider(
  #|     selector,
  #|     provider,
  #|     ...chars
  #|   );
  #| }

///|
extern "js" fn languages_register_inline_completion_item_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.InlineCompletionItemProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) =>
  #|   require("vscode").languages.registerInlineCompletionItemProvider(selector, provider)

///|
extern "js" fn languages_register_code_actions_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.CodeActionProviderObject[@vscode.CodeAction],
  metadata : @v.JsValue,
) -> &@vscode.Disposable =
  #| (selector, provider, metadata) =>
  #|   require("vscode").languages.registerCodeActionsProvider(
  #|     selector,
  #|     provider,
  #|     metadata === undefined || metadata === null ? undefined : metadata
  #|   )

///|
extern "js" fn languages_register_code_lens_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.CodeLensProviderObject[@vscode.CodeLens],
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerCodeLensProvider(selector, provider)

///|
extern "js" fn languages_register_definition_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DefinitionProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerDefinitionProvider(selector, provider)

///|
extern "js" fn languages_register_implementation_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.ImplementationProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerImplementationProvider(selector, provider)

///|
extern "js" fn languages_register_type_definition_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.TypeDefinitionProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerTypeDefinitionProvider(selector, provider)

///|
extern "js" fn languages_register_declaration_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DeclarationProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerDeclarationProvider(selector, provider)

///|
extern "js" fn languages_register_hover_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.HoverProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerHoverProvider(selector, provider)

///|
extern "js" fn languages_register_evaluatable_expression_provider_ffi(
  selector : @v.JsValue,
  provider : EvaluatableExpressionProvider,
) -> &@vscode.Disposable =
  #| (selector, provider) =>
  #|   require("vscode").languages.registerEvaluatableExpressionProvider(selector, provider)

///|
extern "js" fn languages_register_inline_values_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.InlineValuesProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerInlineValuesProvider(selector, provider)

///|
extern "js" fn languages_register_document_highlight_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentHighlightProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerDocumentHighlightProvider(selector, provider)

///|
extern "js" fn languages_register_document_symbol_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentSymbolProviderObject,
  metadata : @v.JsValue,
) -> &@vscode.Disposable =
  #| (selector, provider, metadata) =>
  #|   require("vscode").languages.registerDocumentSymbolProvider(
  #|     selector,
  #|     provider,
  #|     metadata === undefined || metadata === null ? undefined : metadata
  #|   )

///|
extern "js" fn languages_register_workspace_symbol_provider_ffi(
  provider : @providers.WorkspaceSymbolProviderObject[@vscode.SymbolInformation],
) -> &@vscode.Disposable =
  #| (provider) => require("vscode").languages.registerWorkspaceSymbolProvider(provider)

///|
extern "js" fn languages_register_reference_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.ReferenceProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerReferenceProvider(selector, provider)

///|
extern "js" fn languages_register_rename_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.RenameProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerRenameProvider(selector, provider)

///|
extern "js" fn languages_register_document_semantic_tokens_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentSemanticTokensProviderObject,
  legend : SemanticTokensLegend,
) -> &@vscode.Disposable =
  #| (selector, provider, legend) =>
  #|   require("vscode").languages.registerDocumentSemanticTokensProvider(selector, provider, legend)

///|
extern "js" fn languages_register_document_range_semantic_tokens_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentRangeSemanticTokensProviderObject,
  legend : SemanticTokensLegend,
) -> &@vscode.Disposable =
  #| (selector, provider, legend) =>
  #|   require("vscode").languages.registerDocumentRangeSemanticTokensProvider(selector, provider, legend)

///|
extern "js" fn languages_register_document_formatting_edit_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentFormattingEditProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) =>
  #|   require("vscode").languages.registerDocumentFormattingEditProvider(selector, provider)

///|
extern "js" fn languages_register_document_range_formatting_edit_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentRangeFormattingEditProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) =>
  #|   require("vscode").languages.registerDocumentRangeFormattingEditProvider(selector, provider)

///|
extern "js" fn languages_register_on_type_formatting_edit_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.OnTypeFormattingEditProviderObject,
  first_trigger_character : String,
  more_trigger_characters : @v.JsValue,
) -> &@vscode.Disposable =
  #| (selector, provider, firstTriggerCharacter, moreTriggerCharacters) => {
  #|   const rest = moreTriggerCharacters === undefined || moreTriggerCharacters === null
  #|     ? []
  #|     : moreTriggerCharacters;
  #|   return require("vscode").languages.registerOnTypeFormattingEditProvider(
  #|     selector,
  #|     provider,
  #|     firstTriggerCharacter,
  #|     ...rest
  #|   );
  #| }

///|
extern "js" fn languages_register_signature_help_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.SignatureHelpProviderObject,
  trigger_characters : @v.JsValue,
) -> &@vscode.Disposable =
  #| (selector, provider, triggerCharacters) => {
  #|   const chars = triggerCharacters === undefined || triggerCharacters === null
  #|     ? []
  #|     : triggerCharacters;
  #|   return require("vscode").languages.registerSignatureHelpProvider(
  #|     selector,
  #|     provider,
  #|     ...chars
  #|   );
  #| }

///|
extern "js" fn languages_register_signature_help_provider_metadata_ffi(
  selector : @v.JsValue,
  provider : @providers.SignatureHelpProviderObject,
  metadata : @v.JsValue,
) -> &@vscode.Disposable =
  #| (selector, provider, metadata) =>
  #|   require("vscode").languages.registerSignatureHelpProvider(
  #|     selector,
  #|     provider,
  #|     metadata
  #|   )

///|
extern "js" fn languages_register_document_link_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentLinkProviderObject[@vscode.DocumentLink],
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerDocumentLinkProvider(selector, provider)

///|
extern "js" fn languages_register_color_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentColorProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerColorProvider(selector, provider)

///|
extern "js" fn languages_register_inlay_hints_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.InlayHintsProviderObject[@vscode.InlayHint],
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerInlayHintsProvider(selector, provider)

///|
extern "js" fn languages_register_folding_range_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.FoldingRangeProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerFoldingRangeProvider(selector, provider)

///|
extern "js" fn languages_register_selection_range_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.SelectionRangeProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerSelectionRangeProvider(selector, provider)

///|
extern "js" fn languages_register_call_hierarchy_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.CallHierarchyProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerCallHierarchyProvider(selector, provider)

///|
extern "js" fn languages_register_type_hierarchy_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.TypeHierarchyProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerTypeHierarchyProvider(selector, provider)

///|
extern "js" fn languages_register_linked_editing_range_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.LinkedEditingRangeProviderObject,
) -> &@vscode.Disposable =
  #| (selector, provider) => require("vscode").languages.registerLinkedEditingRangeProvider(selector, provider)

///|
extern "js" fn languages_register_document_drop_edit_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentDropEditProviderObject,
  metadata : @v.JsValue,
) -> &@vscode.Disposable =
  #| (selector, provider, metadata) =>
  #|   require("vscode").languages.registerDocumentDropEditProvider(
  #|     selector,
  #|     provider,
  #|     metadata === undefined || metadata === null ? undefined : metadata
  #|   )

///|
extern "js" fn languages_register_document_paste_edit_provider_ffi(
  selector : @v.JsValue,
  provider : @providers.DocumentPasteEditProviderObject,
  metadata : @v.JsValue,
) -> &@vscode.Disposable =
  #| (selector, provider, metadata) =>
  #|   require("vscode").languages.registerDocumentPasteEditProvider(
  #|     selector,
  #|     provider,
  #|     metadata
  #|   )

///|
extern "js" fn languages_set_language_configuration_ffi(
  language : String,
  configuration : @v.JsValue,
) -> &@vscode.Disposable =
  #| (language, configuration) =>
  #|   require("vscode").languages.setLanguageConfiguration(language, configuration)
