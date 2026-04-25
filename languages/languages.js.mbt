///|
/// VS Code languages namespace bindings for the JS backend.
using @vscode {
  type CodeActionKind,
  type CancellationToken,
  type CodeActionProviderMetadata,
  type Diagnostic,
  type DiagnosticChangeEvent,
  type DiagnosticCollection,
  type DocumentDropOrPasteEditKind,
  type DocumentDropEditProviderMetadata,
  type DocumentPasteProviderMetadata,
  type DocumentSelector,
  type DocumentSymbolProviderMetadata,
  type Event,
  type LanguageStatusItem,
  type Position,
  type RegExp,
  type Range,
  type SemanticTokensLegend,
  type SignatureHelpProviderMetadata,
  type TextDocument,
  type Uri,
}

///|
fn document_selector_to_js(selector : DocumentSelector) -> @v.JsValue {
  match selector {
    Filter(value) => document_filter_to_js(value)
    Language(value) => @v.JsValue::make(value)
    Entries(values) => {
      let encoded : Array[@v.JsValue] = []
      for value in values {
        encoded.push(document_selector_entry_to_js(value))
      }
      @v.JsValue::make(encoded)
    }
  }
}

///|
fn document_selector_entry_to_js(
  value : @vscode.DocumentSelectorEntry,
) -> @v.JsValue {
  match value {
    Filter(value) => document_filter_to_js(value)
    Language(value) => @v.JsValue::make(value)
  }
}

///|
fn document_filter_to_js(value : @vscode.DocumentFilter) -> @v.JsValue {
  languages_document_filter_to_js_ffi(
    @v.option_to_js(value.language),
    @v.option_to_js(value.notebook_type),
    @v.option_to_js(value.scheme),
    option_glob_pattern_to_js(value.pattern),
  )
}

///|
fn option_glob_pattern_to_js(value : @vscode.GlobPattern?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => glob_pattern_to_js(value)
  }
}

///|
fn glob_pattern_to_js(value : @vscode.GlobPattern) -> @v.JsValue {
  match value {
    Text(value) => @v.JsValue::make(value)
    Relative(value) => @v.JsValue::make(value)
  }
}

///|
extern "js" fn languages_document_filter_to_js_ffi(
  language : @v.JsValue,
  notebook_type : @v.JsValue,
  scheme : @v.JsValue,
  pattern : @v.JsValue,
) -> @v.JsValue =
  #| (language, notebookType, scheme, pattern) => {
  #|   const filter = {};
  #|   if (language !== undefined && language !== null) filter.language = language;
  #|   if (notebookType !== undefined && notebookType !== null) {
  #|     filter.notebookType = notebookType;
  #|   }
  #|   if (scheme !== undefined && scheme !== null) filter.scheme = scheme;
  #|   if (pattern !== undefined && pattern !== null) filter.pattern = pattern;
  #|   return filter;
  #| }

///|
/// An EvaluatableExpression represents an expression in a document that can be evaluated by an active debugger or runtime.
/// The result of this evaluation is shown in a tooltip-like widget.
/// If only a range is specified, the expression will be extracted from the underlying document.
/// An optional expression can be used to override the extracted expression.
/// In this case the range is still used to highlight the range in the document.
pub type EvaluatableExpression

///|
/// The evaluatable expression provider interface defines the contract between extensions and
/// the debug hover. In this contract the provider returns an evaluatable expression for a given position
/// in a document and the editor evaluates this expression in the active debug session and shows the result in a debug hover.
pub type EvaluatableExpressionProvider

///|
/// The language configuration interfaces defines the contract between extensions
/// and various editor features, like automatic bracket insertion, automatic indentation etc.
pub(all) struct LanguageConfiguration {
  mut comments : CommentRule?
  mut brackets : Array[CharacterPair]?
  mut word_pattern : RegExp?
  mut indentation_rules : IndentationRule?
  mut on_enter_rules : Array[OnEnterRule]?
  mut auto_closing_pairs : Array[AutoClosingPair]?
}

///|
/// A tuple of two characters, like a pair of
/// opening and closing brackets.
pub struct CharacterPair {
  open : String
  close : String
}

///|
/// Describes how comments for a language work.
pub(all) struct CommentRule {
  mut line_comment : String?
  mut block_comment : CharacterPair?
}

///|
/// Describes indentation rules for a language.
pub(all) struct IndentationRule {
  mut decrease_indent_pattern : RegExp
  mut increase_indent_pattern : RegExp
  mut indent_next_line_pattern : RegExp?
  mut un_indented_line_pattern : RegExp?
}

///|
pub(all) enum IndentAction {
  None = 0
  Indent = 1
  IndentOutdent = 2
  Outdent = 3
} derive(Eq)

///|
/// Describes what to do when pressing Enter.
pub(all) struct EnterAction {
  mut indent_action : IndentAction
  mut append_text : String?
  mut remove_text : Int?
}

///|
/// Describes a rule to be evaluated when pressing Enter.
pub(all) struct OnEnterRule {
  mut before_text : RegExp
  mut action : EnterAction
  mut after_text : RegExp?
  mut previous_line_text : RegExp?
}

///|
pub(all) enum SyntaxTokenType {
  Other = 0
  Comment = 1
  String = 2
  RegEx = 3
} derive(Eq)

///|
/// Describes pairs of strings where the close string will be automatically inserted when typing the opening string.
pub(all) struct AutoClosingPair {
  mut open : String
  mut close : String
  mut not_in : Array[SyntaxTokenType]?
}

///|
fn[T : @vscode.CompletionItemProvider] completion_item_provider_object(
  provider : T,
) -> @providers.CompletionItemProviderObject[@vscode.CompletionItem] {
  @providers.CompletionItemProviderObject::new_items(
    async fn(document, position, token, context) {
      provider.provide_completion_items(document, position, token, context)
    },
    resolve_item=async fn(item, token) {
      provider.resolve_completion_item(item, token)
    },
  )
}

///|
fn[T : @vscode.InlineCompletionItemProvider] inline_completion_item_provider_object(
  provider : T,
) -> @providers.InlineCompletionItemProviderObject {
  @providers.InlineCompletionItemProviderObject::new_items(async fn(
    document,
    position,
    context,
    token,
  ) {
    provider.provide_inline_completion_items(document, position, context, token)
  })
}

///|
fn[T : @vscode.CodeActionProvider] code_action_provider_object(
  provider : T,
) -> @providers.CodeActionProviderObject[@vscode.CodeAction] {
  @providers.CodeActionProviderObject::new(
    async fn(document, range, context, token) {
      provider.provide_code_actions(document, range, context, token)
    },
    resolve_action=async fn(action, token) {
      provider.resolve_code_action(action, token)
    },
  )
}

///|
fn code_action_provider_metadata_to_js(
  metadata : CodeActionProviderMetadata,
) -> @v.JsValue {
  languages_code_action_provider_metadata_to_js_ffi(
    option_code_action_kind_array_to_js(metadata.provided_kinds),
  )
}

