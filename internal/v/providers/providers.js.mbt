///|
/// VS Code provider constructors (method-style).
using @vscode {
  type AuthenticationProviderAuthenticationSessionsChangeEvent,
  type AuthenticationProviderSessionOptions,
  type AuthenticationSession,
  type AuthenticationSessionAccountInformation,
  type CallHierarchyIncomingCall,
  type CallHierarchyItem,
  type CallHierarchyOutgoingCall,
  type CancellationToken,
  type CodeAction,
  type CodeActionContext,
  type CodeActionKind,
  type CodeActionTriggerKind,
  type CodeLens,
  type Color,
  type ColorInformation,
  type ColorPresentation,
  type ColorPresentationContext,
  type CommentingRanges,
  type CompletionContext,
  type Diagnostic,
  type CompletionItem,
  type CompletionList,
  type CustomDocument,
  type CustomDocumentBackup,
  type CustomDocumentBackupContext,
  type CustomDocumentChangeEvent,
  type CustomDocumentOpenContext,
  type DataTransfer,
  type DocumentDropOrPasteEditKind,
  type DocumentDropEdit,
  type DocumentDropEditProviderMetadata,
  type DocumentHighlight,
  type DocumentLink,
  type DocumentPasteEdit,
  type DocumentPasteEditContext,
  type DocumentPasteProviderMetadata,
  type DocumentSymbol,
  type Event,
  type FileDecoration,
  type FileDecorationChange,
  type FoldingContext,
  type FoldingRange,
  type FormattingOptions,
  type Hover,
  type InlayHint,
  type InlineCompletionContext,
  type InlineCompletionItem,
  type InlineCompletionList,
  type InlineValue,
  type InlineValueContext,
  type LinkedEditingRanges,
  type Location,
  type LocationLink,
  type Position,
  type Range,
  type ReferenceContext,
  type SelectedCompletionInfo,
  type SelectionRange,
  type SemanticTokens,
  type SemanticTokensEdits,
  type SignatureHelp,
  type SignatureHelpContext,
  type SymbolInformation,
  type Task,
  type TerminalLink,
  type TerminalLinkContext,
  type TerminalProfile,
  type TextDocument,
  type TextEdit,
  type TreeItem,
  type TypeHierarchyItem,
  type Uri,
  type WebviewPanel,
  type WebviewView,
  type WebviewViewResolveContext,
  type WorkspaceEdit,
}

///|
pub type ProviderResult[T]

///|
pub type DefinitionLink

///|
pub type Definition

///|
pub type Declaration

///|
pub fn[T] ProviderResult::from_value(value : T) -> ProviderResult[T] {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ProviderResult::none() -> ProviderResult[T] {
  @v.JsValue::make(()).cast()
}

///|
pub fn[T] ProviderResult::from_async(
  value : async () -> T?,
) -> ProviderResult[T] {
  @v.JsValue::make(@js_async.Promise::from_async(value)).cast()
}

///|
pub fn DefinitionLink::from_location_link(
  value : LocationLink,
) -> DefinitionLink {
  @v.JsValue::make(value).cast()
}

///|
pub fn DefinitionLink::as_location_link(value : DefinitionLink) -> LocationLink {
  @v.JsValue::make(value).cast()
}

///|
pub fn Definition::from_location(value : Location) -> Definition {
  @v.JsValue::make(value).cast()
}

///|
pub fn Definition::from_locations(value : Array[Location]) -> Definition {
  @v.JsValue::make(value).cast()
}

///|
pub fn Declaration::from_location(value : Location) -> Declaration {
  @v.JsValue::make(value).cast()
}

///|
pub fn Declaration::from_locations(value : Array[Location]) -> Declaration {
  @v.JsValue::make(value).cast()
}

///|
pub fn Declaration::from_location_links(
  value : Array[LocationLink],
) -> Declaration {
  @v.JsValue::make(value).cast()
}

///|
fn option_hover_to_js(value : Hover?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => hover_to_js(value)
  }
}

///|
fn hover_to_js(value : Hover) -> @v.JsValue {
  hover_to_js_ffi(
    hover_contents_to_js(value.contents()),
    @v.option_to_js(value.range()),
  )
}

///|
fn hover_contents_to_js(
  values : Array[@vscode.HoverContent],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(hover_content_to_js(value))
  }
  encoded
}

///|
fn hover_content_to_js(value : @vscode.HoverContent) -> @v.JsValue {
  match value {
    Markdown(value) => @v.JsValue::make(value)
    Marked(value) => @v.JsValue::make(value)
  }
}

///|
fn option_signature_help_to_js(value : SignatureHelp?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => signature_help_to_js(value)
  }
}

///|
fn signature_help_to_js(value : SignatureHelp) -> @v.JsValue {
  signature_help_to_js_ffi(
    signature_information_array_to_js(value.signatures()),
    value.active_signature(),
    value.active_parameter(),
  )
}

///|
fn signature_information_array_to_js(
  values : Array[@vscode.SignatureInformation],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(signature_information_to_js(value))
  }
  encoded
}

///|
fn signature_information_to_js(
  value : @vscode.SignatureInformation,
) -> @v.JsValue {
  signature_information_to_js_ffi(
    value.label(),
    option_markdown_string_value_to_js(value.documentation()),
    parameter_information_array_to_js(value.parameters()),
    @v.option_to_js(value.active_parameter()),
  )
}

///|
fn parameter_information_array_to_js(
  values : Array[@vscode.ParameterInformation],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(parameter_information_to_js(value))
  }
  encoded
}

///|
fn parameter_information_to_js(
  value : @vscode.ParameterInformation,
) -> @v.JsValue {
  parameter_information_to_js_ffi(
    match value.label() {
      None => @v.JsValue::make(())
      Some(label) => parameter_label_to_js(label)
    },
    option_markdown_string_value_to_js(value.documentation()),
  )
}

///|
fn option_markdown_string_value_to_js(
  value : @vscode.MarkdownStringValue?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => markdown_string_value_to_js(value)
  }
}

///|
fn markdown_string_value_to_js(
  value : @vscode.MarkdownStringValue,
) -> @v.JsValue {
  match value {
    Text(value) => @v.JsValue::make(value)
    Markdown(value) => @v.JsValue::make(value)
  }
}

///|
fn parameter_label_to_js(value : @vscode.ParameterLabel) -> @v.JsValue {
  match value {
    Text(value) => @v.JsValue::make(value)
    Range((start, end)) => parameter_label_range_to_js_ffi(start, end)
  }
}

///|
fn option_inlay_hints_to_js(value : Array[InlayHint]?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(values) => @v.JsValue::make(inlay_hint_array_to_js(values))
  }
}

///|
fn option_inlay_hint_to_js(value : InlayHint?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => inlay_hint_to_js(value)
  }
}

///|
fn inlay_hint_array_to_js(values : Array[InlayHint]) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(inlay_hint_to_js(value))
  }
  encoded
}

///|
fn inlay_hint_to_js(value : InlayHint) -> @v.JsValue {
  inlay_hint_to_js_ffi(
    value.position(),
    match value.label() {
      None => @v.JsValue::make(())
      Some(label) => inlay_hint_label_value_to_js(label)
    },
    @v.option_to_js(value.kind()),
  )
}

///|
fn inlay_hint_label_value_to_js(
  value : @vscode.InlayHintLabelValue,
) -> @v.JsValue {
  match value {
    Text(value) => @v.JsValue::make(value)
    Parts(value) => @v.JsValue::make(inlay_hint_label_part_array_to_js(value))
  }
}

///|
fn inlay_hint_label_part_array_to_js(
  values : Array[@vscode.InlayHintLabelPart],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(inlay_hint_label_part_to_js(value))
  }
  encoded
}

///|
fn inlay_hint_label_part_to_js(
  value : @vscode.InlayHintLabelPart,
) -> @v.JsValue {
  inlay_hint_label_part_to_js_ffi(value.value())
}

///|
fn inlay_hint_from_js(value : @v.JsValue) -> InlayHint {
  let position_raw = inlay_hint_position_raw(value)
  let label_raw = inlay_hint_label_raw(value)
  let kind_raw = inlay_hint_kind_raw(value)
  if position_raw.is_null_or_undefined() || label_raw.is_null_or_undefined() {
    value.cast()
  } else {
    match inlay_hint_label_value_from_js(label_raw) {
      None => value.cast()
      Some(label) => {
        let kind : @vscode.InlayHintKind? = if kind_raw.is_null_or_undefined() {
          None
        } else {
          Some(kind_raw.cast())
        }
        match kind {
          None => InlayHint::new(position_raw.cast(), label)
          Some(kind) => InlayHint::new(position_raw.cast(), label, kind~)
        }
      }
    }
  }
}

///|
fn inlay_hint_label_value_from_js(
  value : @v.JsValue,
) -> @vscode.InlayHintLabelValue? {
  match providers_js_value_as_string_ffi(value) {
    Some(value) => Some(Text(value))
    None =>
      if providers_js_value_is_array_ffi(value) {
        let raw_parts : Array[@v.JsValue] = value.cast()
        let parts : Array[@vscode.InlayHintLabelPart] = []
        for raw in raw_parts {
          match inlay_hint_label_part_from_js(raw) {
            Some(value) => parts.push(value)
            None => return None
          }
        }
        Some(Parts(parts))
      } else {
        None
      }
  }
}

///|
fn inlay_hint_label_part_from_js(
  value : @v.JsValue,
) -> @vscode.InlayHintLabelPart? {
  let part_value_raw = inlay_hint_label_part_value_raw(value)
  match providers_js_value_as_string_ffi(part_value_raw) {
    None => None
    Some(value) => Some(@vscode.InlayHintLabelPart::new(value))
  }
}

///|
fn option_inline_completion_items_to_js(
  value : Array[InlineCompletionItem]?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(values) => @v.JsValue::make(inline_completion_item_array_to_js(values))
  }
}

///|
fn inline_completion_item_array_to_js(
  values : Array[InlineCompletionItem],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(inline_completion_item_to_js(value))
  }
  encoded
}

///|
fn inline_completion_item_to_js(value : InlineCompletionItem) -> @v.JsValue {
  inline_completion_item_to_js_ffi(
    match value.insert_text() {
      None => @v.JsValue::make(())
      Some(insert_text) => string_or_snippet_string_to_js(insert_text)
    },
    @v.option_to_js(value.range()),
    @v.option_to_js(value.command()),
  )
}

///|
fn option_inline_completion_list_to_js(
  value : InlineCompletionList?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => inline_completion_list_to_js(value)
  }
}

///|
fn inline_completion_list_to_js(value : InlineCompletionList) -> @v.JsValue {
  inline_completion_list_to_js_ffi(
    inline_completion_item_array_to_js(value.items()),
  )
}

///|
fn string_or_snippet_string_to_js(
  value : @vscode.StringOrSnippetString,
) -> @v.JsValue {
  match value {
    Text(value) => @v.JsValue::make(value)
    Snippet(value) => @v.JsValue::make(value)
  }
}

///|
fn option_terminal_profile_to_js(value : TerminalProfile?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => terminal_profile_to_js(value)
  }
}

///|
fn terminal_profile_to_js(value : TerminalProfile) -> @v.JsValue {
  terminal_profile_to_js_ffi(value)
}

///|
fn custom_document_backup_to_js(value : CustomDocumentBackup) -> @v.JsValue {
  custom_document_backup_to_js_ffi(value)
}

///|
fn file_decoration_change_to_js(value : FileDecorationChange) -> @v.JsValue {
  match value {
    UriValue(value) => @v.JsValue::make(value)
    Uris(value) => @v.JsValue::make(value)
    All => @v.JsValue::make(())
  }
}

///|
pub fn HoverProviderObject::new(
  provide_hover : async (TextDocument, Position, CancellationToken) -> Hover?,
) -> HoverProviderObject {
  hover_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      option_hover_to_js(provide_hover(document, position, token))
    })
  })
}

///|
pub fn SignatureHelpProviderObject::new(
  provide_help : async (
    TextDocument,
    Position,
    CancellationToken,
    SignatureHelpContext,
  ) -> SignatureHelp?,
) -> SignatureHelpProviderObject {
  signature_help_provider_ffi((document, position, token, context) => {
    @js_async.Promise::from_async(async fn() {
      option_signature_help_to_js(
        provide_help(document, position, token, context),
      )
    })
  })
}

