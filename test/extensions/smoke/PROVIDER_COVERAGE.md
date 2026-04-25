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
| `InlineCompletionItemProvider` | covered | `editor.action.inlineSuggest.trigger` | Verifies provider state and commits the returned inline suggestion. |
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
| `DocumentDropEditProvider` | covered | `npm run test:ui` document drop | Dispatches an editor drop with `text/plain`, waits for the provided drop edit, and captures a screenshot. |
| `DocumentPasteEditProvider` | covered | `editor.action.pasteAs` | Verifies paste edit selection through clipboard/workbench flow. |
| `QuickDiffProvider` | covered | `editor.action.dirtydiff.next` | Uses `SourceControl.quickDiffProvider` and verifies original-resource resolution. |
| `CommentingRangeProvider` | covered | `editor.action.nextCommentingRange` | Uses a comment controller and verifies provider state. |
| `TextDocumentContentProvider` | covered | `workspace.openTextDocument` with custom scheme |  |
| `FileSystemProvider` | covered | `workspace.fs` with custom scheme | Also validates provider disposables at shutdown. |
| `WebviewViewProvider` | covered | `vscode-mbt-smoke-webview.focus`, `npm run test:ui` | Verifies resolve state and webview HTML through a state command, then captures the rendered webview view. |
| `TerminalLinkProvider` | covered | `npm run test:ui` terminal link | Uses an extension-owned pseudoterminal, hovers the provided link, clicks it, and verifies the handler notification before screenshot capture. |
| `TerminalProfileProvider` | covered | `npm run test:ui` terminal profile | Registers a contributed terminal profile, triggers workbench profile creation, and captures the extension-owned terminal output. |
| `FileDecorationProvider` | covered | `revealInExplorer`, `npm run test:ui` | Reveals a fixture file, verifies provider state, and captures the rendered file decoration. |