///|
fn option_code_action_kind_array_to_js(
  values : Array[CodeActionKind]?,
) -> @v.JsValue {
  match values {
    None => @v.JsValue::make(())
    Some(values) => @v.JsValue::make(code_action_kind_array_to_js(values))
  }
}

///|
fn code_action_kind_array_to_js(
  values : Array[CodeActionKind],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(code_action_kind_to_js(value))
  }
  encoded
}

///|
fn code_action_kind_to_js(value : CodeActionKind) -> @v.JsValue {
  languages_code_action_kind_to_js_ffi(value.value())
}

///|
extern "js" fn languages_code_action_kind_to_js_ffi(
  value : String,
) -> @v.JsValue =
  #| (value) => {
  #|   const kind = require("vscode").CodeActionKind;
  #|   if (value === "") return kind.Empty;
  #|   let result = kind.Empty;
  #|   for (const part of value.split(".")) {
  #|     if (part.length === 0) continue;
  #|     result = result.append(part);
  #|   }
  #|   return result;
  #| }

///|
extern "js" fn languages_code_action_provider_metadata_to_js_ffi(
  provided_kinds : @v.JsValue,
) -> @v.JsValue =
  #| (providedCodeActionKinds) => {
  #|   const metadata = {};
  #|   if (providedCodeActionKinds !== undefined && providedCodeActionKinds !== null) {
  #|     if (providedCodeActionKinds.length > 0) {
  #|       metadata.providedCodeActionKinds = providedCodeActionKinds;
  #|     }
  #|   }
  #|   return metadata;
  #| }

///|
fn[T : @vscode.CodeLensProvider] code_lens_provider_object(
  provider : T,
) -> @providers.CodeLensProviderObject[@vscode.CodeLens] {
  match provider.on_did_change_code_lenses() {
    None =>
      @providers.CodeLensProviderObject::new(
        async fn(document, token) {
          provider.provide_code_lenses(document, token)
        },
        resolve_lens=async fn(lens, token) {
          provider.resolve_code_lens(lens, token)
        },
      )
    Some(event) =>
      @providers.CodeLensProviderObject::new(
        async fn(document, token) {
          provider.provide_code_lenses(document, token)
        },
        resolve_lens=async fn(lens, token) {
          provider.resolve_code_lens(lens, token)
        },
        on_did_change=event,
      )
  }
}

///|
fn[T : @vscode.DefinitionProvider] definition_provider_object(
  provider : T,
) -> @providers.DefinitionProviderObject {
  @providers.DefinitionProviderObject::new_locations(async fn(
    document,
    position,
    token,
  ) {
    provider.provide_definition(document, position, token)
  })
}

///|
fn[T : @vscode.ImplementationProvider] implementation_provider_object(
  provider : T,
) -> @providers.ImplementationProviderObject {
  @providers.ImplementationProviderObject::new_locations(async fn(
    document,
    position,
    token,
  ) {
    provider.provide_implementation(document, position, token)
  })
}

///|
fn[T : @vscode.TypeDefinitionProvider] type_definition_provider_object(
  provider : T,
) -> @providers.TypeDefinitionProviderObject {
  @providers.TypeDefinitionProviderObject::new_locations(async fn(
    document,
    position,
    token,
  ) {
    provider.provide_type_definition(document, position, token)
  })
}

///|
fn[T : @vscode.DeclarationProvider] declaration_provider_object(
  provider : T,
) -> @providers.DeclarationProviderObject {
  @providers.DeclarationProviderObject::new_locations(async fn(
    document,
    position,
    token,
  ) {
    provider.provide_declaration(document, position, token)
  })
}

///|
fn[T : @vscode.HoverProvider] hover_provider_object(
  provider : T,
) -> @providers.HoverProviderObject {
  @providers.HoverProviderObject::new(async fn(document, position, token) {
    provider.provide_hover(document, position, token)
  })
}

///|
fn[T : @vscode.InlineValuesProvider] inline_values_provider_object(
  provider : T,
) -> @providers.InlineValuesProviderObject {
  @providers.InlineValuesProviderObject::new(async fn(
    document,
    range,
    context,
    token,
  ) {
    provider.provide_inline_values(document, range, context, token)
  })
}

///|
fn[T : @vscode.DocumentHighlightProvider] document_highlight_provider_object(
  provider : T,
) -> @providers.DocumentHighlightProviderObject {
  @providers.DocumentHighlightProviderObject::new(async fn(
    document,
    position,
    token,
  ) {
    provider.provide_document_highlights(document, position, token)
  })
}

///|
fn[T : @vscode.DocumentSymbolProvider] document_symbol_provider_object(
  provider : T,
) -> @providers.DocumentSymbolProviderObject {
  @providers.DocumentSymbolProviderObject::new_symbols(async fn(
    document,
    token,
  ) {
    provider.provide_document_symbols(document, token)
  })
}

///|
fn document_symbol_provider_metadata_to_js(
  metadata : DocumentSymbolProviderMetadata,
) -> @v.JsValue {
  languages_document_symbol_provider_metadata_to_js_ffi(
    @v.option_to_js(metadata.label),
  )
}

///|
extern "js" fn languages_document_symbol_provider_metadata_to_js_ffi(
  label : @v.JsValue,
) -> @v.JsValue =
  #| (label) => {
  #|   const metadata = {};
  #|   if (label !== undefined && label !== null) {
  #|     metadata.label = label;
  #|   }
  #|   return metadata;
  #| }

///|
fn[T : @vscode.WorkspaceSymbolProvider] workspace_symbol_provider_object(
  provider : T,
) -> @providers.WorkspaceSymbolProviderObject[@vscode.SymbolInformation] {
  @providers.WorkspaceSymbolProviderObject::new(
    async fn(query, token) { provider.provide_workspace_symbols(query, token) },
    resolve_symbol=async fn(symbol, token) {
      provider.resolve_workspace_symbol(symbol, token)
    },
  )
}

///|
fn[T : @vscode.ReferenceProvider] reference_provider_object(
  provider : T,
) -> @providers.ReferenceProviderObject {
  @providers.ReferenceProviderObject::new(async fn(
    document,
    position,
    context,
    token,
  ) {
    provider.provide_references(document, position, context, token)
  })
}

///|
fn[T : @vscode.RenameProvider] rename_provider_object(
  provider : T,
) -> @providers.RenameProviderObject {
  @providers.RenameProviderObject::new(
    async fn(document, position, new_name, token) {
      provider.provide_rename_edits(document, position, new_name, token)
    },
    prepare_rename=async fn(document, position, token) {
      provider.prepare_rename(document, position, token)
    },
  )
}