///|
pub fn CompletionItemProviderObject::new_items(
  provide_items : async (
    TextDocument,
    Position,
    CancellationToken,
    CompletionContext,
  ) -> Array[CompletionItem]?,
  resolve_item? : async (CompletionItem, CancellationToken) -> CompletionItem?,
) -> CompletionItemProviderObject[CompletionItem] {
  let resolve_callback : ((CompletionItem, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_item {
    None => None
    Some(value) =>
      Some((item, token) => {
        @js_async.Promise::from_async(async fn() {
          @v.option_to_js(value(item, token))
        })
      })
  }
  completion_item_provider_ffi(
    (document, position, token, context) => {
      @js_async.Promise::from_async(async fn() {
        let completion_context = completion_context_from_js(
          @v.JsValue::make(context),
        )
        @v.option_to_js(
          provide_items(document, position, token, completion_context),
        )
      })
    },
    @v.option_to_js(resolve_callback),
  )
}

///|
pub fn CompletionItemProviderObject::new_list(
  provide_list : async (
    TextDocument,
    Position,
    CancellationToken,
    CompletionContext,
  ) -> CompletionList[CompletionItem]?,
  resolve_item? : async (CompletionItem, CancellationToken) -> CompletionItem?,
) -> CompletionItemProviderObject[CompletionItem] {
  let resolve_callback : ((CompletionItem, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_item {
    None => None
    Some(value) =>
      Some((item, token) => {
        @js_async.Promise::from_async(async fn() {
          @v.option_to_js(value(item, token))
        })
      })
  }
  completion_item_provider_ffi(
    (document, position, token, context) => {
      @js_async.Promise::from_async(async fn() {
        let completion_context = completion_context_from_js(
          @v.JsValue::make(context),
        )
        @v.option_to_js(
          provide_list(document, position, token, completion_context),
        )
      })
    },
    @v.option_to_js(resolve_callback),
  )
}

///|
pub fn DefinitionProviderObject::new_location(
  provide_definition : async (TextDocument, Position, CancellationToken) -> Location?,
) -> DefinitionProviderObject {
  definition_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_definition(document, position, token))
    })
  })
}

///|
pub fn DefinitionProviderObject::new_locations(
  provide_definition : async (TextDocument, Position, CancellationToken) -> Array[
    Location,
  ]?,
) -> DefinitionProviderObject {
  definition_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_definition(document, position, token))
    })
  })
}

///|
pub fn DefinitionProviderObject::new_location_links(
  provide_definition : async (TextDocument, Position, CancellationToken) -> Array[
    LocationLink,
  ]?,
) -> DefinitionProviderObject {
  definition_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_definition(document, position, token))
    })
  })
}

///|
pub fn ImplementationProviderObject::new_location(
  provide_implementation : async (TextDocument, Position, CancellationToken) -> Location?,
) -> ImplementationProviderObject {
  implementation_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_implementation(document, position, token))
    })
  })
}

///|
pub fn ImplementationProviderObject::new_locations(
  provide_implementation : async (TextDocument, Position, CancellationToken) -> Array[
    Location,
  ]?,
) -> ImplementationProviderObject {
  implementation_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_implementation(document, position, token))
    })
  })
}

///|
pub fn ImplementationProviderObject::new_location_links(
  provide_implementation : async (TextDocument, Position, CancellationToken) -> Array[
    LocationLink,
  ]?,
) -> ImplementationProviderObject {
  implementation_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_implementation(document, position, token))
    })
  })
}

///|
pub fn TypeDefinitionProviderObject::new_location(
  provide_definition : async (TextDocument, Position, CancellationToken) -> Location?,
) -> TypeDefinitionProviderObject {
  type_definition_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_definition(document, position, token))
    })
  })
}

///|
pub fn TypeDefinitionProviderObject::new_locations(
  provide_definition : async (TextDocument, Position, CancellationToken) -> Array[
    Location,
  ]?,
) -> TypeDefinitionProviderObject {
  type_definition_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_definition(document, position, token))
    })
  })
}

///|
pub fn TypeDefinitionProviderObject::new_location_links(
  provide_definition : async (TextDocument, Position, CancellationToken) -> Array[
    LocationLink,
  ]?,
) -> TypeDefinitionProviderObject {
  type_definition_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_definition(document, position, token))
    })
  })
}

///|
pub fn DeclarationProviderObject::new_location(
  provide_declaration : async (TextDocument, Position, CancellationToken) -> Location?,
) -> DeclarationProviderObject {
  declaration_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_declaration(document, position, token))
    })
  })
}

///|
pub fn DeclarationProviderObject::new_locations(
  provide_declaration : async (TextDocument, Position, CancellationToken) -> Array[
    Location,
  ]?,
) -> DeclarationProviderObject {
  declaration_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_declaration(document, position, token))
    })
  })
}

///|
pub fn DeclarationProviderObject::new_location_links(
  provide_declaration : async (TextDocument, Position, CancellationToken) -> Array[
    LocationLink,
  ]?,
) -> DeclarationProviderObject {
  declaration_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_declaration(document, position, token))
    })
  })
}

///|
pub fn ReferenceProviderObject::new(
  provide_references : async (
    TextDocument,
    Position,
    ReferenceContext,
    CancellationToken,
  ) -> Array[Location]?,
) -> ReferenceProviderObject {
  reference_provider_ffi((document, position, context, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_references(document, position, context, token))
    })
  })
}

///|
pub fn DocumentHighlightProviderObject::new(
  provide_highlights : async (TextDocument, Position, CancellationToken) -> Array[
    DocumentHighlight,
  ]?,
) -> DocumentHighlightProviderObject {
  document_highlight_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_highlights(document, position, token))
    })
  })
}

///|
pub fn CodeActionProviderObject::new(
  provide_actions : async (
    TextDocument,
    Range,
    CodeActionContext,
    CancellationToken,
  ) -> Array[CodeAction]?,
  resolve_action? : async (CodeAction, CancellationToken) -> CodeAction?,
) -> CodeActionProviderObject[CodeAction] {
  let resolve_callback : ((CodeAction, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_action {
    None => None
    Some(value) =>
      Some((action, token) => {
        @js_async.Promise::from_async(async fn() {
          @v.option_to_js(value(action, token))
        })
      })
  }
  code_action_provider_ffi(
    (document, range, context, token) => {
      @js_async.Promise::from_async(async fn() {
        let code_action_context = code_action_context_from_js(
          @v.JsValue::make(context),
        )
        @v.option_to_js(
          provide_actions(document, range, code_action_context, token),
        )
      })
    },
    @v.option_to_js(resolve_callback),
  )
}

///|
pub fn DocumentFormattingEditProviderObject::new(
  provide_edits : async (TextDocument, FormattingOptions, CancellationToken) -> Array[
    TextEdit,
  ]?,
) -> DocumentFormattingEditProviderObject {
  document_formatting_provider_ffi((document, options, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_edits(document, options, token))
    })
  })
}

///|
pub fn DocumentRangeFormattingEditProviderObject::new(
  provide_edits : async (
    TextDocument,
    Range,
    FormattingOptions,
    CancellationToken,
  ) -> Array[TextEdit]?,
) -> DocumentRangeFormattingEditProviderObject {
  document_range_formatting_provider_ffi((document, range, options, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_edits(document, range, options, token))
    })
  })
}

///|
pub fn OnTypeFormattingEditProviderObject::new(
  provide_edits : async (
    TextDocument,
    Position,
    String,
    FormattingOptions,
    CancellationToken,
  ) -> Array[TextEdit]?,
) -> OnTypeFormattingEditProviderObject {
  on_type_formatting_provider_ffi((document, position, ch, options, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_edits(document, position, ch, options, token))
    })
  })
}

///|
pub fn DocumentLinkProviderObject::new(
  provide_links : async (TextDocument, CancellationToken) -> Array[DocumentLink]?,
  resolve_link? : async (DocumentLink, CancellationToken) -> DocumentLink?,
) -> DocumentLinkProviderObject[DocumentLink] {
  let resolve_callback : ((DocumentLink, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_link {
    None => None
    Some(value) =>
      Some((link, token) => {
        @js_async.Promise::from_async(async fn() {
          @v.option_to_js(value(link, token))
        })
      })
  }
  document_link_provider_ffi(
    (document, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(provide_links(document, token))
      })
    },
    @v.option_to_js(resolve_callback),
  )
}

///|
pub fn CodeLensProviderObject::new(
  provide_lenses : async (TextDocument, CancellationToken) -> Array[CodeLens]?,
  resolve_lens? : async (CodeLens, CancellationToken) -> CodeLens?,
  on_did_change? : Event[Unit],
) -> CodeLensProviderObject[CodeLens] {
  let resolve_callback : ((CodeLens, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_lens {
    None => None
    Some(value) =>
      Some((lens, token) => {
        @js_async.Promise::from_async(async fn() {
          @v.option_to_js(value(lens, token))
        })
      })
  }
  code_lens_provider_ffi(
    (document, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(provide_lenses(document, token))
      })
    },
    @v.option_to_js(resolve_callback),
    @v.option_to_js(on_did_change),
  )
}

///|
pub fn DocumentColorProviderObject::new(
  provide_colors : async (TextDocument, CancellationToken) -> Array[
    ColorInformation,
  ]?,
  provide_presentations : async (
    Color,
    ColorPresentationContext,
    CancellationToken,
  ) -> Array[ColorPresentation]?,
) -> DocumentColorProviderObject {
  document_color_provider_ffi(
    (document, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(provide_colors(document, token))
      })
    },
    (color, context, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(provide_presentations(color, context, token))
      })
    },
  )
}

///|
pub fn FoldingRangeProviderObject::new(
  provide_ranges : async (TextDocument, FoldingContext, CancellationToken) -> Array[
    FoldingRange,
  ]?,
) -> FoldingRangeProviderObject {
  folding_range_provider_ffi((document, context, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_ranges(document, context, token))
    })
  })
}

///|
pub fn DocumentSymbolProviderObject::new_symbols(
  provide_symbols : async (TextDocument, CancellationToken) -> Array[
    DocumentSymbol,
  ]?,
) -> DocumentSymbolProviderObject {
  document_symbol_provider_ffi((document, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_symbols(document, token))
    })
  })
}

///|
pub fn DocumentSymbolProviderObject::new_information(
  provide_symbols : async (TextDocument, CancellationToken) -> Array[
    SymbolInformation,
  ]?,
) -> DocumentSymbolProviderObject {
  document_symbol_provider_ffi((document, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_symbols(document, token))
    })
  })
}

///|
pub fn WorkspaceSymbolProviderObject::new(
  provide_symbols : async (String, CancellationToken) -> Array[
    SymbolInformation,
  ]?,
  resolve_symbol? : async (SymbolInformation, CancellationToken) -> SymbolInformation?,
) -> WorkspaceSymbolProviderObject[SymbolInformation] {
  let resolve_callback : ((SymbolInformation, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_symbol {
    None => None
    Some(value) =>
      Some((symbol, token) => {
        @js_async.Promise::from_async(async fn() {
          @v.option_to_js(value(symbol, token))
        })
      })
  }
  workspace_symbol_provider_ffi(
    (query, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(provide_symbols(query, token))
      })
    },
    @v.option_to_js(resolve_callback),
  )
}

///|
pub fn CallHierarchyProviderObject::new_item(
  prepare : async (TextDocument, Position, CancellationToken) -> CallHierarchyItem?,
  incoming_calls : async (CallHierarchyItem, CancellationToken) -> Array[
    CallHierarchyIncomingCall,
  ]?,
  outgoing_calls : async (CallHierarchyItem, CancellationToken) -> Array[
    CallHierarchyOutgoingCall,
  ]?,
) -> CallHierarchyProviderObject {
  call_hierarchy_provider_ffi(
    (document, position, token) => {
      @js_async.Promise::from_async(async fn() {
        option_call_hierarchy_item_to_js(prepare(document, position, token))
      })
    },
    (item, token) => {
      @js_async.Promise::from_async(async fn() {
        let call_hierarchy_item = call_hierarchy_item_from_js(
          @v.JsValue::make(item),
        )
        option_call_hierarchy_incoming_calls_to_js(
          incoming_calls(call_hierarchy_item, token),
        )
      })
    },
    (item, token) => {
      @js_async.Promise::from_async(async fn() {
        let call_hierarchy_item = call_hierarchy_item_from_js(
          @v.JsValue::make(item),
        )
        option_call_hierarchy_outgoing_calls_to_js(
          outgoing_calls(call_hierarchy_item, token),
        )
      })
    },
  )
}

///|
pub fn CallHierarchyProviderObject::new_items(
  prepare : async (TextDocument, Position, CancellationToken) -> Array[
    CallHierarchyItem,
  ]?,
  incoming_calls : async (CallHierarchyItem, CancellationToken) -> Array[
    CallHierarchyIncomingCall,
  ]?,
  outgoing_calls : async (CallHierarchyItem, CancellationToken) -> Array[
    CallHierarchyOutgoingCall,
  ]?,
) -> CallHierarchyProviderObject {
  call_hierarchy_provider_ffi(
    (document, position, token) => {
      @js_async.Promise::from_async(async fn() {
        option_call_hierarchy_item_array_to_js(
          prepare(document, position, token),
        )
      })
    },
    (item, token) => {
      @js_async.Promise::from_async(async fn() {
        let call_hierarchy_item = call_hierarchy_item_from_js(
          @v.JsValue::make(item),
        )
        option_call_hierarchy_incoming_calls_to_js(
          incoming_calls(call_hierarchy_item, token),
        )
      })
    },
    (item, token) => {
      @js_async.Promise::from_async(async fn() {
        let call_hierarchy_item = call_hierarchy_item_from_js(
          @v.JsValue::make(item),
        )
        option_call_hierarchy_outgoing_calls_to_js(
          outgoing_calls(call_hierarchy_item, token),
        )
      })
    },
  )
}

