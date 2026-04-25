# Provider Smoke Coverage

This checklist maps provider traits in `provider_traits.js.mbt` to the smoke extension coverage in this directory. Keep it updated when adding provider bindings or new integration cases.

Status keys:

- `covered`: Exercised by `suite/smoke.test.js` with a stable command or API call.
- `covered-internal`: Exercised through a VS Code internal command because no public `vscode.execute*` command exists.
- `pending-harness`: Binding exists, but the smoke harness still needs a reliable way to trigger it.
- `ui-backed`: Best validated by a UI or screenshot test because behavior is visual or workbench driven.

| Provider trait | Status | Smoke trigger | Notes |
| --- | --- | --- | --- |
| `CompletionItemProvider` | covered | `vscode.executeCompletionItemProvider` | Includes resolve path. |
| `InlineCompletionItemProvider` | pending-harness | none | No stable command found in the current extension-host harness. |
| `CodeActionProvider` | covered | `vscode.executeCodeActionProvider` | Includes resolve path. |
| `CodeLensProvider` | covered | `vscode.executeCodeLensProvider` | Includes resolve path. |
| `DefinitionProvider` | covered | `vscode.executeDefinitionProvider` |  |
| `ImplementationProvider` | covered | `vscode.executeImplementationProvider` |  |
| `TypeDefinitionProvider` | covered | `vscode.executeTypeDefinitionProvider` |  |
| `DeclarationProvider` | covered | `vscode.executeDeclarationProvider` |  |
| `HoverProvider` | covered | `vscode.executeHoverProvider` |  |
| `InlineValuesProvider` | covered | `vscode.executeInlineValueProvider` |  |
| `DocumentHighlightProvider` | covered | `vscode.executeDocumentHighlights` |  |
| `DocumentSymbolProvider` | covered | `vscode.executeDocumentSymbolProvider` |  |
| `WorkspaceSymbolProvider` | covered | `vscode.executeWorkspaceSymbolProvider` | Includes resolve path. |
| `ReferenceProvider` | covered | `vscode.executeReferenceProvider` |  |
| `RenameProvider` | covered | `vscode.executeDocumentRenameProvider`, `vscode.prepareRename` | Includes prepare path. |
| `DocumentSemanticTokensProvider` | covered | `vscode.provideDocumentSemanticTokensLegend`, `vscode.provideDocumentSemanticTokens` |  |
| `DocumentRangeSemanticTokensProvider` | covered | `vscode.provideDocumentRangeSemanticTokensLegend`, `vscode.provideDocumentRangeSemanticTokens` |  |
| `DocumentFormattingEditProvider` | covered | `vscode.executeFormatDocumentProvider` |  |
| `DocumentRangeFormattingEditProvider` | covered | `vscode.executeFormatRangeProvider` |  |
| `OnTypeFormattingEditProvider` | covered | `vscode.executeFormatOnTypeProvider` |  |
| `SignatureHelpProvider` | covered | `vscode.executeSignatureHelpProvider` |  |
| `DocumentLinkProvider` | covered | `vscode.executeLinkProvider` | Includes resolve path. |
| `DocumentColorProvider` | covered | `vscode.executeDocumentColorProvider`, `vscode.executeColorPresentationProvider` |  |
| `InlayHintsProvider` | covered | `vscode.executeInlayHintProvider` | Includes resolve path. |
| `FoldingRangeProvider` | covered | `vscode.executeFoldingRangeProvider` |  |
| `SelectionRangeProvider` | covered | `vscode.executeSelectionRangeProvider` |  |
| `CallHierarchyProvider` | covered | `vscode.prepareCallHierarchy`, `vscode.provideIncomingCalls`, `vscode.provideOutgoingCalls` |  |
| `TypeHierarchyProvider` | covered | `vscode.prepareTypeHierarchy`, `vscode.provideSupertypes`, `vscode.provideSubtypes` |  |
| `LinkedEditingRangeProvider` | covered-internal | `_executeLinkedEditingProvider` | Internal command returns Monaco range objects. |
| `DocumentDropEditProvider` | pending-harness | none | Drop behavior is workbench/UI driven. |
| `DocumentPasteEditProvider` | covered | `editor.action.pasteAs` | Verifies paste edit selection through clipboard/workbench flow. |
| `QuickDiffProvider` | covered | `editor.action.dirtydiff.next` | Uses `SourceControl.quickDiffProvider` and verifies original-resource resolution. |
| `CommentingRangeProvider` | covered | `editor.action.nextCommentingRange` | Uses a comment controller and verifies provider state. |
| `TextDocumentContentProvider` | covered | `workspace.openTextDocument` with custom scheme |  |
| `FileSystemProvider` | covered | `workspace.fs` with custom scheme | Also validates provider disposables at shutdown. |
| `WebviewViewProvider` | covered | `vscode-mbt-smoke-webview.focus` | Verifies resolve state and webview HTML through a state command. |
| `TerminalLinkProvider` | ui-backed | none | Needs terminal UI link detection. |
| `TerminalProfileProvider` | ui-backed | none | Public registration works, but provider invocation is workbench profile/UI driven. |
| `FileDecorationProvider` | covered | `revealInExplorer` | Reveals a fixture file and verifies provider state. |