///|
fn[T : @vscode.DocumentSemanticTokensProvider] document_semantic_tokens_provider_object(
  provider : T,
) -> @providers.DocumentSemanticTokensProviderObject {
  let provide_edits = provider.provide_document_semantic_tokens_edits()
  let on_did_change = provider.on_did_change_semantic_tokens()
  match provide_edits {
    None =>
      match on_did_change {
        None =>
          @providers.DocumentSemanticTokensProviderObject::new(async fn(
            document,
            token,
          ) {
            provider.provide_document_semantic_tokens(document, token)
          })
        Some(event) =>
          @providers.DocumentSemanticTokensProviderObject::new(
            async fn(document, token) {
              provider.provide_document_semantic_tokens(document, token)
            },
            on_did_change=event,
          )
      }
    Some(edits) =>
      match on_did_change {
        None =>
          @providers.DocumentSemanticTokensProviderObject::new(
            async fn(document, token) {
              provider.provide_document_semantic_tokens(document, token)
            },
            provide_edits=edits,
          )
        Some(event) =>
          @providers.DocumentSemanticTokensProviderObject::new(
            async fn(document, token) {
              provider.provide_document_semantic_tokens(document, token)
            },
            provide_edits=edits,
            on_did_change=event,
          )
      }
  }
}

///|
fn[T : @vscode.DocumentRangeSemanticTokensProvider] document_range_semantic_tokens_provider_object(
  provider : T,
) -> @providers.DocumentRangeSemanticTokensProviderObject {
  @providers.DocumentRangeSemanticTokensProviderObject::new(async fn(
    document,
    range,
    token,
  ) {
    provider.provide_document_range_semantic_tokens(document, range, token)
  })
}

///|
fn[T : @vscode.DocumentFormattingEditProvider] document_formatting_edit_provider_object(
  provider : T,
) -> @providers.DocumentFormattingEditProviderObject {
  @providers.DocumentFormattingEditProviderObject::new(async fn(
    document,
    options,
    token,
  ) {
    provider.provide_document_formatting_edits(document, options, token)
  })
}

///|
fn[T : @vscode.DocumentRangeFormattingEditProvider] document_range_formatting_edit_provider_object(
  provider : T,
) -> @providers.DocumentRangeFormattingEditProviderObject {
  @providers.DocumentRangeFormattingEditProviderObject::new(async fn(
    document,
    range,
    options,
    token,
  ) {
    provider.provide_document_range_formatting_edits(
      document, range, options, token,
    )
  })
}

///|
fn[T : @vscode.OnTypeFormattingEditProvider] on_type_formatting_edit_provider_object(
  provider : T,
) -> @providers.OnTypeFormattingEditProviderObject {
  @providers.OnTypeFormattingEditProviderObject::new(async fn(
    document,
    position,
    ch,
    options,
    token,
  ) {
    provider.provide_on_type_formatting_edits(
      document, position, ch, options, token,
    )
  })
}

///|
fn[T : @vscode.SignatureHelpProvider] signature_help_provider_object(
  provider : T,
) -> @providers.SignatureHelpProviderObject {
  @providers.SignatureHelpProviderObject::new(async fn(
    document,
    position,
    token,
    context,
  ) {
    provider.provide_signature_help(document, position, token, context)
  })
}

///|
fn signature_help_provider_metadata_to_js(
  metadata : SignatureHelpProviderMetadata,
) -> @v.JsValue {
  languages_signature_help_provider_metadata_to_js_ffi(
    metadata.trigger_characters,
    @v.option_to_js(metadata.retrigger_characters),
  )
}

///|
extern "js" fn languages_signature_help_provider_metadata_to_js_ffi(
  trigger_characters : Array[String],
  retrigger_characters : @v.JsValue,
) -> @v.JsValue =
  #| (triggerCharacters, retriggerCharacters) => {
  #|   const metadata = { triggerCharacters };
  #|   if (retriggerCharacters !== undefined && retriggerCharacters !== null) {
  #|     metadata.retriggerCharacters = retriggerCharacters;
  #|   }
  #|   return metadata;
  #| }

///|
fn[T : @vscode.DocumentLinkProvider] document_link_provider_object(
  provider : T,
) -> @providers.DocumentLinkProviderObject[@vscode.DocumentLink] {
  @providers.DocumentLinkProviderObject::new(
    async fn(document, token) {
      provider.provide_document_links(document, token)
    },
    resolve_link=async fn(link, token) {
      provider.resolve_document_link(link, token)
    },
  )
}

///|
fn[T : @vscode.DocumentColorProvider] document_color_provider_object(
  provider : T,
) -> @providers.DocumentColorProviderObject {
  @providers.DocumentColorProviderObject::new(
    async fn(document, token) {
      provider.provide_document_colors(document, token)
    },
    async fn(color, context, token) {
      provider.provide_color_presentations(color, context, token)
    },
  )
}

///|
fn[T : @vscode.InlayHintsProvider] inlay_hints_provider_object(
  provider : T,
) -> @providers.InlayHintsProviderObject[@vscode.InlayHint] {
  @providers.InlayHintsProviderObject::new(
    async fn(document, range, token) {
      provider.provide_inlay_hints(document, range, token)
    },
    resolve_hint=async fn(hint, token) {
      provider.resolve_inlay_hint(hint, token)
    },
  )
}

///|
fn[T : @vscode.FoldingRangeProvider] folding_range_provider_object(
  provider : T,
) -> @providers.FoldingRangeProviderObject {
  @providers.FoldingRangeProviderObject::new(async fn(
    document,
    context,
    token,
  ) {
    provider.provide_folding_ranges(document, context, token)
  })
}

///|
fn[T : @vscode.SelectionRangeProvider] selection_range_provider_object(
  provider : T,
) -> @providers.SelectionRangeProviderObject {
  @providers.SelectionRangeProviderObject::new(async fn(
    document,
    positions,
    token,
  ) {
    provider.provide_selection_ranges(document, positions, token)
  })
}

///|
fn[T : @vscode.CallHierarchyProvider] call_hierarchy_provider_object(
  provider : T,
) -> @providers.CallHierarchyProviderObject {
  @providers.CallHierarchyProviderObject::new_items(
    async fn(document, position, token) {
      provider.prepare_call_hierarchy(document, position, token)
    },
    async fn(item, token) {
      provider.provide_call_hierarchy_incoming_calls(item, token)
    },
    async fn(item, token) {
      provider.provide_call_hierarchy_outgoing_calls(item, token)
    },
  )
}

///|
fn[T : @vscode.TypeHierarchyProvider] type_hierarchy_provider_object(
  provider : T,
) -> @providers.TypeHierarchyProviderObject {
  @providers.TypeHierarchyProviderObject::new_items(
    async fn(document, position, token) {
      provider.prepare_type_hierarchy(document, position, token)
    },
    async fn(item, token) {
      provider.provide_type_hierarchy_supertypes(item, token)
    },
    async fn(item, token) {
      provider.provide_type_hierarchy_subtypes(item, token)
    },
  )
}