///|
pub fn TypeHierarchyProviderObject::new_item(
  prepare : async (TextDocument, Position, CancellationToken) -> TypeHierarchyItem?,
  supertypes : async (TypeHierarchyItem, CancellationToken) -> Array[
    TypeHierarchyItem,
  ]?,
  subtypes : async (TypeHierarchyItem, CancellationToken) -> Array[
    TypeHierarchyItem,
  ]?,
) -> TypeHierarchyProviderObject {
  type_hierarchy_provider_ffi(
    (document, position, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(prepare(document, position, token))
      })
    },
    (item, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(supertypes(item, token))
      })
    },
    (item, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(subtypes(item, token))
      })
    },
  )
}

///|
pub fn TypeHierarchyProviderObject::new_items(
  prepare : async (TextDocument, Position, CancellationToken) -> Array[
    TypeHierarchyItem,
  ]?,
  supertypes : async (TypeHierarchyItem, CancellationToken) -> Array[
    TypeHierarchyItem,
  ]?,
  subtypes : async (TypeHierarchyItem, CancellationToken) -> Array[
    TypeHierarchyItem,
  ]?,
) -> TypeHierarchyProviderObject {
  type_hierarchy_provider_ffi(
    (document, position, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(prepare(document, position, token))
      })
    },
    (item, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(supertypes(item, token))
      })
    },
    (item, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(subtypes(item, token))
      })
    },
  )
}

///|
pub fn InlayHintsProviderObject::new(
  provide_hints : async (TextDocument, Range, CancellationToken) -> Array[
    InlayHint,
  ]?,
  resolve_hint? : async (InlayHint, CancellationToken) -> InlayHint?,
) -> InlayHintsProviderObject[InlayHint] {
  let resolve_callback : ((InlayHint, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_hint {
    None => None
    Some(value) =>
      Some((hint, token) => {
        @js_async.Promise::from_async(async fn() {
          let decoded_hint = inlay_hint_from_js(@v.JsValue::make(hint))
          option_inlay_hint_to_js(value(decoded_hint, token))
        })
      })
  }
  inlay_hints_provider_ffi(
    (document, range, token) => {
      @js_async.Promise::from_async(async fn() {
        option_inlay_hints_to_js(provide_hints(document, range, token))
      })
    },
    @v.option_to_js(resolve_callback),
  )
}

///|
pub fn DocumentSemanticTokensProviderObject::new(
  provide_tokens : async (TextDocument, CancellationToken) -> SemanticTokens,
  provide_edits? : async (TextDocument, String, CancellationToken) -> SemanticTokensEdits,
  on_did_change? : Event[Unit],
) -> DocumentSemanticTokensProviderObject {
  let edits_callback : ((TextDocument, String, CancellationToken) -> @js_async.Promise[
    SemanticTokensEdits,
  ])? = match provide_edits {
    None => None
    Some(value) =>
      Some((document, result_id, token) => {
        @js_async.Promise::from_async(() => value(document, result_id, token))
      })
  }
  document_semantic_tokens_provider_ffi(
    (document, token) => {
      @js_async.Promise::from_async(() => provide_tokens(document, token))
    },
    @v.option_to_js(edits_callback),
    @v.option_to_js(on_did_change),
  )
}

///|
pub fn DocumentRangeSemanticTokensProviderObject::new(
  provide_tokens : async (TextDocument, Range, CancellationToken) -> SemanticTokens,
) -> DocumentRangeSemanticTokensProviderObject {
  document_range_semantic_tokens_provider_ffi((document, range, token) => {
    @js_async.Promise::from_async(() => provide_tokens(document, range, token))
  })
}

///|
pub fn InlineCompletionItemProviderObject::new_items(
  provide_items : async (
    TextDocument,
    Position,
    InlineCompletionContext,
    CancellationToken,
  ) -> Array[InlineCompletionItem]?,
) -> InlineCompletionItemProviderObject {
  inline_completion_item_provider_ffi((document, position, context, token) => {
    @js_async.Promise::from_async(async fn() {
      let inline_context = inline_completion_context_from_js(
        @v.JsValue::make(context),
      )
      option_inline_completion_items_to_js(
        provide_items(document, position, inline_context, token),
      )
    })
  })
}

///|
pub fn InlineCompletionItemProviderObject::new_list(
  provide_list : async (
    TextDocument,
    Position,
    InlineCompletionContext,
    CancellationToken,
  ) -> InlineCompletionList?,
) -> InlineCompletionItemProviderObject {
  inline_completion_item_provider_ffi((document, position, context, token) => {
    @js_async.Promise::from_async(async fn() {
      let inline_context = inline_completion_context_from_js(
        @v.JsValue::make(context),
      )
      option_inline_completion_list_to_js(
        provide_list(document, position, inline_context, token),
      )
    })
  })
}

///|
pub fn InlineValuesProviderObject::new(
  provide_values : async (
    TextDocument,
    Range,
    InlineValueContext,
    CancellationToken,
  ) -> Array[InlineValue]?,
) -> InlineValuesProviderObject {
  inline_values_provider_ffi((document, range, context, token) => {
    @js_async.Promise::from_async(async fn() {
      let inline_context = inline_value_context_from_js(
        @v.JsValue::make(context),
      )
      option_inline_values_to_js(
        provide_values(document, range, inline_context, token),
      )
    })
  })
}

///|
fn option_inline_values_to_js(values : Array[InlineValue]?) -> @v.JsValue {
  match values {
    None => @v.JsValue::make(())
    Some(values) => @v.JsValue::make(inline_values_raw(values))
  }
}

///|
fn inline_values_raw(values : Array[InlineValue]) -> Array[@v.JsValue] {
  let raw : Array[@v.JsValue] = []
  for value in values {
    raw.push(inline_value_to_js(value))
  }
  raw
}

///|
fn inline_value_to_js(value : InlineValue) -> @v.JsValue {
  match value {
    Text(value) => inline_value_text_to_js_ffi(value.range(), value.text())
    VariableLookup(value) =>
      inline_value_variable_lookup_to_js_ffi(
        value.range(),
        @v.option_to_js(value.variable_name()),
        value.case_sensitive_lookup(),
      )
    EvaluatableExpression(value) =>
      inline_value_evaluatable_expression_to_js_ffi(
        value.range(),
        @v.option_to_js(value.expression()),
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
  providers_document_drop_edit_provider_metadata_to_js_ffi(
    @v.option_to_js(provided_kind_values),
    metadata.drop_mime_types,
  )
}

///|
fn document_paste_provider_metadata_to_js(
  metadata : DocumentPasteProviderMetadata,
) -> @v.JsValue {
  providers_document_paste_provider_metadata_to_js_ffi(
    document_drop_or_paste_edit_kind_values(metadata.provided_kinds),
    @v.option_to_js(metadata.copy_mime_types),
    @v.option_to_js(metadata.paste_mime_types),
  )
}

///|
pub fn DocumentDropEditProviderObject::new(
  provide_edit : async (TextDocument, Position, DataTransfer, CancellationToken) -> DocumentDropEdit?,
  metadata? : DocumentDropEditProviderMetadata,
) -> DocumentDropEditProviderObject {
  let metadata_js = match metadata {
    None => @v.JsValue::make(())
    Some(value) => document_drop_edit_provider_metadata_to_js(value)
  }
  document_drop_edit_provider_ffi(
    (document, position, data_transfer, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(provide_edit(document, position, data_transfer, token))
      })
    },
    metadata_js,
  )
}

///|
pub fn DocumentPasteEditProviderObject::new(
  provide_edit : async (
    TextDocument,
    Array[Range],
    DataTransfer,
    DocumentPasteEditContext,
    CancellationToken,
  ) -> DocumentPasteEdit?,
  metadata? : DocumentPasteProviderMetadata,
) -> DocumentPasteEditProviderObject {
  let metadata_js = match metadata {
    None => @v.JsValue::make(())
    Some(value) => document_paste_provider_metadata_to_js(value)
  }
  document_paste_edit_provider_ffi(
    (document, ranges, data_transfer, context, token) => {
      @js_async.Promise::from_async(async fn() {
        let paste_context = document_paste_edit_context_from_js(
          @v.JsValue::make(context),
        )
        @v.option_to_js(
          provide_edit(document, ranges, data_transfer, paste_context, token),
        )
      })
    },
    metadata_js,
  )
}

///|
fn completion_context_from_js(value : @v.JsValue) -> CompletionContext {
  let trigger_kind_raw = completion_context_trigger_kind_raw(value)
  let trigger_character_raw = completion_context_trigger_character_raw(value)
  let trigger_kind = if trigger_kind_raw.is_null_or_undefined() {
    let fallback : CompletionContext = value.cast()
    fallback.trigger_kind
  } else {
    trigger_kind_raw.cast()
  }
  let trigger_character : String? = if trigger_character_raw.is_null_or_undefined() {
    None
  } else {
    Some(trigger_character_raw.cast())
  }
  match trigger_character {
    None => CompletionContext::new(trigger_kind)
    Some(value) => CompletionContext::new(trigger_kind, trigger_character=value)
  }
}

///|
fn code_action_context_from_js(value : @v.JsValue) -> CodeActionContext {
  let diagnostics_raw = code_action_context_diagnostics_raw(value)
  let only_raw = code_action_context_only_raw(value)
  let trigger_kind_raw = code_action_context_trigger_kind_raw(value)
  let diagnostics : Array[Diagnostic] = if diagnostics_raw.is_null_or_undefined() {
    []
  } else {
    diagnostics_raw.cast()
  }
  let only : CodeActionKind? = if only_raw.is_null_or_undefined() {
    None
  } else {
    Some(code_action_kind_from_value(code_action_kind_value_from_js(only_raw)))
  }
  let trigger_kind = if trigger_kind_raw.is_null_or_undefined() {
    CodeActionTriggerKind::Invoke
  } else {
    trigger_kind_raw.cast()
  }
  match only {
    None => CodeActionContext::new(trigger_kind, diagnostics)
    Some(value) => CodeActionContext::new(trigger_kind, diagnostics, only=value)
  }
}

///|
fn code_action_kind_from_value(value : String) -> CodeActionKind {
  match value {
    "" => CodeActionKind::Empty
    "quickfix" => CodeActionKind::QuickFix
    "refactor" => CodeActionKind::Refactor
    "refactor.extract" => CodeActionKind::RefactorExtract
    "refactor.inline" => CodeActionKind::RefactorInline
    "refactor.move" => CodeActionKind::RefactorMove
    "refactor.rewrite" => CodeActionKind::RefactorRewrite
    "source" => CodeActionKind::Source
    "source.organizeImports" => CodeActionKind::SourceOrganizeImports
    "source.fixAll" => CodeActionKind::SourceFixAll
    "notebook" => CodeActionKind::Notebook
    _ => CodeActionKind::Custom(value)
  }
}

///|
extern "js" fn code_action_kind_value_from_js(value : @v.JsValue) -> String =
  #| (kind) => {
  #|   if (typeof kind === "string") {
  #|     return kind;
  #|   }
  #|   if (kind && typeof kind.value === "string") {
  #|     return kind.value;
  #|   }
  #|   if (kind && typeof kind.value === "number") {
  #|     return String(kind.value);
  #|   }
  #|   if (kind && typeof kind.valueOf === "function") {
  #|     return String(kind.valueOf());
  #|   }
  #|   return "";
  #| }

///|
fn call_hierarchy_item_from_js(value : @v.JsValue) -> CallHierarchyItem {
  let kind_raw = call_hierarchy_item_kind_raw(value)
  let name_raw = call_hierarchy_item_name_raw(value)
  let detail_raw = call_hierarchy_item_detail_raw(value)
  let uri_raw = call_hierarchy_item_uri_raw(value)
  let range_raw = call_hierarchy_item_range_raw(value)
  let selection_range_raw = call_hierarchy_item_selection_range_raw(value)
  let missing = kind_raw.is_null_or_undefined() ||
    uri_raw.is_null_or_undefined() ||
    range_raw.is_null_or_undefined() ||
    selection_range_raw.is_null_or_undefined()
  if missing {
    value.cast()
  } else {
    match
      (
        providers_js_value_as_string_ffi(name_raw),
        providers_js_value_as_string_ffi(detail_raw),
      ) {
      (Some(name), Some(detail)) =>
        CallHierarchyItem::new(
          kind_raw.cast(),
          name,
          detail,
          uri_raw.cast(),
          range_raw.cast(),
          selection_range_raw.cast(),
        )
      _ => value.cast()
    }
  }
}

///|
fn call_hierarchy_item_to_js(value : CallHierarchyItem) -> @v.JsValue {
  call_hierarchy_item_to_js_ffi(
    value.kind(),
    value.name(),
    value.detail(),
    value.uri(),
    value.range(),
    value.selection_range(),
  )
}

///|
fn call_hierarchy_item_array_to_js(
  values : Array[CallHierarchyItem],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(call_hierarchy_item_to_js(value))
  }
  encoded
}

///|
fn option_call_hierarchy_item_to_js(value : CallHierarchyItem?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(item) => call_hierarchy_item_to_js(item)
  }
}

///|
fn option_call_hierarchy_item_array_to_js(
  value : Array[CallHierarchyItem]?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(items) => @v.JsValue::make(call_hierarchy_item_array_to_js(items))
  }
}

///|
fn call_hierarchy_incoming_call_to_js(
  value : CallHierarchyIncomingCall,
) -> @v.JsValue {
  call_hierarchy_incoming_call_to_js_ffi(
    call_hierarchy_item_to_js(value.from_item()),
    value.from_ranges(),
  )
}

///|
fn call_hierarchy_incoming_call_array_to_js(
  values : Array[CallHierarchyIncomingCall],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(call_hierarchy_incoming_call_to_js(value))
  }
  encoded
}

///|
fn option_call_hierarchy_incoming_calls_to_js(
  values : Array[CallHierarchyIncomingCall]?,
) -> @v.JsValue {
  match values {
    None => @v.JsValue::make(())
    Some(items) =>
      @v.JsValue::make(call_hierarchy_incoming_call_array_to_js(items))
  }
}

///|
fn call_hierarchy_outgoing_call_to_js(
  value : CallHierarchyOutgoingCall,
) -> @v.JsValue {
  call_hierarchy_outgoing_call_to_js_ffi(
    call_hierarchy_item_to_js(value.to_item()),
    value.from_ranges(),
  )
}

///|
fn call_hierarchy_outgoing_call_array_to_js(
  values : Array[CallHierarchyOutgoingCall],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(call_hierarchy_outgoing_call_to_js(value))
  }
  encoded
}

///|
fn option_call_hierarchy_outgoing_calls_to_js(
  values : Array[CallHierarchyOutgoingCall]?,
) -> @v.JsValue {
  match values {
    None => @v.JsValue::make(())
    Some(items) =>
      @v.JsValue::make(call_hierarchy_outgoing_call_array_to_js(items))
  }
}

///|
fn selected_completion_info_from_js(
  value : @v.JsValue,
) -> SelectedCompletionInfo? {
  let range_raw = selected_completion_info_range_raw(value)
  let text_raw = selected_completion_info_text_raw(value)
  if range_raw.is_null_or_undefined() {
    None
  } else {
    match providers_js_value_as_string_ffi(text_raw) {
      Some(text) => Some(SelectedCompletionInfo::new(range_raw.cast(), text))
      None => None
    }
  }
}

///|
fn inline_completion_context_from_js(
  value : @v.JsValue,
) -> InlineCompletionContext {
  let trigger_kind_raw = inline_completion_context_trigger_kind_raw(value)
  let selected_info_raw = inline_completion_context_selected_info_raw(value)
  let selected_info = if selected_info_raw.is_null_or_undefined() {
    None
  } else {
    selected_completion_info_from_js(selected_info_raw)
  }
  let trigger_kind = if trigger_kind_raw.is_null_or_undefined() {
    let fallback : InlineCompletionContext = value.cast()
    fallback.trigger_kind
  } else {
    trigger_kind_raw.cast()
  }
  match selected_info {
    None => InlineCompletionContext::new(trigger_kind)
    Some(value) =>
      InlineCompletionContext::new(trigger_kind, selected_info=value)
  }
}

///|
fn inline_value_context_from_js(value : @v.JsValue) -> InlineValueContext {
  let frame_id_raw = inline_value_context_frame_id_raw(value)
  let stopped_location_raw = inline_value_context_stopped_location_raw(value)
  if frame_id_raw.is_null_or_undefined() ||
    stopped_location_raw.is_null_or_undefined() {
    value.cast()
  } else {
    InlineValueContext::new(frame_id_raw.cast(), stopped_location_raw.cast())
  }
}

///|
fn document_drop_or_paste_edit_kind_from_js(
  value : @v.JsValue,
) -> DocumentDropOrPasteEditKind? {
  if value.is_null_or_undefined() {
    None
  } else {
    let value_string = document_drop_or_paste_kind_value_raw(value)
    Some(
      match value_string {
        "" => DocumentDropOrPasteEditKind::Empty
        "text" => DocumentDropOrPasteEditKind::Text
        "text.updateImports" => DocumentDropOrPasteEditKind::TextUpdateImports
        _ => Custom(value_string)
      },
    )
  }
}

///|
fn document_paste_edit_context_from_js(
  value : @v.JsValue,
) -> DocumentPasteEditContext {
  let trigger_kind_raw = document_paste_edit_context_trigger_kind_raw(value)
  let only_raw = document_paste_edit_context_only_raw(value)
  let only : DocumentDropOrPasteEditKind? = if only_raw.is_null_or_undefined() {
    None
  } else {
    document_drop_or_paste_edit_kind_from_js(only_raw)
  }
  let trigger_kind = if trigger_kind_raw.is_null_or_undefined() {
    let fallback : DocumentPasteEditContext = value.cast()
    fallback.trigger_kind
  } else {
    trigger_kind_raw.cast()
  }
  match only {
    None => DocumentPasteEditContext::new(trigger_kind)
    Some(value) => DocumentPasteEditContext::new(trigger_kind, only=value)
  }
}

///|
fn terminal_link_context_from_js(value : @v.JsValue) -> TerminalLinkContext {
  let line_raw = terminal_link_context_line_raw(value)
  let terminal_raw = terminal_link_context_terminal_raw(value)
  if terminal_raw.is_null_or_undefined() {
    value.cast()
  } else {
    match providers_js_value_as_string_ffi(line_raw) {
      Some(line) => TerminalLinkContext::new(line, terminal_raw.cast())
      None => value.cast()
    }
  }
}

///|
pub fn RenameProviderObject::new(
  provide_edits : async (TextDocument, Position, String, CancellationToken) -> WorkspaceEdit?,
  prepare_rename? : async (TextDocument, Position, CancellationToken) -> Range?,
) -> RenameProviderObject {
  let prepare_callback : ((TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match prepare_rename {
    None => None
    Some(value) =>
      Some((document, position, token) => {
        @js_async.Promise::from_async(async fn() {
          @v.option_to_js(value(document, position, token))
        })
      })
  }
  rename_provider_ffi(
    (document, position, new_name, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(provide_edits(document, position, new_name, token))
      })
    },
    @v.option_to_js(prepare_callback),
  )
}

///|
pub fn SelectionRangeProviderObject::new(
  provide_ranges : async (TextDocument, Array[Position], CancellationToken) -> Array[
    SelectionRange,
  ]?,
) -> SelectionRangeProviderObject {
  selection_range_provider_ffi((document, positions, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_ranges(document, positions, token))
    })
  })
}

///|
pub fn LinkedEditingRangeProviderObject::new(
  provide_ranges : async (TextDocument, Position, CancellationToken) -> LinkedEditingRanges?,
) -> LinkedEditingRangeProviderObject {
  linked_editing_range_provider_ffi((document, position, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_ranges(document, position, token))
    })
  })
}

///|
pub fn QuickDiffProviderObject::new(
  provide_original : async (Uri, CancellationToken) -> Uri?,
) -> QuickDiffProviderObject {
  quick_diff_provider_ffi((uri, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_original(uri, token))
    })
  })
}

///|
pub fn TextDocumentContentProviderObject::new(
  provide_content : async (Uri, CancellationToken) -> String,
  on_did_change? : Event[Uri],
) -> TextDocumentContentProviderObject {
  text_document_content_provider_ffi(
    (uri, token) => {
      @js_async.Promise::from_async(() => provide_content(uri, token))
    },
    @v.option_to_js(on_did_change),
  )
}

///|
fn option_file_decoration_change_event_to_js(
  value : Event[FileDecorationChange]?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) =>
      file_decoration_change_event_to_js_ffi(
        value, file_decoration_change_to_js,
      )
  }
}

///|
extern "js" fn file_decoration_change_event_to_js_ffi(
  event : Event[FileDecorationChange],
  encode : (FileDecorationChange) -> @v.JsValue,
) -> @v.JsValue =
  #| (event, encode) => (listener, thisArg, disposables) =>
  #|   event((e) => listener(encode(e)), thisArg, disposables)

///|
pub fn FileDecorationProviderObject::new(
  provide_decoration : async (Uri, CancellationToken) -> FileDecoration?,
  on_did_change? : Event[FileDecorationChange],
) -> FileDecorationProviderObject {
  file_decoration_provider_ffi(
    (uri, token) => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(provide_decoration(uri, token))
      })
    },
    option_file_decoration_change_event_to_js(on_did_change),
  )
}

///|
pub fn CommentingRangeProviderObject::new_ranges(
  provide_ranges : async (TextDocument, CancellationToken) -> Array[Range]?,
) -> CommentingRangeProviderObject {
  commenting_range_provider_ffi((document, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_ranges(document, token))
    })
  })
}

///|
pub fn CommentingRangeProviderObject::new_ranges_with_details(
  provide_ranges : async (TextDocument, CancellationToken) -> CommentingRanges?,
) -> CommentingRangeProviderObject {
  commenting_range_provider_ffi((document, token) => {
    @js_async.Promise::from_async(async fn() {
      @v.option_to_js(provide_ranges(document, token))
    })
  })
}

///|
pub(open) trait AuthenticationProvider {
  on_did_change_sessions(Self) -> Event[
    AuthenticationProviderAuthenticationSessionsChangeEvent,
  ]
  async get_sessions(Self, Array[String]?, AuthenticationProviderSessionOptions) -> Array[
    AuthenticationSession,
  ]
  async create_session(
    Self,
    Array[String],
    AuthenticationProviderSessionOptions,
  ) -> AuthenticationSession
  async remove_session(Self, String) -> Unit
}

///|
pub impl AuthenticationProvider for AuthenticationProviderObject with on_did_change_sessions(
  self,
) {
  authentication_provider_on_did_change_sessions(self)
}

///|
pub impl AuthenticationProvider for AuthenticationProviderObject with get_sessions(
  self,
  scopes,
  options,
) {
  authentication_session_array_from_js(
    @js_async.Promise::wait(
      authentication_provider_get_sessions_promise(
        self,
        @v.option_to_js(scopes),
        authentication_provider_session_options_to_js(options),
      ),
    ),
  )
}

///|
pub impl AuthenticationProvider for AuthenticationProviderObject with create_session(
  self,
  scopes,
  options,
) {
  let raw = @js_async.Promise::wait(
    authentication_provider_create_session_promise(
      self,
      scopes,
      authentication_provider_session_options_to_js(options),
    ),
  )
  match authentication_session_from_js(raw) {
    Some(value) => value
    None => raw.cast()
  }
}

///|
pub impl AuthenticationProvider for AuthenticationProviderObject with remove_session(
  self,
  session_id,
) {
  @js_async.Promise::wait(
    authentication_provider_remove_session_promise(self, session_id),
  )
}

///|
pub fn AuthenticationProviderObject::new(
  on_did_change_sessions : Event[
    AuthenticationProviderAuthenticationSessionsChangeEvent,
  ],
  get_sessions : async (Array[String]?, AuthenticationProviderSessionOptions) -> Array[
    AuthenticationSession,
  ],
  create_session : async (Array[String], AuthenticationProviderSessionOptions) -> AuthenticationSession,
  remove_session : async (String) -> Unit,
) -> AuthenticationProviderObject {
  let on_did_change_sessions_js : @v.JsValue = authentication_provider_map_event_ffi(
    @v.JsValue::make(on_did_change_sessions),
    value => {
      let decoded : AuthenticationProviderAuthenticationSessionsChangeEvent = value.cast()
      authentication_provider_auth_sessions_change_event_to_js(decoded)
    },
  )
  authentication_provider_ffi(
    on_did_change_sessions_js,
    (scopes, options_raw) => {
      @js_async.Promise::from_async(async fn() {
        let scope_list : Array[String]? = if @v.JsValue::is_null_or_undefined(
            scopes,
          ) {
          None
        } else {
          Some(scopes.cast())
        }
        let options = authentication_provider_session_options_from_js(
          options_raw,
        )
        authentication_session_array_to_js(get_sessions(scope_list, options))
      })
    },
    (scopes, options_raw) => {
      @js_async.Promise::from_async(() => {
        authentication_session_to_js(
          create_session(
            scopes,
            authentication_provider_session_options_from_js(options_raw),
          ),
        )
      })
    },
    session_id => {
      @js_async.Promise::from_async(() => remove_session(session_id))
    },
  )
}

///|
fn authentication_provider_session_options_to_js(
  options : AuthenticationProviderSessionOptions,
) -> @v.JsValue {
  authentication_provider_session_options_to_js_ffi(
    match options.account {
      None => @v.JsValue::make(())
      Some(account) => authentication_session_account_information_to_js(account)
    },
  )
}

///|
fn authentication_provider_session_options_from_js(
  value : @v.JsValue,
) -> AuthenticationProviderSessionOptions {
  let account_raw = authentication_provider_session_options_account_raw(value)
  if account_raw.is_null_or_undefined() {
    AuthenticationProviderSessionOptions::new()
  } else {
    match authentication_session_account_information_from_js(account_raw) {
      Some(account) => AuthenticationProviderSessionOptions::new(account~)
      None =>
        AuthenticationProviderSessionOptions::new(account=account_raw.cast())
    }
  }
}

///|
fn authentication_provider_on_did_change_sessions(
  provider : AuthenticationProviderObject,
) -> Event[AuthenticationProviderAuthenticationSessionsChangeEvent] {
  authentication_provider_map_event_ffi(
    authentication_provider_on_did_change_sessions_raw(provider),
    value => {
      @v.JsValue::make(
        authentication_provider_auth_sessions_change_event_from_js(value),
      )
    },
  ).cast()
}