///|
fn[T : @vscode.LinkedEditingRangeProvider] linked_editing_range_provider_object(
  provider : T,
) -> @providers.LinkedEditingRangeProviderObject {
  @providers.LinkedEditingRangeProviderObject::new(async fn(
    document,
    position,
    token,
  ) {
    provider.provide_linked_editing_ranges(document, position, token)
  })
}

///|
fn[T : @vscode.DocumentDropEditProvider] document_drop_edit_provider_object(
  provider : T,
) -> @providers.DocumentDropEditProviderObject {
  match provider.metadata() {
    None =>
      @providers.DocumentDropEditProviderObject::new(async fn(
        document,
        position,
        data_transfer,
        token,
      ) {
        provider.provide_document_drop_edits(
          document, position, data_transfer, token,
        )
      })
    Some(metadata) =>
      @providers.DocumentDropEditProviderObject::new(
        async fn(document, position, data_transfer, token) {
          provider.provide_document_drop_edits(
            document, position, data_transfer, token,
          )
        },
        metadata~,
      )
  }
}

///|
fn[T : @vscode.DocumentPasteEditProvider] document_paste_edit_provider_object(
  provider : T,
) -> @providers.DocumentPasteEditProviderObject {
  match provider.metadata() {
    None =>
      @providers.DocumentPasteEditProviderObject::new(async fn(
        document,
        ranges,
        data_transfer,
        context,
        token,
      ) {
        provider.provide_document_paste_edits(
          document, ranges, data_transfer, context, token,
        )
      })
    Some(metadata) =>
      @providers.DocumentPasteEditProviderObject::new(
        async fn(document, ranges, data_transfer, context, token) {
          provider.provide_document_paste_edits(
            document, ranges, data_transfer, context, token,
          )
        },
        metadata~,
      )
  }
}

///|
fn document_drop_or_paste_edit_kind_values(
  kinds : Array[DocumentDropOrPasteEditKind],
) -> Array[String] {
  let values : Array[String] = []
  for kind in kinds {
    values.push(kind.value())
  }
  values
}

///|
fn document_drop_edit_provider_metadata_to_js(
  metadata : DocumentDropEditProviderMetadata,
) -> @v.JsValue {
  let provided_kind_values : Array[String]? = match metadata.provided_kinds {
    None => None
    Some(value) => Some(document_drop_or_paste_edit_kind_values(value))
  }
  languages_document_drop_edit_provider_metadata_to_js_ffi(
    @v.option_to_js(provided_kind_values),
    metadata.drop_mime_types,
  )
}

///|
fn document_paste_provider_metadata_to_js(
  metadata : DocumentPasteProviderMetadata,
) -> @v.JsValue {
  languages_document_paste_provider_metadata_to_js_ffi(
    document_drop_or_paste_edit_kind_values(metadata.provided_kinds),
    @v.option_to_js(metadata.copy_mime_types),
    @v.option_to_js(metadata.paste_mime_types),
  )
}

///|
extern "js" fn languages_document_drop_edit_provider_metadata_to_js_ffi(
  provided_kind_values : @v.JsValue,
  drop_mime_types : Array[String],
) -> @v.JsValue =
  #| (providedKindValues, dropMimeTypes) => {
  #|   const kind = require("vscode").DocumentDropOrPasteEditKind;
  #|   const kindFromValue = (value) => {
  #|     if (value === "") return kind.Empty;
  #|     if (value === "text") return kind.Text;
  #|     if (value === "text.updateImports") return kind.TextUpdateImports;
  #|     let result = kind.Empty;
  #|     for (const part of value.split(".")) {
  #|       if (part.length === 0) continue;
  #|       result = result.append(part);
  #|     }
  #|     return result;
  #|   };
  #|   const metadata = { dropMimeTypes };
  #|   if (providedKindValues !== undefined && providedKindValues !== null) {
  #|     const values = providedKindValues;
  #|     if (values.length > 0) {
  #|       metadata.providedDropEditKinds = values.map(kindFromValue);
  #|     }
  #|   }
  #|   return metadata;
  #| }

///|
extern "js" fn languages_document_paste_provider_metadata_to_js_ffi(
  provided_kind_values : Array[String],
  copy_mime_types : @v.JsValue,
  paste_mime_types : @v.JsValue,
) -> @v.JsValue =
  #| (providedKindValues, copyMimeTypes, pasteMimeTypes) => {
  #|   const kind = require("vscode").DocumentDropOrPasteEditKind;
  #|   const kindFromValue = (value) => {
  #|     if (value === "") return kind.Empty;
  #|     if (value === "text") return kind.Text;
  #|     if (value === "text.updateImports") return kind.TextUpdateImports;
  #|     let result = kind.Empty;
  #|     for (const part of value.split(".")) {
  #|       if (part.length === 0) continue;
  #|       result = result.append(part);
  #|     }
  #|     return result;
  #|   };
  #|   const metadata = {
  #|     providedPasteEditKinds: providedKindValues.map(kindFromValue),
  #|   };
  #|   if (copyMimeTypes !== undefined && copyMimeTypes !== null) {
  #|     const values = copyMimeTypes;
  #|     if (values.length > 0) {
  #|       metadata.copyMimeTypes = values;
  #|     }
  #|   }
  #|   if (pasteMimeTypes !== undefined && pasteMimeTypes !== null) {
  #|     const values = pasteMimeTypes;
  #|     if (values.length > 0) {
  #|       metadata.pasteMimeTypes = values;
  #|     }
  #|   }
  #|   return metadata;
  #| }

///|
/// Creates a new evaluatable expression object.
///
/// @param range The range in the underlying document from which the evaluatable expression is extracted.
/// @param expression If specified overrides the extracted expression.
pub fn EvaluatableExpression::new(
  range : Range,
  expression? : String,
) -> EvaluatableExpression {
  languages_evaluatable_expression_ffi(range, @v.option_to_js(expression))
}

///|
/// The range is used to extract the evaluatable expression from the underlying document and to highlight it.
pub extern "js" fn EvaluatableExpression::range(
  self : EvaluatableExpression,
) -> Range =
  #| (value) => value.range

///|
/// If specified the expression overrides the extracted expression.
pub fn EvaluatableExpression::expression(
  self : EvaluatableExpression,
) -> String? {
  let raw = evaluatable_expression_expression_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn EvaluatableExpressionProvider::new(
  provide_expression : async (TextDocument, Position, CancellationToken) -> EvaluatableExpression?,
) -> EvaluatableExpressionProvider {
  languages_evaluatable_expression_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      option_evaluatable_expression_to_js(
        provide_expression(document, position, token),
      )
    })
  })
}

///|
pub fn LanguageConfiguration::empty() -> LanguageConfiguration {
  LanguageConfiguration::{
    comments: None,
    brackets: None,
    word_pattern: None,
    indentation_rules: None,
    on_enter_rules: None,
    auto_closing_pairs: None,
  }
}

///|
pub fn CharacterPair::new(open : String, close : String) -> CharacterPair {
  CharacterPair::{ open, close }
}

///|

///|

///|
pub fn CommentRule::new(
  line_comment? : String,
  block_comment? : CharacterPair,
) -> CommentRule {
  CommentRule::{ line_comment, block_comment }
}

///|
/// The line comment token, like `// this is a comment`

///|
/// The block comment character pair, like `/* block comment *&#47;`

///|
pub fn IndentationRule::new(
  decrease_indent_pattern : RegExp,
  increase_indent_pattern : RegExp,
  indent_next_line_pattern? : RegExp,
  un_indented_line_pattern? : RegExp,
) -> IndentationRule {
  IndentationRule::{
    decrease_indent_pattern,
    increase_indent_pattern,
    indent_next_line_pattern,
    un_indented_line_pattern,
  }
}

///|
/// If a line matches this pattern, then all the lines after it should be unindented once (until another rule matches).

///|
/// If a line matches this pattern, then all the lines after it should be indented once (until another rule matches).

///|
/// If a line matches this pattern, then **only the next line** after it should be indented once.

///|
/// If a line matches this pattern, then its indentation should not be changed and it should not be evaluated against the other rules.

///|
pub fn EnterAction::new(
  indent_action : IndentAction,
  append_text? : String,
  remove_text? : Int,
) -> EnterAction {
  EnterAction::{ indent_action, append_text, remove_text }
}

///|
/// Describe what to do with the indentation.

///|
/// Describes text to be appended after the new line and after the indentation.

///|
/// Describes the number of characters to remove from the new line's indentation.

///|
pub fn OnEnterRule::new(
  before_text : RegExp,
  action : EnterAction,
  after_text? : RegExp,
  previous_line_text? : RegExp,
) -> OnEnterRule {
  OnEnterRule::{ before_text, action, after_text, previous_line_text }
}

///|
/// This rule will only execute if the text before the cursor matches this regular expression.

///|
/// This rule will only execute if the text after the cursor matches this regular expression.

///|
/// This rule will only execute if the text above the current line matches this regular expression.

///|
/// The action to execute.

///|
pub fn AutoClosingPair::new(
  open : String,
  close : String,
  not_in? : Array[SyntaxTokenType],
) -> AutoClosingPair {
  AutoClosingPair::{ open, close, not_in }
}

///|
/// The string that will trigger the automatic insertion of the closing string.

///|
/// The closing string that will be automatically inserted when typing the opening string.

///|
/// A set of tokens where the pair should not be auto closed.

///|
pub fn LanguageConfiguration::new(
  comments? : CommentRule,
  brackets? : Array[CharacterPair],
  word_pattern? : RegExp,
  indentation_rules? : IndentationRule,
  on_enter_rules? : Array[OnEnterRule],
  auto_closing_pairs? : Array[AutoClosingPair],
) -> LanguageConfiguration {
  LanguageConfiguration::{
    comments,
    brackets,
    word_pattern,
    indentation_rules,
    on_enter_rules,
    auto_closing_pairs,
  }
}

///|
fn option_evaluatable_expression_to_js(
  value : EvaluatableExpression?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => evaluatable_expression_to_js(value)
  }
}

///|
fn evaluatable_expression_to_js(value : EvaluatableExpression) -> @v.JsValue {
  @v.JsValue::make(
    languages_evaluatable_expression_ffi(
      value.range(),
      @v.option_to_js(value.expression()),
    ),
  )
}

///|
extern "js" fn evaluatable_expression_expression_raw(
  value : EvaluatableExpression,
) -> @v.JsValue =
  #| (value) => value.expression

///|
fn character_pair_to_js(value : CharacterPair) -> @v.JsValue {
  character_pair_ffi(value.open, value.close)
}

///|
fn option_character_pair_to_js(value : CharacterPair?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => character_pair_to_js(value)
  }
}

///|
fn comment_rule_to_js(value : CommentRule) -> @v.JsValue {
  comment_rule_ffi(
    @v.option_to_js(value.line_comment),
    option_character_pair_to_js(value.block_comment),
  )
}

///|
fn option_comment_rule_to_js(value : CommentRule?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => comment_rule_to_js(value)
  }
}

///|
fn indentation_rule_to_js(value : IndentationRule) -> @v.JsValue {
  indentation_rule_ffi(
    value.decrease_indent_pattern,
    value.increase_indent_pattern,
    @v.option_to_js(value.indent_next_line_pattern),
    @v.option_to_js(value.un_indented_line_pattern),
  )
}

///|
fn option_indentation_rule_to_js(value : IndentationRule?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => indentation_rule_to_js(value)
  }
}

///|
fn enter_action_to_js(value : EnterAction) -> @v.JsValue {
  enter_action_ffi(
    value.indent_action,
    @v.option_to_js(value.append_text),
    @v.option_to_js(value.remove_text),
  )
}

///|
fn on_enter_rule_to_js(value : OnEnterRule) -> @v.JsValue {
  on_enter_rule_ffi(
    value.before_text,
    @v.option_to_js(value.after_text),
    @v.option_to_js(value.previous_line_text),
    enter_action_to_js(value.action),
  )
}

///|
fn auto_closing_pair_to_js(value : AutoClosingPair) -> @v.JsValue {
  auto_closing_pair_ffi(value.open, value.close, @v.option_to_js(value.not_in))
}

///|
fn[T] array_to_js(
  values : Array[T],
  encode : (T) -> @v.JsValue,
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(encode(value))
  }
  encoded
}

///|
fn[T] option_array_to_js(
  values : Array[T]?,
  encode : (T) -> @v.JsValue,
) -> @v.JsValue {
  match values {
    None => @v.JsValue::make(())
    Some(values) => @v.JsValue::make(array_to_js(values, encode))
  }
}

///|
fn language_configuration_to_js(value : LanguageConfiguration) -> @v.JsValue {
  language_configuration_with_parts_ffi(
    option_comment_rule_to_js(value.comments),
    option_array_to_js(value.brackets, character_pair_to_js),
    @v.option_to_js(value.word_pattern),
    option_indentation_rule_to_js(value.indentation_rules),
    option_array_to_js(value.on_enter_rules, on_enter_rule_to_js),
    option_array_to_js(value.auto_closing_pairs, auto_closing_pair_to_js),
  )
}

///|
/// Return the identifiers of all known languages.
/// @returns Promise resolving to an array of identifier strings.
pub async fn get_languages() -> Array[String] {
  @js_async.Promise::wait(languages_get_languages_ffi())
}

///|
/// Create a diagnostics collection.
///
/// @param name The {@link DiagnosticCollection.name name} of the collection.
/// @returns A new diagnostic collection.
pub fn create_diagnostic_collection(name? : String) -> DiagnosticCollection {
  languages_create_diagnostic_collection_ffi(@v.option_to_js(name))
}