///|
fn authentication_provider_auth_sessions_change_event_to_js(
  value : AuthenticationProviderAuthenticationSessionsChangeEvent,
) -> @v.JsValue {
  authentication_provider_auth_sessions_change_event_to_js_ffi(
    authentication_session_array_to_js(value.added),
    authentication_session_array_to_js(value.removed),
    authentication_session_array_to_js(value.changed),
  )
}

///|
fn authentication_provider_auth_sessions_change_event_from_js(
  value : @v.JsValue,
) -> AuthenticationProviderAuthenticationSessionsChangeEvent {
  let added_raw = authentication_provider_auth_sessions_change_event_added_raw(
    value,
  )
  let removed_raw = authentication_provider_auth_sessions_change_event_removed_raw(
    value,
  )
  let changed_raw = authentication_provider_auth_sessions_change_event_changed_raw(
    value,
  )
  AuthenticationProviderAuthenticationSessionsChangeEvent::new(
    added=if added_raw.is_null_or_undefined() {
      []
    } else {
      authentication_session_array_from_js(added_raw.cast())
    },
    removed=if removed_raw.is_null_or_undefined() {
      []
    } else {
      authentication_session_array_from_js(removed_raw.cast())
    },
    changed=if changed_raw.is_null_or_undefined() {
      []
    } else {
      authentication_session_array_from_js(changed_raw.cast())
    },
  )
}

///|
fn authentication_session_array_to_js(
  values : Array[AuthenticationSession],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(authentication_session_to_js(value))
  }
  encoded
}

///|
fn authentication_session_array_from_js(
  values : Array[@v.JsValue],
) -> Array[AuthenticationSession] {
  let decoded : Array[AuthenticationSession] = []
  for value in values {
    match authentication_session_from_js(value) {
      Some(session) => decoded.push(session)
      None => decoded.push(value.cast())
    }
  }
  decoded
}

///|
fn authentication_session_to_js(value : AuthenticationSession) -> @v.JsValue {
  authentication_session_to_js_ffi(
    value.id(),
    value.access_token(),
    authentication_session_account_information_to_js(value.account()),
    value.scopes(),
  )
}

///|
fn authentication_session_from_js(value : @v.JsValue) -> AuthenticationSession? {
  let id_raw = authentication_session_id_raw(value)
  let access_token_raw = authentication_session_access_token_raw(value)
  let account_raw = authentication_session_account_raw(value)
  let scopes_raw = authentication_session_scopes_raw(value)
  match
    (
      providers_js_value_as_string_ffi(id_raw),
      providers_js_value_as_string_ffi(access_token_raw),
      authentication_session_account_information_from_js(account_raw),
    ) {
    (Some(id), Some(access_token), Some(account)) =>
      if scopes_raw.is_null_or_undefined() {
        None
      } else {
        Some(
          AuthenticationSession::new(
            id,
            access_token,
            account,
            scopes_raw.cast(),
          ),
        )
      }
    _ => None
  }
}

///|
fn authentication_session_account_information_to_js(
  value : AuthenticationSessionAccountInformation,
) -> @v.JsValue {
  authentication_session_account_information_to_js_ffi(
    value.id(),
    value.label(),
  )
}

///|
fn authentication_session_account_information_from_js(
  value : @v.JsValue,
) -> AuthenticationSessionAccountInformation? {
  let id_raw = authentication_session_account_information_id_raw(value)
  let label_raw = authentication_session_account_information_label_raw(value)
  match
    (
      providers_js_value_as_string_ffi(id_raw),
      providers_js_value_as_string_ffi(label_raw),
    ) {
    (Some(id), Some(label)) =>
      Some(AuthenticationSessionAccountInformation::new(id, label))
    _ => None
  }
}

///|
pub(open) trait TaskProvider {
  async provide_tasks(Self, CancellationToken) -> Array[Task]?
  async resolve_task(Self, Task, CancellationToken) -> Task?
}

///|
pub impl TaskProvider for TaskProviderObject with provide_tasks(self, token) {
  TaskProviderObject::provide_tasks(self, token)
}

///|
pub impl TaskProvider for TaskProviderObject with resolve_task(
  self,
  task,
  token,
) {
  TaskProviderObject::resolve_task(self, task, token)
}