///|
/// An {@link Event} which fires when the global set of diagnostics changes. This is
/// newly added and removed diagnostics.
pub fn on_did_change_diagnostics() -> Event[DiagnosticChangeEvent] {
  languages_on_did_change_diagnostics_ffi()
}

///|
/// Get all diagnostics for a given resource.
///
/// @param resource A resource
/// @returns An array of {@link Diagnostic diagnostics} objects or an empty array.
pub fn get_diagnostics(uri : Uri) -> Array[Diagnostic] {
  languages_get_diagnostics_ffi(uri)
}

///|
pub fn get_all_diagnostics() -> Array[(Uri, Array[Diagnostic])] {
  languages_get_all_diagnostics_ffi()
}

///|
/// Creates a new {@link LanguageStatusItem language status item}.
///
/// @param id The identifier of the item.
/// @param selector The document selector that defines for what editors the item shows.
/// @returns A new language status item.
pub fn create_language_status_item(
  id : String,
  selector : DocumentSelector,
) -> LanguageStatusItem {
  languages_create_language_status_item_ffi(
    id,
    document_selector_to_js(selector),
  )
}

///|
/// Compute the match between a document {@link DocumentSelector selector} and a document. Values
/// greater than zero mean the selector matches the document.
///
/// A match is computed according to these rules:
/// 1. When {@linkcode DocumentSelector} is an array, compute the match for each contained `DocumentFilter` or language identifier and take the maximum value.
/// 2. A string will be desugared to become the `language`-part of a {@linkcode DocumentFilter}, so `"fooLang"` is like `{ language: "fooLang" }`.
/// 3. A {@linkcode DocumentFilter} will be matched against the document by comparing its parts with the document. The following rules apply:
///    1. When the `DocumentFilter` is empty (`{}`) the result is `0`
///    2. When `scheme`, `language`, `pattern`, or `notebook` are defined but one doesn't match, the result is `0`
///    3. Matching against `*` gives a score of `5`, matching via equality or via a glob-pattern gives a score of `10`
///    4. The result is the maximum value of each match
///
/// Samples:
/// ```js
/// // default document from disk (file-scheme)
/// doc.uri; //'file:///my/file.js'
/// doc.languageId; // 'javascript'
/// match('javascript', doc); // 10;
/// match({ language: 'javascript' }, doc); // 10;
/// match({ language: 'javascript', scheme: 'file' }, doc); // 10;
/// match('*', doc); // 5
/// match('fooLang', doc); // 0
/// match(['fooLang', '*'], doc); // 5
///
/// // virtual document, e.g. from git-index
/// doc.uri; // 'git:/my/file.js'
/// doc.languageId; // 'javascript'
/// match('javascript', doc); // 10;
/// match({ language: 'javascript', scheme: 'git' }, doc); // 10;
/// match('*', doc); // 5
///
/// // notebook cell document
/// doc.uri; // `vscode-notebook-cell:///my/notebook.ipynb#gl65s2pmha`;
/// doc.languageId; // 'python'
/// match({ notebookType: 'jupyter-notebook' }, doc) // 10
/// match({ notebookType: 'fooNotebook', language: 'python' }, doc) // 0
/// match({ language: 'python' }, doc) // 10
/// match({ notebookType: '*' }, doc) // 5
/// ```
///
/// @param selector A document selector.
/// @param document A text document.
/// @returns A number `>0` when the selector matches and `0` when the selector does not match.
pub fn match_document(
  selector : DocumentSelector,
  document : TextDocument,
) -> Int {
  languages_match_ffi(document_selector_to_js(selector), document)
}

///|
/// Set (and change) the {@link TextDocument.languageId language} that is associated
/// with the given document.
///
/// *Note* that calling this function will trigger the {@linkcode workspace.onDidCloseTextDocument onDidCloseTextDocument} event
/// followed by the {@linkcode workspace.onDidOpenTextDocument onDidOpenTextDocument} event.
///
/// @param document The document which language is to be changed
/// @param languageId The new language identifier.
/// @returns A thenable that resolves with the updated document.
pub async fn set_text_document_language(
  document : TextDocument,
  language_id : String,
) -> TextDocument {
  @js_async.Promise::wait(
    languages_set_text_document_language_ffi(document, language_id),
  )
}

///|
/// Register a completion provider.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and groups of equal score are sequentially asked for
/// completion items. The process stops when one or many providers of a group return a
/// result. A failing provider (rejected promise or exception) will not fail the whole
/// operation.
///
/// A completion item provider can be associated with a set of `triggerCharacters`. When trigger
/// characters are being typed, completions are requested but only from providers that registered
/// the typed character. Because of that trigger characters should be different than {@link LanguageConfiguration.wordPattern word characters},
/// a common trigger character is `.` to trigger member completions.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A completion provider.
/// @param triggerCharacters Trigger completion when the user types one of the characters.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.CompletionItemProvider] register_completion_item_provider(
  selector : DocumentSelector,
  provider : T,
  trigger_characters? : Array[String],
) -> @vscode.Disposable {
  languages_register_completion_item_provider_ffi(
    document_selector_to_js(selector),
    completion_item_provider_object(provider),
    @v.option_to_js(trigger_characters),
  )
}

///|
/// Registers an inline completion provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider An inline completion provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.InlineCompletionItemProvider] register_inline_completion_item_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_inline_completion_item_provider_ffi(
    document_selector_to_js(selector),
    inline_completion_item_provider_object(provider),
  )
}

///|
/// Register a code action provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A code action provider.
/// @param metadata Metadata about the kind of code actions the provider provides.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.CodeActionProvider] register_code_actions_provider(
  selector : DocumentSelector,
  provider : T,
  metadata? : CodeActionProviderMetadata,
) -> @vscode.Disposable {
  let metadata_js = match metadata {
    None => @v.JsValue::make(())
    Some(value) => code_action_provider_metadata_to_js(value)
  }
  languages_register_code_actions_provider_ffi(
    document_selector_to_js(selector),
    code_action_provider_object(provider),
    metadata_js,
  )
}

///|
/// Register a code lens provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A code lens provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.CodeLensProvider] register_code_lens_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_code_lens_provider_ffi(
    document_selector_to_js(selector),
    code_lens_provider_object(provider),
  )
}

///|
/// Register a definition provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A definition provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DefinitionProvider] register_definition_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_definition_provider_ffi(
    document_selector_to_js(selector),
    definition_provider_object(provider),
  )
}

///|
/// Register an implementation provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider An implementation provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.ImplementationProvider] register_implementation_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_implementation_provider_ffi(
    document_selector_to_js(selector),
    implementation_provider_object(provider),
  )
}

///|
/// Register a type definition provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A type definition provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.TypeDefinitionProvider] register_type_definition_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_type_definition_provider_ffi(
    document_selector_to_js(selector),
    type_definition_provider_object(provider),
  )
}

///|
/// Register a declaration provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A declaration provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DeclarationProvider] register_declaration_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_declaration_provider_ffi(
    document_selector_to_js(selector),
    declaration_provider_object(provider),
  )
}

///|
/// Register a hover provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A hover provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.HoverProvider] register_hover_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_hover_provider_ffi(
    document_selector_to_js(selector),
    hover_provider_object(provider),
  )
}

///|
/// Register a provider that locates evaluatable expressions in text documents.
/// The editor will evaluate the expression in the active debug session and will show the result in the debug hover.
///
/// If multiple providers are registered for a language an arbitrary provider will be used.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider An evaluatable expression provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn register_evaluatable_expression_provider(
  selector : DocumentSelector,
  provider : EvaluatableExpressionProvider,
) -> @vscode.Disposable {
  languages_register_evaluatable_expression_provider_ffi(
    document_selector_to_js(selector),
    provider,
  )
}

///|
/// Register a provider that returns data for the debugger's 'inline value' feature.
/// Whenever the generic debugger has stopped in a source file, providers registered for the language of the file
/// are called to return textual data that will be shown in the editor at the end of lines.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider An inline values provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.InlineValuesProvider] register_inline_values_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_inline_values_provider_ffi(
    document_selector_to_js(selector),
    inline_values_provider_object(provider),
  )
}

///|
/// Register a document highlight provider.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and groups sequentially asked for document highlights.
/// The process stops when a provider returns a `non-falsy` or `non-failure` result.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A document highlight provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DocumentHighlightProvider] register_document_highlight_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_document_highlight_provider_ffi(
    document_selector_to_js(selector),
    document_highlight_provider_object(provider),
  )
}

///|
/// Register a document symbol provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A document symbol provider.
/// @param metaData metadata about the provider
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DocumentSymbolProvider] register_document_symbol_provider(
  selector : DocumentSelector,
  provider : T,
  metadata? : DocumentSymbolProviderMetadata,
) -> @vscode.Disposable {
  let metadata_js = match metadata {
    None => @v.JsValue::make(())
    Some(value) => document_symbol_provider_metadata_to_js(value)
  }
  languages_register_document_symbol_provider_ffi(
    document_selector_to_js(selector),
    document_symbol_provider_object(provider),
    metadata_js,
  )
}

///|
/// Register a workspace symbol provider.
///
/// Multiple providers can be registered. In that case providers are asked in parallel and
/// the results are merged. A failing provider (rejected promise or exception) will not cause
/// a failure of the whole operation.
///
/// @param provider A workspace symbol provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.WorkspaceSymbolProvider] register_workspace_symbol_provider(
  provider : T,
) -> @vscode.Disposable {
  languages_register_workspace_symbol_provider_ffi(
    workspace_symbol_provider_object(provider),
  )
}

///|
/// Register a reference provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A reference provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.ReferenceProvider] register_reference_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_reference_provider_ffi(
    document_selector_to_js(selector),
    reference_provider_object(provider),
  )
}

///|
/// Register a rename provider.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and asked in sequence. The first provider producing a result
/// defines the result of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A rename provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.RenameProvider] register_rename_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_rename_provider_ffi(
    document_selector_to_js(selector),
    rename_provider_object(provider),
  )
}

///|
/// Register a semantic tokens provider for a whole document.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and the best-matching provider is used. Failure
/// of the selected provider will cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A document semantic tokens provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DocumentSemanticTokensProvider] register_document_semantic_tokens_provider(
  selector : DocumentSelector,
  provider : T,
  legend : SemanticTokensLegend,
) -> @vscode.Disposable {
  languages_register_document_semantic_tokens_provider_ffi(
    document_selector_to_js(selector),
    document_semantic_tokens_provider_object(provider),
    legend,
  )
}

///|
/// Register a semantic tokens provider for a document range.
///
/// *Note:* If a document has both a `DocumentSemanticTokensProvider` and a `DocumentRangeSemanticTokensProvider`,
/// the range provider will be invoked only initially, for the time in which the full document provider takes
/// to resolve the first request. Once the full document provider resolves the first request, the semantic tokens
/// provided via the range provider will be discarded and from that point forward, only the document provider
/// will be used.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and the best-matching provider is used. Failure
/// of the selected provider will cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A document range semantic tokens provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DocumentRangeSemanticTokensProvider] register_document_range_semantic_tokens_provider(
  selector : DocumentSelector,
  provider : T,
  legend : SemanticTokensLegend,
) -> @vscode.Disposable {
  languages_register_document_range_semantic_tokens_provider_ffi(
    document_selector_to_js(selector),
    document_range_semantic_tokens_provider_object(provider),
    legend,
  )
}

///|
/// Register a formatting provider for a document.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and the best-matching provider is used. Failure
/// of the selected provider will cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A document formatting edit provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DocumentFormattingEditProvider] register_document_formatting_edit_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_document_formatting_edit_provider_ffi(
    document_selector_to_js(selector),
    document_formatting_edit_provider_object(provider),
  )
}

///|
/// Register a formatting provider for a document range.
///
/// *Note:* A document range provider is also a {@link DocumentFormattingEditProvider document formatter}
/// which means there is no need to {@link languages.registerDocumentFormattingEditProvider register} a document
/// formatter when also registering a range provider.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and the best-matching provider is used. Failure
/// of the selected provider will cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A document range formatting edit provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DocumentRangeFormattingEditProvider] register_document_range_formatting_edit_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_document_range_formatting_edit_provider_ffi(
    document_selector_to_js(selector),
    document_range_formatting_edit_provider_object(provider),
  )
}

///|
/// Register a formatting provider that works on type. The provider is active when the user enables the setting `editor.formatOnType`.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and the best-matching provider is used. Failure
/// of the selected provider will cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider An on type formatting edit provider.
/// @param firstTriggerCharacter A character on which formatting should be triggered, like `}`.
/// @param moreTriggerCharacter More trigger characters.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.OnTypeFormattingEditProvider] register_on_type_formatting_edit_provider(
  selector : DocumentSelector,
  provider : T,
  first_trigger_character : String,
  more_trigger_characters? : Array[String],
) -> @vscode.Disposable {
  languages_register_on_type_formatting_edit_provider_ffi(
    document_selector_to_js(selector),
    on_type_formatting_edit_provider_object(provider),
    first_trigger_character,
    @v.option_to_js(more_trigger_characters),
  )
}

///|
/// Register a signature help provider.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and called sequentially until a provider returns a
/// valid result.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A signature help provider.
/// @param triggerCharacters Trigger signature help when the user types one of the characters, like `,` or `(`.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.SignatureHelpProvider] register_signature_help_provider(
  selector : DocumentSelector,
  provider : T,
  trigger_characters? : Array[String],
) -> @vscode.Disposable {
  languages_register_signature_help_provider_ffi(
    document_selector_to_js(selector),
    signature_help_provider_object(provider),
    @v.option_to_js(trigger_characters),
  )
}