///|
pub fn TaskProviderObject::new(
  provide_tasks : async (CancellationToken) -> Array[Task]?,
  resolve_task? : async (Task, CancellationToken) -> Task?,
) -> TaskProviderObject {
  let resolve_callback : ((Task, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_task {
    None => None
    Some(value) =>
      Some((task, token) => {
        @js_async.Promise::from_async(async fn() {
          @v.option_to_js(value(task, token))
        })
      })
  }
  task_provider_ffi(
    token => {
      @js_async.Promise::from_async(async fn() {
        @v.option_to_js(provide_tasks(token))
      })
    },
    @v.option_to_js(resolve_callback),
  )
}

///|
pub fn TerminalLinkProviderObject::new(
  provide_links : async (TerminalLinkContext, CancellationToken) -> Array[
    TerminalLink,
  ]?,
  handle_link? : async (TerminalLink) -> Unit,
) -> TerminalLinkProviderObject {
  let handle_callback : ((TerminalLink) -> @js_async.Promise[Unit])? = match
    handle_link {
    None => None
    Some(value) =>
      Some(link => @js_async.Promise::from_async(() => value(link)))
  }
  terminal_link_provider_ffi(
    (context, token) => {
      @js_async.Promise::from_async(async fn() {
        let link_context = terminal_link_context_from_js(
          @v.JsValue::make(context),
        )
        @v.option_to_js(provide_links(link_context, token))
      })
    },
    @v.option_to_js(handle_callback),
  )
}

///|
pub fn TerminalProfileProviderObject::new(
  provide_profile : async (CancellationToken) -> TerminalProfile?,
) -> TerminalProfileProviderObject {
  terminal_profile_provider_ffi(token => {
    @js_async.Promise::from_async(async fn() {
      option_terminal_profile_to_js(provide_profile(token))
    })
  })
}

///|
pub fn CustomTextEditorProviderObject::new(
  resolve_custom_text_editor : async (
    TextDocument,
    WebviewPanel,
    CancellationToken,
  ) -> Unit,
) -> CustomTextEditorProviderObject {
  custom_text_editor_provider_ffi((document, panel, token) => {
    @js_async.Promise::from_async(async fn() {
      resolve_custom_text_editor(document, panel, token)
    })
  })
}

///|
pub fn CustomReadonlyEditorProviderObject::new(
  open_custom_document : async (
    Uri,
    CustomDocumentOpenContext,
    CancellationToken,
  ) -> CustomDocument,
  resolve_custom_editor : async (
    CustomDocument,
    WebviewPanel,
    CancellationToken,
  ) -> Unit,
) -> CustomReadonlyEditorProviderObject {
  custom_readonly_editor_provider_ffi(
    (uri, context, token) => {
      @js_async.Promise::from_async(async fn() {
        open_custom_document(uri, context, token)
      })
    },
    (document, panel, token) => {
      @js_async.Promise::from_async(async fn() {
        resolve_custom_editor(document, panel, token)
      })
    },
  )
}

///|
pub fn CustomEditorProviderObject::new(
  open_custom_document : async (
    Uri,
    CustomDocumentOpenContext,
    CancellationToken,
  ) -> CustomDocument,
  resolve_custom_editor : async (
    CustomDocument,
    WebviewPanel,
    CancellationToken,
  ) -> Unit,
  save_custom_document : async (CustomDocument, CancellationToken) -> Unit,
  save_custom_document_as : async (CustomDocument, Uri, CancellationToken) -> Unit,
  revert_custom_document : async (CustomDocument, CancellationToken) -> Unit,
  backup_custom_document : async (
    CustomDocument,
    CustomDocumentBackupContext,
    CancellationToken,
  ) -> CustomDocumentBackup,
  on_did_change_custom_document? : Event[
    CustomDocumentChangeEvent[CustomDocument],
  ],
) -> CustomEditorProviderObject {
  custom_editor_provider_ffi(
    (uri, context, token) => {
      @js_async.Promise::from_async(async fn() {
        open_custom_document(uri, context, token)
      })
    },
    (document, panel, token) => {
      @js_async.Promise::from_async(async fn() {
        resolve_custom_editor(document, panel, token)
      })
    },
    (document, token) => {
      @js_async.Promise::from_async(async fn() {
        save_custom_document(document, token)
      })
    },
    (document, destination, token) => {
      @js_async.Promise::from_async(async fn() {
        save_custom_document_as(document, destination, token)
      })
    },
    (document, token) => {
      @js_async.Promise::from_async(async fn() {
        revert_custom_document(document, token)
      })
    },
    (document, context, token) => {
      @js_async.Promise::from_async(async fn() {
        custom_document_backup_to_js(
          backup_custom_document(document, context, token),
        )
      })
    },
    @v.option_to_js(on_did_change_custom_document),
  )
}

///|
pub fn[T] TreeDataProviderObject::new(
  get_tree_item : async (T) -> TreeItem,
  get_children : async (T?) -> Array[T]?,
  on_did_change_tree_data? : Event[T?],
  get_parent? : async (T) -> T?,
  resolve_tree_item? : async (TreeItem, T, CancellationToken) -> TreeItem?,
) -> TreeDataProviderObject[T] {
  let get_parent_value : ((@v.JsValue) -> @js_async.Promise[@v.JsValue])? = match
    get_parent {
    None => None
    Some(callback) =>
      Some(element => {
        @js_async.Promise::from_async(async fn() {
          let value : T = element.cast()
          @v.option_to_js(callback(value))
        })
      })
  }
  let resolve_value : ((TreeItem, @v.JsValue, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_tree_item {
    None => None
    Some(callback) =>
      Some((item, element, token) => {
        @js_async.Promise::from_async(async fn() {
          let value : T = element.cast()
          @v.option_to_js(callback(item, value, token))
        })
      })
  }
  let provider : TreeDataProviderObject[@v.JsValue] = tree_data_provider_ffi(
    element => {
      @js_async.Promise::from_async(async fn() {
        let value : T = element.cast()
        @v.JsValue::make(get_tree_item(value))
      })
    },
    element => {
      @js_async.Promise::from_async(async fn() {
        let value : T? = if element.is_null_or_undefined() {
          None
        } else {
          Some(element.cast())
        }
        @v.option_to_js(get_children(value))
      })
    },
    @v.option_to_js(on_did_change_tree_data),
    @v.option_to_js(get_parent_value),
    @v.option_to_js(resolve_value),
  )
  @v.JsValue::make(provider).cast()
}

///|
pub fn WebviewViewProviderObject::new(
  resolve_view : async (
    WebviewView,
    WebviewViewResolveContext,
    CancellationToken,
  ) -> Unit,
) -> WebviewViewProviderObject {
  webview_view_provider_ffi((view, context, token) => {
    @js_async.Promise::from_async(() => resolve_view(view, context, token))
  })
}

///|
extern "js" fn authentication_provider_on_did_change_sessions_raw(
  provider : AuthenticationProviderObject,
) -> @v.JsValue =
  #| (provider) => provider.onDidChangeSessions

///|
extern "js" fn authentication_provider_get_sessions_promise(
  provider : AuthenticationProviderObject,
  scopes : @v.JsValue,
  options : @v.JsValue,
) -> @js_async.Promise[Array[@v.JsValue]] =
  #| (provider, scopes, options) => {
  #|   return scopes === undefined || scopes === null
  #|     ? provider.getSessions(undefined, options)
  #|     : provider.getSessions(scopes, options);
  #| }

///|
extern "js" fn authentication_provider_create_session_promise(
  provider : AuthenticationProviderObject,
  scopes : Array[String],
  options : @v.JsValue,
) -> @js_async.Promise[@v.JsValue] =
  #| (provider, scopes, options) => provider.createSession(scopes, options)

///|
extern "js" fn authentication_provider_map_event_ffi(
  event : @v.JsValue,
  mapper : (@v.JsValue) -> @v.JsValue,
) -> @v.JsValue =
  #| (event, mapper) => (listener, thisArg, disposables) =>
  #|   event((value) => listener.call(thisArg, mapper(value)), thisArg, disposables)

///|
extern "js" fn authentication_provider_auth_sessions_change_event_to_js_ffi(
  added : Array[@v.JsValue],
  removed : Array[@v.JsValue],
  changed : Array[@v.JsValue],
) -> @v.JsValue =
  #| (added, removed, changed) => ({ added, removed, changed })

///|
extern "js" fn authentication_provider_auth_sessions_change_event_added_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.added

///|
extern "js" fn authentication_provider_auth_sessions_change_event_removed_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.removed

///|
extern "js" fn authentication_provider_auth_sessions_change_event_changed_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.changed

///|
extern "js" fn authentication_session_to_js_ffi(
  id : String,
  access_token : String,
  account : @v.JsValue,
  scopes : Array[String],
) -> @v.JsValue =
  #| (id, accessToken, account, scopes) => ({ id, accessToken, account, scopes })

///|
extern "js" fn authentication_session_account_information_to_js_ffi(
  id : String,
  label : String,
) -> @v.JsValue =
  #| (id, label) => ({ id, label })

///|
extern "js" fn providers_js_value_as_string_ffi(value : @v.JsValue) -> String? =
  #| (value) => typeof value === "string" ? value : undefined

///|
extern "js" fn providers_js_value_is_array_ffi(value : @v.JsValue) -> Bool =
  #| (value) => Array.isArray(value)

///|
extern "js" fn hover_to_js_ffi(
  contents : Array[@v.JsValue],
  range : @v.JsValue,
) -> @v.JsValue =
  #| (contents, range) => {
  #|   const value = new (require("vscode").Hover)(contents, range);
  #|   return value;
  #| }

///|
extern "js" fn parameter_label_range_to_js_ffi(
  start : Int,
  end : Int,
) -> @v.JsValue =
  #| (start, end) => [start, end]

///|
extern "js" fn parameter_information_to_js_ffi(
  label : @v.JsValue,
  documentation : @v.JsValue,
) -> @v.JsValue =
  #| (label, documentation) => {
  #|   const hasDoc = documentation !== undefined && documentation !== null;
  #|   return hasDoc
  #|     ? new (require("vscode").ParameterInformation)(label, documentation)
  #|     : new (require("vscode").ParameterInformation)(label);
  #| }

///|
extern "js" fn signature_information_to_js_ffi(
  label : String,
  documentation : @v.JsValue,
  parameters : Array[@v.JsValue],
  active_parameter : @v.JsValue,
) -> @v.JsValue =
  #| (label, documentation, parameters, activeParameter) => {
  #|   const hasDoc = documentation !== undefined && documentation !== null;
  #|   const value = hasDoc
  #|     ? new (require("vscode").SignatureInformation)(label, documentation)
  #|     : new (require("vscode").SignatureInformation)(label);
  #|   value.parameters = parameters;
  #|   if (activeParameter !== undefined && activeParameter !== null) {
  #|     value.activeParameter = activeParameter;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn signature_help_to_js_ffi(
  signatures : Array[@v.JsValue],
  active_signature : Int,
  active_parameter : Int,
) -> @v.JsValue =
  #| (signatures, activeSignature, activeParameter) => {
  #|   const value = new (require("vscode").SignatureHelp)();
  #|   value.signatures = signatures;
  #|   value.activeSignature = activeSignature;
  #|   value.activeParameter = activeParameter;
  #|   return value;
  #| }

///|
extern "js" fn inlay_hint_to_js_ffi(
  position : Position,
  label : @v.JsValue,
  kind : @v.JsValue,
) -> @v.JsValue =
  #| (position, label, kind) => {
  #|   const hasKind = kind !== undefined && kind !== null;
  #|   return hasKind
  #|     ? new (require("vscode").InlayHint)(position, label, kind)
  #|     : new (require("vscode").InlayHint)(position, label);
  #| }

///|
extern "js" fn inlay_hint_label_part_to_js_ffi(value : String) -> @v.JsValue =
  #| (value) => new (require("vscode").InlayHintLabelPart)(value)

///|
extern "js" fn inlay_hint_position_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.position

///|
extern "js" fn inlay_hint_label_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.label

///|
extern "js" fn inlay_hint_kind_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.kind

///|
extern "js" fn inlay_hint_label_part_value_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.value

///|
extern "js" fn inline_completion_item_to_js_ffi(
  insert_text : @v.JsValue,
  range : @v.JsValue,
  command : @v.JsValue,
) -> @v.JsValue =
  #| (insertText, range, command) => {
  #|   const hasRange = range !== undefined && range !== null;
  #|   const hasCommand = command !== undefined && command !== null;
  #|   if (hasRange && hasCommand) {
  #|     return new (require("vscode").InlineCompletionItem)(insertText, range, command);
  #|   }
  #|   if (hasRange) {
  #|     return new (require("vscode").InlineCompletionItem)(insertText, range);
  #|   }
  #|   return new (require("vscode").InlineCompletionItem)(insertText);
  #| }

///|
extern "js" fn inline_completion_list_to_js_ffi(
  items : Array[@v.JsValue],
) -> @v.JsValue =
  #| (items) => new (require("vscode").InlineCompletionList)(items)

///|
extern "js" fn inline_value_text_to_js_ffi(
  range : Range,
  text : String,
) -> @v.JsValue =
  #| (range, text) => new (require("vscode").InlineValueText)(range, text)

///|
extern "js" fn inline_value_variable_lookup_to_js_ffi(
  range : Range,
  variable_name : @v.JsValue,
  case_sensitive_lookup : Bool,
) -> @v.JsValue =
  #| (range, variableName, caseSensitiveLookup) =>
  #|   new (require("vscode").InlineValueVariableLookup)(range, variableName, caseSensitiveLookup)

///|
extern "js" fn inline_value_evaluatable_expression_to_js_ffi(
  range : Range,
  expression : @v.JsValue,
) -> @v.JsValue =
  #| (range, expression) =>
  #|   new (require("vscode").InlineValueEvaluatableExpression)(range, expression)

///|
extern "js" fn terminal_profile_to_js_ffi(
  value : TerminalProfile,
) -> @v.JsValue =
  #| (value) => value

///|
extern "js" fn custom_document_backup_to_js_ffi(
  value : CustomDocumentBackup,
) -> @v.JsValue =
  #| (value) => value

///|
extern "js" fn completion_context_trigger_kind_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.triggerKind

///|
extern "js" fn completion_context_trigger_character_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.triggerCharacter

///|
extern "js" fn code_action_context_diagnostics_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.diagnostics

///|
extern "js" fn code_action_context_only_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.only

///|
extern "js" fn code_action_context_trigger_kind_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.triggerKind

///|
extern "js" fn call_hierarchy_item_kind_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.kind

///|
extern "js" fn call_hierarchy_item_name_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.name

///|
extern "js" fn call_hierarchy_item_detail_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.detail

///|
extern "js" fn call_hierarchy_item_uri_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.uri

///|
extern "js" fn call_hierarchy_item_range_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.range

///|
extern "js" fn call_hierarchy_item_selection_range_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.selectionRange

///|
extern "js" fn call_hierarchy_item_to_js_ffi(
  kind : @vscode.SymbolKind,
  name : String,
  detail : String,
  uri : Uri,
  range : Range,
  selection_range : Range,
) -> @v.JsValue =
  #| (kind, name, detail, uri, range, selectionRange) => ({
  #|   kind,
  #|   name,
  #|   detail,
  #|   uri,
  #|   range,
  #|   selectionRange,
  #| })

///|
extern "js" fn call_hierarchy_incoming_call_to_js_ffi(
  from_item : @v.JsValue,
  from_ranges : Array[Range],
) -> @v.JsValue =
  #| (fromItem, fromRanges) => ({ from: fromItem, fromRanges })

///|
extern "js" fn call_hierarchy_outgoing_call_to_js_ffi(
  to_item : @v.JsValue,
  from_ranges : Array[Range],
) -> @v.JsValue =
  #| (toItem, fromRanges) => ({ to: toItem, fromRanges })

///|
extern "js" fn selected_completion_info_range_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.range

///|
extern "js" fn selected_completion_info_text_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.text

///|
extern "js" fn inline_completion_context_trigger_kind_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.triggerKind

///|
extern "js" fn inline_completion_context_selected_info_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.selectedCompletionInfo

///|
extern "js" fn inline_value_context_frame_id_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.frameId

///|
extern "js" fn inline_value_context_stopped_location_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.stoppedLocation

///|
extern "js" fn document_paste_edit_context_trigger_kind_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.triggerKind

///|
extern "js" fn document_paste_edit_context_only_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.only

///|
extern "js" fn document_drop_or_paste_kind_value_raw(
  value : @v.JsValue,
) -> String =
  #| (value) => {
  #|   if (value === undefined || value === null) return "";
  #|   return typeof value.value === "string" ? value.value : "";
  #| }

///|
extern "js" fn terminal_link_context_line_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.line

///|
extern "js" fn terminal_link_context_terminal_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.terminal

///|
extern "js" fn authentication_session_id_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.id

///|
extern "js" fn authentication_session_access_token_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.accessToken

///|
extern "js" fn authentication_session_account_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.account

///|
extern "js" fn authentication_session_scopes_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.scopes

///|
extern "js" fn authentication_session_account_information_id_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.id

///|
extern "js" fn authentication_session_account_information_label_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.label

///|
extern "js" fn authentication_provider_remove_session_promise(
  provider : AuthenticationProviderObject,
  session_id : String,
) -> @js_async.Promise[Unit] =
  #| (provider, sessionId) => provider.removeSession(sessionId)

///|
extern "js" fn hover_provider_ffi(
  provide_hover : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> HoverProviderObject =
  #| (provideHover) => ({ provideHover })

///|
extern "js" fn signature_help_provider_ffi(
  provide_help : (
    TextDocument,
    Position,
    CancellationToken,
    SignatureHelpContext,
  ) -> @js_async.Promise[@v.JsValue],
) -> SignatureHelpProviderObject =
  #| (provideSignatureHelp) => ({ provideSignatureHelp })

///|
extern "js" fn completion_item_provider_ffi(
  provide_items : (TextDocument, Position, CancellationToken, CompletionContext) -> @js_async.Promise[
    @v.JsValue,
  ],
  resolve_item : @v.JsValue,
) -> CompletionItemProviderObject[CompletionItem] =
  #| (provideCompletionItems, resolveItem) => {
  #|   const provider = { provideCompletionItems };
  #|   if (resolveItem !== undefined && resolveItem !== null) {
  #|     provider.resolveCompletionItem = resolveItem;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn definition_provider_ffi(
  provide_definition : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> DefinitionProviderObject =
  #| (provideDefinition) => ({ provideDefinition })

///|
extern "js" fn implementation_provider_ffi(
  provide_implementation : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> ImplementationProviderObject =
  #| (provideImplementation) => ({ provideImplementation })

///|
extern "js" fn type_definition_provider_ffi(
  provide_definition : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> TypeDefinitionProviderObject =
  #| (provideTypeDefinition) => ({ provideTypeDefinition })

///|
extern "js" fn declaration_provider_ffi(
  provide_declaration : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> DeclarationProviderObject =
  #| (provideDeclaration) => ({ provideDeclaration })

///|
extern "js" fn reference_provider_ffi(
  provide_references : (
    TextDocument,
    Position,
    ReferenceContext,
    CancellationToken,
  ) -> @js_async.Promise[@v.JsValue],
) -> ReferenceProviderObject =
  #| (provideReferences) => ({ provideReferences })

///|
extern "js" fn document_highlight_provider_ffi(
  provide_highlights : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> DocumentHighlightProviderObject =
  #| (provideDocumentHighlights) => ({ provideDocumentHighlights })

///|
extern "js" fn code_action_provider_ffi(
  provide_actions : (TextDocument, Range, CodeActionContext, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  resolve_action : @v.JsValue,
) -> CodeActionProviderObject[CodeAction] =
  #| (provideCodeActions, resolveCodeAction) => {
  #|   const provider = { provideCodeActions };
  #|   if (resolveCodeAction !== undefined && resolveCodeAction !== null) {
  #|     provider.resolveCodeAction = resolveCodeAction;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn document_formatting_provider_ffi(
  provide_edits : (TextDocument, FormattingOptions, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> DocumentFormattingEditProviderObject =
  #| (provideDocumentFormattingEdits) => ({ provideDocumentFormattingEdits })

///|
extern "js" fn document_range_formatting_provider_ffi(
  provide_edits : (TextDocument, Range, FormattingOptions, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> DocumentRangeFormattingEditProviderObject =
  #| (provideDocumentRangeFormattingEdits) => ({ provideDocumentRangeFormattingEdits })

///|
extern "js" fn on_type_formatting_provider_ffi(
  provide_edits : (
    TextDocument,
    Position,
    String,
    FormattingOptions,
    CancellationToken,
  ) -> @js_async.Promise[@v.JsValue],
) -> OnTypeFormattingEditProviderObject =
  #| (provideOnTypeFormattingEdits) => ({ provideOnTypeFormattingEdits })

///|
extern "js" fn document_link_provider_ffi(
  provide_links : (TextDocument, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  resolve_link : @v.JsValue,
) -> DocumentLinkProviderObject[DocumentLink] =
  #| (provideDocumentLinks, resolveDocumentLink) => {
  #|   const provider = { provideDocumentLinks };
  #|   if (resolveDocumentLink !== undefined && resolveDocumentLink !== null) {
  #|     provider.resolveDocumentLink = resolveDocumentLink;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn code_lens_provider_ffi(
  provide_lenses : (TextDocument, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  resolve_lens : @v.JsValue,
  on_did_change : @v.JsValue,
) -> CodeLensProviderObject[CodeLens] =
  #| (provideCodeLenses, resolveCodeLens, onDidChangeCodeLenses) => {
  #|   const provider = { provideCodeLenses };
  #|   if (resolveCodeLens !== undefined && resolveCodeLens !== null) {
  #|     provider.resolveCodeLens = resolveCodeLens;
  #|   }
  #|   if (onDidChangeCodeLenses !== undefined && onDidChangeCodeLenses !== null) {
  #|     provider.onDidChangeCodeLenses = onDidChangeCodeLenses;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn document_color_provider_ffi(
  provide_colors : (TextDocument, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  provide_presentations : (Color, ColorPresentationContext, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> DocumentColorProviderObject =
  #| (provideDocumentColors, provideColorPresentations) => ({
  #|   provideDocumentColors,
  #|   provideColorPresentations,
  #| })

///|
extern "js" fn folding_range_provider_ffi(
  provide_ranges : (TextDocument, FoldingContext, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> FoldingRangeProviderObject =
  #| (provideFoldingRanges) => ({ provideFoldingRanges })

///|
extern "js" fn document_symbol_provider_ffi(
  provide_symbols : (TextDocument, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> DocumentSymbolProviderObject =
  #| (provideDocumentSymbols) => ({ provideDocumentSymbols })

///|
extern "js" fn workspace_symbol_provider_ffi(
  provide_symbols : (String, CancellationToken) -> @js_async.Promise[@v.JsValue],
  resolve_symbol : @v.JsValue,
) -> WorkspaceSymbolProviderObject[SymbolInformation] =
  #| (provideWorkspaceSymbols, resolveWorkspaceSymbol) => {
  #|   const provider = { provideWorkspaceSymbols };
  #|   if (resolveWorkspaceSymbol !== undefined && resolveWorkspaceSymbol !== null) {
  #|     provider.resolveWorkspaceSymbol = resolveWorkspaceSymbol;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn call_hierarchy_provider_ffi(
  prepare : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  incoming_calls : (CallHierarchyItem, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  outgoing_calls : (CallHierarchyItem, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> CallHierarchyProviderObject =
  #| (prepareCallHierarchy, provideCallHierarchyIncomingCalls, provideCallHierarchyOutgoingCalls) => ({
  #|   prepareCallHierarchy,
  #|   provideCallHierarchyIncomingCalls,
  #|   provideCallHierarchyOutgoingCalls,
  #| })

///|
extern "js" fn type_hierarchy_provider_ffi(
  prepare : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  supertypes : (TypeHierarchyItem, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  subtypes : (TypeHierarchyItem, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> TypeHierarchyProviderObject =
  #| (prepareTypeHierarchy, provideTypeHierarchySupertypes, provideTypeHierarchySubtypes) => ({
  #|   prepareTypeHierarchy,
  #|   provideTypeHierarchySupertypes,
  #|   provideTypeHierarchySubtypes,
  #| })

///|
extern "js" fn inlay_hints_provider_ffi(
  provide_hints : (TextDocument, Range, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  resolve_hint : @v.JsValue,
) -> InlayHintsProviderObject[InlayHint] =
  #| (provideInlayHints, resolveInlayHint) => {
  #|   const provider = { provideInlayHints };
  #|   if (resolveInlayHint !== undefined && resolveInlayHint !== null) {
  #|     provider.resolveInlayHint = resolveInlayHint;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn document_semantic_tokens_provider_ffi(
  provide_tokens : (TextDocument, CancellationToken) -> @js_async.Promise[
    SemanticTokens,
  ],
  provide_edits : @v.JsValue,
  on_did_change : @v.JsValue,
) -> DocumentSemanticTokensProviderObject =
  #| (provideDocumentSemanticTokens, provideDocumentSemanticTokensEdits, onDidChangeSemanticTokens) => {
  #|   const provider = { provideDocumentSemanticTokens };
  #|   if (provideDocumentSemanticTokensEdits !== undefined && provideDocumentSemanticTokensEdits !== null) {
  #|     provider.provideDocumentSemanticTokensEdits = provideDocumentSemanticTokensEdits;
  #|   }
  #|   if (onDidChangeSemanticTokens !== undefined && onDidChangeSemanticTokens !== null) {
  #|     provider.onDidChangeSemanticTokens = onDidChangeSemanticTokens;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn document_range_semantic_tokens_provider_ffi(
  provide_tokens : (TextDocument, Range, CancellationToken) -> @js_async.Promise[
    SemanticTokens,
  ],
) -> DocumentRangeSemanticTokensProviderObject =
  #| (provideDocumentRangeSemanticTokens) => ({ provideDocumentRangeSemanticTokens })

///|
extern "js" fn inline_completion_item_provider_ffi(
  provide_items : (
    TextDocument,
    Position,
    InlineCompletionContext,
    CancellationToken,
  ) -> @js_async.Promise[@v.JsValue],
) -> InlineCompletionItemProviderObject =
  #| (provideInlineCompletionItems) => ({ provideInlineCompletionItems })

///|
extern "js" fn inline_values_provider_ffi(
  provide_values : (TextDocument, Range, InlineValueContext, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> InlineValuesProviderObject =
  #| (provideInlineValues) => ({ provideInlineValues })

///|
extern "js" fn providers_document_drop_edit_provider_metadata_to_js_ffi(
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
extern "js" fn providers_document_paste_provider_metadata_to_js_ffi(
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
extern "js" fn document_drop_edit_provider_ffi(
  provide_edit : (TextDocument, Position, DataTransfer, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  metadata : @v.JsValue,
) -> DocumentDropEditProviderObject =
  #| (provideDocumentDropEdits, metadata) => {
  #|   const provider = { provideDocumentDropEdits };
  #|   if (metadata !== undefined && metadata !== null) {
  #|     provider.metadata = metadata;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn document_paste_edit_provider_ffi(
  provide_edit : (
    TextDocument,
    Array[Range],
    DataTransfer,
    DocumentPasteEditContext,
    CancellationToken,
  ) -> @js_async.Promise[@v.JsValue],
  metadata : @v.JsValue,
) -> DocumentPasteEditProviderObject =
  #| (provideDocumentPasteEdits, metadata) => {
  #|   const provider = { provideDocumentPasteEdits };
  #|   if (metadata !== undefined && metadata !== null) {
  #|     provider.metadata = metadata;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn rename_provider_ffi(
  provide_edits : (TextDocument, Position, String, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  prepare_rename : @v.JsValue,
) -> RenameProviderObject =
  #| (provideRenameEdits, prepareRename) => {
  #|   const provider = { provideRenameEdits };
  #|   if (prepareRename !== undefined && prepareRename !== null) {
  #|     provider.prepareRename = prepareRename;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn selection_range_provider_ffi(
  provide_ranges : (TextDocument, Array[Position], CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> SelectionRangeProviderObject =
  #| (provideSelectionRanges) => ({ provideSelectionRanges })

///|
extern "js" fn linked_editing_range_provider_ffi(
  provide_ranges : (TextDocument, Position, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> LinkedEditingRangeProviderObject =
  #| (provideLinkedEditingRanges) => ({ provideLinkedEditingRanges })

///|
extern "js" fn quick_diff_provider_ffi(
  provide_original : (Uri, CancellationToken) -> @js_async.Promise[@v.JsValue],
) -> QuickDiffProviderObject =
  #| (provideOriginalResource) => ({ provideOriginalResource })

///|
extern "js" fn text_document_content_provider_ffi(
  provide_content : (Uri, CancellationToken) -> @js_async.Promise[String],
  on_did_change : @v.JsValue,
) -> TextDocumentContentProviderObject =
  #| (provideTextDocumentContent, onDidChange) => {
  #|   const provider = { provideTextDocumentContent };
  #|   if (onDidChange !== undefined && onDidChange !== null) {
  #|     provider.onDidChange = onDidChange;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn file_decoration_provider_ffi(
  provide_decoration : (Uri, CancellationToken) -> @js_async.Promise[@v.JsValue],
  on_did_change : @v.JsValue,
) -> FileDecorationProviderObject =
  #| (provideFileDecoration, onDidChangeFileDecorations) => {
  #|   const provider = { provideFileDecoration };
  #|   if (onDidChangeFileDecorations !== undefined && onDidChangeFileDecorations !== null) {
  #|     provider.onDidChangeFileDecorations = onDidChangeFileDecorations;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn commenting_range_provider_ffi(
  provide_commenting_ranges : (TextDocument, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> CommentingRangeProviderObject =
  #| (provideCommentingRanges) => ({ provideCommentingRanges })

///|
extern "js" fn authentication_provider_ffi(
  on_did_change_sessions : @v.JsValue,
  get_sessions : (@v.JsValue, @v.JsValue) -> @js_async.Promise[
    Array[@v.JsValue],
  ],
  create_session : (Array[String], @v.JsValue) -> @js_async.Promise[@v.JsValue],
  remove_session : (String) -> @js_async.Promise[Unit],
) -> AuthenticationProviderObject =
  #| (onDidChangeSessions, getSessions, createSession, removeSession) => ({
  #|   onDidChangeSessions,
  #|   getSessions,
  #|   createSession,
  #|   removeSession,
  #| })

///|
extern "js" fn authentication_provider_session_options_to_js_ffi(
  account : @v.JsValue,
) -> @v.JsValue =
  #| (account) => ({ account })

///|
extern "js" fn authentication_provider_session_options_account_raw(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.account

///|
extern "js" fn task_provider_ffi(
  provide_tasks : (CancellationToken) -> @js_async.Promise[@v.JsValue],
  resolve_task : @v.JsValue,
) -> TaskProviderObject =
  #| (provideTasks, resolveTask) => {
  #|   const provider = { provideTasks };
  #|   if (resolveTask !== undefined && resolveTask !== null) {
  #|     provider.resolveTask = resolveTask;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn terminal_link_provider_ffi(
  provide_links : (TerminalLinkContext, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  handle_link : @v.JsValue,
) -> TerminalLinkProviderObject =
  #| (provideTerminalLinks, handleTerminalLink) => {
  #|   const provider = { provideTerminalLinks };
  #|   if (handleTerminalLink !== undefined && handleTerminalLink !== null) {
  #|     provider.handleTerminalLink = handleTerminalLink;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn terminal_profile_provider_ffi(
  provide_profile : (CancellationToken) -> @js_async.Promise[@v.JsValue],
) -> TerminalProfileProviderObject =
  #| (provideTerminalProfile) => ({ provideTerminalProfile })

///|
extern "js" fn custom_text_editor_provider_ffi(
  resolve_custom_text_editor : (TextDocument, WebviewPanel, CancellationToken) -> @js_async.Promise[
    Unit,
  ],
) -> CustomTextEditorProviderObject =
  #| (resolveCustomTextEditor) => ({ resolveCustomTextEditor })

///|
extern "js" fn custom_readonly_editor_provider_ffi(
  open_custom_document : (Uri, CustomDocumentOpenContext, CancellationToken) -> @js_async.Promise[
    CustomDocument,
  ],
  resolve_custom_editor : (CustomDocument, WebviewPanel, CancellationToken) -> @js_async.Promise[
    Unit,
  ],
) -> CustomReadonlyEditorProviderObject =
  #| (openCustomDocument, resolveCustomEditor) => ({
  #|   openCustomDocument,
  #|   resolveCustomEditor,
  #| })

///|
extern "js" fn custom_editor_provider_ffi(
  open_custom_document : (Uri, CustomDocumentOpenContext, CancellationToken) -> @js_async.Promise[
    CustomDocument,
  ],
  resolve_custom_editor : (CustomDocument, WebviewPanel, CancellationToken) -> @js_async.Promise[
    Unit,
  ],
  save_custom_document : (CustomDocument, CancellationToken) -> @js_async.Promise[
    Unit,
  ],
  save_custom_document_as : (CustomDocument, Uri, CancellationToken) -> @js_async.Promise[
    Unit,
  ],
  revert_custom_document : (CustomDocument, CancellationToken) -> @js_async.Promise[
    Unit,
  ],
  backup_custom_document : (
    CustomDocument,
    CustomDocumentBackupContext,
    CancellationToken,
  ) -> @js_async.Promise[@v.JsValue],
  on_did_change_custom_document : @v.JsValue,
) -> CustomEditorProviderObject =
  #| (openCustomDocument, resolveCustomEditor, saveCustomDocument, saveCustomDocumentAs, revertCustomDocument, backupCustomDocument, onDidChangeCustomDocument) => {
  #|   const provider = {
  #|     openCustomDocument,
  #|     resolveCustomEditor,
  #|     saveCustomDocument,
  #|     saveCustomDocumentAs,
  #|     revertCustomDocument,
  #|     backupCustomDocument,
  #|   };
  #|   if (onDidChangeCustomDocument !== undefined && onDidChangeCustomDocument !== null) {
  #|     provider.onDidChangeCustomDocument = onDidChangeCustomDocument;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn tree_data_provider_ffi(
  get_tree_item : (@v.JsValue) -> @js_async.Promise[@v.JsValue],
  get_children : (@v.JsValue) -> @js_async.Promise[@v.JsValue],
  on_did_change_tree_data : @v.JsValue,
  get_parent : @v.JsValue,
  resolve_tree_item : @v.JsValue,
) -> TreeDataProviderObject[@v.JsValue] =
  #| (getTreeItem, getChildren, onDidChangeTreeData, getParent, resolveTreeItem) => {
  #|   const provider = { getTreeItem, getChildren };
  #|   if (onDidChangeTreeData !== undefined && onDidChangeTreeData !== null) {
  #|     provider.onDidChangeTreeData = onDidChangeTreeData;
  #|   }
  #|   if (getParent !== undefined && getParent !== null) provider.getParent = getParent;
  #|   if (resolveTreeItem !== undefined && resolveTreeItem !== null) {
  #|     provider.resolveTreeItem = resolveTreeItem;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn webview_view_provider_ffi(
  resolve_view : (WebviewView, WebviewViewResolveContext, CancellationToken) -> @js_async.Promise[
    Unit,
  ],
) -> WebviewViewProviderObject =
  #| (resolveWebviewView) => ({ resolveWebviewView })

///|
/// Internal JS carrier for vscode.FileSystemProvider.
priv type Uint8Array

///|
pub type FileSystemProviderObject

///|
fn bytes_to_uint8_array(value : Bytes) -> Uint8Array {
  @v.JsValue::make(value).cast()
}

///|
fn bytes_from_uint8_array(value : Uint8Array) -> Bytes {
  @v.JsValue::make(value).cast()
}

///|
pub fn FileSystemProviderObject::on_did_change_file(
  self : FileSystemProviderObject,
) -> @vscode.Event[Array[@vscode.FileChangeEvent]] {
  file_system_provider_on_did_change_file_event_ffi(self).cast()
}

///|
extern "js" fn file_system_provider_on_did_change_file_event_ffi(
  provider : FileSystemProviderObject,
) -> @v.JsValue =
  #| (provider) => (listener, thisArg, disposables) =>
  #|   provider.onDidChangeFile(
  #|     (events) => listener(events.map((e) => ({ uri: e.uri, type_: e.type }))),
  #|     thisArg,
  #|     disposables,
  #|   )

///|
pub extern "js" fn FileSystemProviderObject::watch(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
  recursive : Bool,
  excludes : Array[String],
) -> @vscode.Disposable =
  #| (provider, uri, recursive, excludes) =>
  #|   provider.watch(uri, { recursive, excludes })

///|
extern "js" fn FileSystemProviderObject::stat_promise(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
) -> @js_async.Promise[@v.JsValue] =
  #| (provider, uri) => Promise.resolve(provider.stat(uri))

///|
fn file_stat_from_js(value : @v.JsValue) -> @vscode.FileStat {
  let permissions_raw = file_stat_permissions_raw(value)
  @vscode.FileStat::{
    file_type: file_stat_type_raw(value),
    ctime: file_stat_ctime_raw(value),
    mtime: file_stat_mtime_raw(value),
    size: file_stat_size_raw(value),
    permissions: if permissions_raw.is_null_or_undefined() {
      None
    } else {
      Some(permissions_raw.cast())
    },
  }
}

///|
fn file_stat_to_js(value : @vscode.FileStat) -> @v.JsValue {
  file_stat_to_js_ffi(
    value.file_type,
    value.ctime,
    value.mtime,
    value.size,
    @v.option_to_js(value.permissions),
  )
}

///|
pub async fn FileSystemProviderObject::stat(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
) -> @vscode.FileStat {
  file_stat_from_js(
    @js_async.Promise::wait(FileSystemProviderObject::stat_promise(self, uri)),
  )
}

///|
extern "js" fn FileSystemProviderObject::read_directory_promise(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
) -> @js_async.Promise[Array[@vscode.DirectoryEntry]] =
  #| (provider, uri) => Promise.resolve(provider.readDirectory(uri))

///|
pub async fn FileSystemProviderObject::read_directory(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
) -> Array[@vscode.DirectoryEntry] {
  @js_async.Promise::wait(
    FileSystemProviderObject::read_directory_promise(self, uri),
  )
}

///|
extern "js" fn FileSystemProviderObject::create_directory_promise(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
) -> @js_async.Promise[Unit] =
  #| (provider, uri) => Promise.resolve(provider.createDirectory(uri))

///|
pub async fn FileSystemProviderObject::create_directory(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
) -> Unit {
  @js_async.Promise::wait(
    FileSystemProviderObject::create_directory_promise(self, uri),
  )
}

///|
extern "js" fn FileSystemProviderObject::read_file_promise(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
) -> @js_async.Promise[Uint8Array] =
  #| (provider, uri) => Promise.resolve(provider.readFile(uri))

///|
pub async fn FileSystemProviderObject::read_file(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
) -> Bytes {
  bytes_from_uint8_array(
    @js_async.Promise::wait(
      FileSystemProviderObject::read_file_promise(self, uri),
    ),
  )
}

///|
extern "js" fn FileSystemProviderObject::write_file_promise(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
  content : Uint8Array,
  create : Bool,
  overwrite : Bool,
) -> @js_async.Promise[Unit] =
  #| (provider, uri, content, create, overwrite) =>
  #|   Promise.resolve(provider.writeFile(uri, content, { create, overwrite }))

///|
pub async fn FileSystemProviderObject::write_file(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
  content : Bytes,
  create : Bool,
  overwrite : Bool,
) -> Unit {
  @js_async.Promise::wait(
    FileSystemProviderObject::write_file_promise(
      self,
      uri,
      bytes_to_uint8_array(content),
      create,
      overwrite,
    ),
  )
}

///|
extern "js" fn FileSystemProviderObject::delete_promise(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
  recursive : Bool,
) -> @js_async.Promise[Unit] =
  #| (provider, uri, recursive) =>
  #|   Promise.resolve(provider.delete(uri, { recursive }))

///|
pub async fn FileSystemProviderObject::delete(
  self : FileSystemProviderObject,
  uri : @vscode.Uri,
  recursive : Bool,
) -> Unit {
  @js_async.Promise::wait(
    FileSystemProviderObject::delete_promise(self, uri, recursive),
  )
}

///|
extern "js" fn FileSystemProviderObject::rename_promise(
  self : FileSystemProviderObject,
  old_uri : @vscode.Uri,
  new_uri : @vscode.Uri,
  overwrite : Bool,
) -> @js_async.Promise[Unit] =
  #| (provider, oldUri, newUri, overwrite) =>
  #|   Promise.resolve(provider.rename(oldUri, newUri, { overwrite }))

///|
pub async fn FileSystemProviderObject::rename(
  self : FileSystemProviderObject,
  old_uri : @vscode.Uri,
  new_uri : @vscode.Uri,
  overwrite : Bool,
) -> Unit {
  @js_async.Promise::wait(
    FileSystemProviderObject::rename_promise(self, old_uri, new_uri, overwrite),
  )
}

///|
extern "js" fn FileSystemProviderObject::copy_promise(
  self : FileSystemProviderObject,
  source : @vscode.Uri,
  destination : @vscode.Uri,
  overwrite : Bool,
) -> @js_async.Promise[Unit] =
  #| (provider, source, destination, overwrite) =>
  #|   Promise.resolve(provider.copy(source, destination, { overwrite }))

///|
pub async fn FileSystemProviderObject::copy(
  self : FileSystemProviderObject,
  source : @vscode.Uri,
  destination : @vscode.Uri,
  overwrite : Bool,
) -> Unit {
  @js_async.Promise::wait(
    FileSystemProviderObject::copy_promise(self, source, destination, overwrite),
  )
}

///|
extern "js" fn file_change_event_array_event_to_js_ffi(
  event : @vscode.Event[Array[@vscode.FileChangeEvent]],
) -> @v.JsValue =
  #| (event) => (listener, thisArg, disposables) =>
  #|   event(
  #|     (events) => listener(events.map((e) => ({ uri: e.uri, type: e.type_ }))),
  #|     thisArg,
  #|     disposables,
  #|   )

///|
pub fn FileSystemProviderObject::new(
  on_did_change_file : @vscode.Event[Array[@vscode.FileChangeEvent]],
  watch : (@vscode.Uri, Bool, Array[String]) -> @vscode.Disposable,
  stat : async (@vscode.Uri) -> @vscode.FileStat,
  read_directory : async (@vscode.Uri) -> Array[@vscode.DirectoryEntry],
  create_directory : async (@vscode.Uri) -> Unit,
  read_file : async (@vscode.Uri) -> Bytes,
  write_file : async (@vscode.Uri, Bytes, Bool, Bool) -> Unit,
  delete_file : async (@vscode.Uri, Bool) -> Unit,
  rename_file : async (@vscode.Uri, @vscode.Uri, Bool) -> Unit,
  copy_file? : async (@vscode.Uri, @vscode.Uri, Bool) -> Unit,
) -> FileSystemProviderObject {
  let copy_callback : ((@vscode.Uri, @vscode.Uri, Bool) -> @js_async.Promise[
    Unit,
  ])? = match copy_file {
    None => None
    Some(value) =>
      Some((source, destination, overwrite) => {
        @js_async.Promise::from_async(() => {
          value(source, destination, overwrite)
        })
      })
  }
  file_system_provider_ffi(
    file_change_event_array_event_to_js_ffi(on_did_change_file),
    watch,
    uri => {
      @js_async.Promise::from_async(async fn() { file_stat_to_js(stat(uri)) })
    },
    uri => @js_async.Promise::from_async(() => read_directory(uri)),
    uri => @js_async.Promise::from_async(() => create_directory(uri)),
    uri => @js_async.Promise::from_async(() => read_file(uri)),
    (uri, content, create, overwrite) => {
      @js_async.Promise::from_async(() => {
        write_file(uri, content, create, overwrite)
      })
    },
    (uri, recursive) => {
      @js_async.Promise::from_async(() => delete_file(uri, recursive))
    },
    (old_uri, new_uri, overwrite) => {
      @js_async.Promise::from_async(() => {
        rename_file(old_uri, new_uri, overwrite)
      })
    },
    @v.option_to_js(copy_callback),
  )
}

///|
extern "js" fn file_system_provider_ffi(
  on_did_change_file : @v.JsValue,
  watch : (@vscode.Uri, Bool, Array[String]) -> @vscode.Disposable,
  stat : (@vscode.Uri) -> @js_async.Promise[@v.JsValue],
  read_directory : (@vscode.Uri) -> @js_async.Promise[
    Array[@vscode.DirectoryEntry],
  ],
  create_directory : (@vscode.Uri) -> @js_async.Promise[Unit],
  read_file : (@vscode.Uri) -> @js_async.Promise[Bytes],
  write_file : (@vscode.Uri, Bytes, Bool, Bool) -> @js_async.Promise[Unit],
  delete_file : (@vscode.Uri, Bool) -> @js_async.Promise[Unit],
  rename_file : (@vscode.Uri, @vscode.Uri, Bool) -> @js_async.Promise[Unit],
  copy_file : @v.JsValue,
) -> FileSystemProviderObject =
  #| (onDidChangeFile, watch, stat, readDirectory, createDirectory, readFile, writeFile, deleteFile, renameFile, copyFile) => {
  #|   const provider = {
  #|     onDidChangeFile,
  #|     watch: (uri, options) => watch(uri, options.recursive, options.excludes),
  #|     stat,
  #|     readDirectory,
  #|     createDirectory,
  #|     readFile,
  #|     writeFile: (uri, content, options) =>
  #|       writeFile(uri, content, options.create, options.overwrite),
  #|     delete: (uri, options) => deleteFile(uri, options.recursive),
  #|     rename: (oldUri, newUri, options) =>
  #|       renameFile(oldUri, newUri, options.overwrite),
  #|   };
  #|   if (copyFile !== undefined && copyFile !== null) {
  #|     provider.copy = (source, destination, options) =>
  #|       copyFile(source, destination, options.overwrite);
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn file_stat_to_js_ffi(
  file_type : @vscode.FileType,
  ctime : Int,
  mtime : Int,
  size : Int,
  permissions : @v.JsValue,
) -> @v.JsValue =
  #| (type, ctime, mtime, size, permissions) => ({
  #|   type,
  #|   ctime,
  #|   mtime,
  #|   size,
  #|   permissions,
  #| })

///|
extern "js" fn file_stat_type_raw(value : @v.JsValue) -> @vscode.FileType =
  #| (value) => value.type

///|
extern "js" fn file_stat_ctime_raw(value : @v.JsValue) -> Int =
  #| (value) => value.ctime

///|
extern "js" fn file_stat_mtime_raw(value : @v.JsValue) -> Int =
  #| (value) => value.mtime

///|
extern "js" fn file_stat_size_raw(value : @v.JsValue) -> Int =
  #| (value) => value.size

///|
extern "js" fn file_stat_permissions_raw(value : @v.JsValue) -> @v.JsValue =
  #| (value) => value.permissions

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with on_did_change_file(
  self,
) {
  FileSystemProviderObject::on_did_change_file(self)
}

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with watch(
  self,
  uri,
  recursive,
  excludes,
) {
  FileSystemProviderObject::watch(self, uri, recursive, excludes)
}

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with stat(
  self,
  uri,
) {
  FileSystemProviderObject::stat(self, uri)
}

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with read_directory(
  self,
  uri,
) {
  FileSystemProviderObject::read_directory(self, uri)
}

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with create_directory(
  self,
  uri,
) {
  FileSystemProviderObject::create_directory(self, uri)
}

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with read_file(
  self,
  uri,
) {
  FileSystemProviderObject::read_file(self, uri)
}

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with write_file(
  self,
  uri,
  content,
  create,
  overwrite,
) {
  FileSystemProviderObject::write_file(self, uri, content, create, overwrite)
}

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with delete(
  self,
  uri,
  recursive,
) {
  FileSystemProviderObject::delete(self, uri, recursive)
}

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with rename(
  self,
  old_uri,
  new_uri,
  overwrite,
) {
  FileSystemProviderObject::rename(self, old_uri, new_uri, overwrite)
}

///|
pub impl @vscode.FileSystemProvider for FileSystemProviderObject with copy(
  self,
  source,
  destination,
  overwrite,
) {
  FileSystemProviderObject::copy(self, source, destination, overwrite)
}