///|
/// Register a signature help provider.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and called sequentially until a provider returns a
/// valid result.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A signature help provider.
/// @param triggerCharacters Trigger signature help when the user types one of the characters, like `,` or `(`.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.SignatureHelpProvider] register_signature_help_provider_metadata(
  selector : DocumentSelector,
  provider : T,
  metadata : SignatureHelpProviderMetadata,
) -> @vscode.Disposable {
  languages_register_signature_help_provider_metadata_ffi(
    document_selector_to_js(selector),
    signature_help_provider_object(provider),
    signature_help_provider_metadata_to_js(metadata),
  )
}

///|
/// Register a document link provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A document link provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DocumentLinkProvider] register_document_link_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_document_link_provider_ffi(
    document_selector_to_js(selector),
    document_link_provider_object(provider),
  )
}

///|
/// Register a color provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A color provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.DocumentColorProvider] register_color_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_color_provider_ffi(
    document_selector_to_js(selector),
    document_color_provider_object(provider),
  )
}

///|
/// Register a inlay hints provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider An inlay hints provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.InlayHintsProvider] register_inlay_hints_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_inlay_hints_provider_ffi(
    document_selector_to_js(selector),
    inlay_hints_provider_object(provider),
  )
}

///|
/// Register a folding range provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged.
/// If multiple folding ranges start at the same position, only the range of the first registered provider is used.
/// If a folding range overlaps with an other range that has a smaller position, it is also ignored.
///
/// A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A folding range provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.FoldingRangeProvider] register_folding_range_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_folding_range_provider_ffi(
    document_selector_to_js(selector),
    folding_range_provider_object(provider),
  )
}

///|
/// Register a selection range provider.
///
/// Multiple providers can be registered for a language. In that case providers are asked in
/// parallel and the results are merged. A failing provider (rejected promise or exception) will
/// not cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A selection range provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.SelectionRangeProvider] register_selection_range_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_selection_range_provider_ffi(
    document_selector_to_js(selector),
    selection_range_provider_object(provider),
  )
}

///|
/// Register a call hierarchy provider.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A call hierarchy provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.CallHierarchyProvider] register_call_hierarchy_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_call_hierarchy_provider_ffi(
    document_selector_to_js(selector),
    call_hierarchy_provider_object(provider),
  )
}

///|
/// Register a type hierarchy provider.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A type hierarchy provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.TypeHierarchyProvider] register_type_hierarchy_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_type_hierarchy_provider_ffi(
    document_selector_to_js(selector),
    type_hierarchy_provider_object(provider),
  )
}

///|
/// Register a linked editing range provider.
///
/// Multiple providers can be registered for a language. In that case providers are sorted
/// by their {@link languages.match score} and the best-matching provider that has a result is used. Failure
/// of the selected provider will cause a failure of the whole operation.
///
/// @param selector A selector that defines the documents this provider is applicable to.
/// @param provider A linked editing range provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.LinkedEditingRangeProvider] register_linked_editing_range_provider(
  selector : DocumentSelector,
  provider : T,
) -> @vscode.Disposable {
  languages_register_linked_editing_range_provider_ffi(
    document_selector_to_js(selector),
    linked_editing_range_provider_object(provider),
  )
}

///|
/// Registers a new {@link DocumentDropEditProvider}.
///
/// Multiple drop providers can be registered for a language. When dropping content into an editor, all
/// registered providers for the editor's language will be invoked based on the mimetypes they handle
/// as specified by their {@linkcode DocumentDropEditProviderMetadata}.
///
/// Each provider can return one or more {@linkcode DocumentDropEdit DocumentDropEdits}. The edits are sorted
/// using the {@linkcode DocumentDropEdit.yieldTo} property. By default the first edit will be applied. If there
/// are any additional edits, these will be shown to the user as selectable drop options in the drop widget.
///
/// @param selector A selector that defines the documents this provider applies to.
/// @param provider A drop provider.
/// @param metadata Additional metadata about the provider.
///
/// @returns A {@linkcode Disposable} that unregisters this provider when disposed of.
pub fn[T : @vscode.DocumentDropEditProvider] register_document_drop_edit_provider(
  selector : DocumentSelector,
  provider : T,
  metadata? : DocumentDropEditProviderMetadata,
) -> @vscode.Disposable {
  let metadata_js = match metadata {
    None => @v.JsValue::make(())
    Some(value) => document_drop_edit_provider_metadata_to_js(value)
  }
  languages_register_document_drop_edit_provider_ffi(
    document_selector_to_js(selector),
    document_drop_edit_provider_object(provider),
    metadata_js,
  )
}

///|
/// Registers a new {@linkcode DocumentPasteEditProvider}.
///
/// Multiple providers can be registered for a language. All registered providers for a language will be invoked
/// for copy and paste operations based on their handled mimetypes as specified by the {@linkcode DocumentPasteProviderMetadata}.
///
/// For {@link DocumentPasteEditProvider.prepareDocumentPaste copy operations}, changes to the {@linkcode DataTransfer}
/// made by each provider will be merged into a single {@linkcode DataTransfer} that is used to populate the clipboard.
///
/// For {@link DocumentPasteEditProvider.providerDocumentPasteEdits paste operations}, each provider will be invoked
/// and can return one or more {@linkcode DocumentPasteEdit DocumentPasteEdits}. The edits are sorted using
/// the {@linkcode DocumentPasteEdit.yieldTo} property. By default the first edit will be applied
/// and the rest of the edits will be shown to the user as selectable paste options in the paste widget.
///
/// @param selector A selector that defines the documents this provider applies to.
/// @param provider A paste editor provider.
/// @param metadata Additional metadata about the provider.
///
/// @returns A {@linkcode Disposable} that unregisters this provider when disposed of.
pub fn[T : @vscode.DocumentPasteEditProvider] register_document_paste_edit_provider(
  selector : DocumentSelector,
  provider : T,
  metadata : DocumentPasteProviderMetadata,
) -> @vscode.Disposable {
  languages_register_document_paste_edit_provider_ffi(
    document_selector_to_js(selector),
    document_paste_edit_provider_object(provider),
    document_paste_provider_metadata_to_js(metadata),
  )
}

///|
/// Set a {@link LanguageConfiguration language configuration} for a language.
///
/// @param language A language identifier like `typescript`.
/// @param configuration Language configuration.
/// @returns A {@link Disposable} that unsets this configuration.
pub fn set_language_configuration(
  language : String,
  configuration : LanguageConfiguration,
) -> @vscode.Disposable {
  languages_set_language_configuration_ffi(
    language,
    language_configuration_to_js(configuration),
  )
}
