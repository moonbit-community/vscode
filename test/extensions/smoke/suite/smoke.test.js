const assert = require('assert');
const fs = require('fs');
const path = require('path');
const { TextDecoder } = require('util');
const vscode = require('vscode');

async function runCase(name, fn) {
  try {
    await fn();
    console.log(`ok - ${name}`);
  } catch (error) {
    error.message = `${name}: ${error.message}`;
    throw error;
  }
}

function applyTextEdits(document, edits) {
  return [...edits]
    .sort((left, right) => document.offsetAt(right.range.start) - document.offsetAt(left.range.start))
    .reduce((text, edit) => {
      const start = document.offsetAt(edit.range.start);
      const end = document.offsetAt(edit.range.end);
      return `${text.slice(0, start)}${edit.newText}${text.slice(end)}`;
    }, document.getText());
}

function rangeTuple(range) {
  return [
    range.start.line,
    range.start.character,
    range.end.line,
    range.end.character
  ];
}

function monacoRangeTuple(range) {
  return [
    range.startLineNumber - 1,
    range.startColumn - 1,
    range.endLineNumber - 1,
    range.endColumn - 1
  ];
}

function parseWebviewViewState(value) {
  const [resolveCount, viewType, title, description, ...htmlParts] = value.split('|');
  return {
    resolveCount: Number(resolveCount),
    viewType,
    title,
    description,
    html: htmlParts.join('|')
  };
}

async function waitForWebviewViewState(predicate) {
  let state = parseWebviewViewState(
    await vscode.commands.executeCommand('vscode-mbt-tests.webviewView', 'read')
  );
  for (let attempt = 0; attempt < 20; attempt += 1) {
    if (predicate(state)) {
      return state;
    }
    await new Promise(resolve => setTimeout(resolve, 50));
    state = parseWebviewViewState(
      await vscode.commands.executeCommand('vscode-mbt-tests.webviewView', 'read')
    );
  }
  assert.fail(`webview view provider was not called: ${JSON.stringify(state)}`);
}

function parseFileDecorationState(value) {
  const [provideCount, sawTarget, lastUri, badge, tooltip] = value.split('|');
  return {
    provideCount: Number(provideCount),
    sawTarget: sawTarget === 'true',
    lastUri,
    badge,
    tooltip
  };
}

function parseInlineCompletionState(value) {
  const [provideCount, lastUri, lastLine, lastCharacter, triggerKind, itemText] = value.split('|');
  return {
    provideCount: Number(provideCount),
    lastUri,
    lastLine: Number(lastLine),
    lastCharacter: Number(lastCharacter),
    triggerKind,
    itemText
  };
}

function parseDocumentPasteState(value) {
  const [provideCount, rangeCount, clipboardText, triggerKind, onlyKind, editTitle] = value.split('|');
  return {
    provideCount: Number(provideCount),
    rangeCount: Number(rangeCount),
    clipboardText,
    triggerKind,
    onlyKind,
    editTitle
  };
}

function parseCommentingRangeState(value) {
  const [provideCount, lastUri, rangeCount, enableFileComments] = value.split('|');
  return {
    provideCount: Number(provideCount),
    lastUri,
    rangeCount: Number(rangeCount),
    enableFileComments: enableFileComments === 'true'
  };
}

function parseQuickDiffState(value) {
  const [provideCount, lastUri, originalUri] = value.split('|');
  return {
    provideCount: Number(provideCount),
    lastUri,
    originalUri
  };
}

async function waitForFileDecorationState(predicate) {
  let state = parseFileDecorationState(
    await vscode.commands.executeCommand('vscode-mbt-tests.fileDecoration', 'read')
  );
  for (let attempt = 0; attempt < 20; attempt += 1) {
    if (predicate(state)) {
      return state;
    }
    await new Promise(resolve => setTimeout(resolve, 50));
    state = parseFileDecorationState(
      await vscode.commands.executeCommand('vscode-mbt-tests.fileDecoration', 'read')
    );
  }
  assert.fail(`file decoration provider was not called: ${JSON.stringify(state)}`);
}

async function waitForInlineCompletionState(predicate) {
  let state = parseInlineCompletionState(
    await vscode.commands.executeCommand('vscode-mbt-tests.inlineCompletion', 'read')
  );
  for (let attempt = 0; attempt < 30; attempt += 1) {
    if (predicate(state)) {
      return state;
    }
    await new Promise(resolve => setTimeout(resolve, 50));
    state = parseInlineCompletionState(
      await vscode.commands.executeCommand('vscode-mbt-tests.inlineCompletion', 'read')
    );
  }
  assert.fail(`inline completion provider was not called: ${JSON.stringify(state)}`);
}

async function waitForDocumentText(document, predicate) {
  for (let attempt = 0; attempt < 20; attempt += 1) {
    const text = document.getText();
    if (predicate(text)) {
      return text;
    }
    await new Promise(resolve => setTimeout(resolve, 50));
  }
  assert.fail(`document text did not match: ${document.getText()}`);
}

async function waitForCommentingRangeState(predicate) {
  let state = parseCommentingRangeState(
    await vscode.commands.executeCommand('vscode-mbt-tests.commentingRange', 'read')
  );
  for (let attempt = 0; attempt < 30; attempt += 1) {
    if (predicate(state)) {
      return state;
    }
    await new Promise(resolve => setTimeout(resolve, 50));
    state = parseCommentingRangeState(
      await vscode.commands.executeCommand('vscode-mbt-tests.commentingRange', 'read')
    );
  }
  assert.fail(`commenting range provider was not called: ${JSON.stringify(state)}`);
}

async function waitForQuickDiffState(predicate) {
  let state = parseQuickDiffState(
    await vscode.commands.executeCommand('vscode-mbt-tests.quickDiff', 'read')
  );
  for (let attempt = 0; attempt < 30; attempt += 1) {
    if (predicate(state)) {
      return state;
    }
    await new Promise(resolve => setTimeout(resolve, 50));
    state = parseQuickDiffState(
      await vscode.commands.executeCommand('vscode-mbt-tests.quickDiff', 'read')
    );
  }
  assert.fail(`quick diff provider was not called: ${JSON.stringify(state)}`);
}

function documentationText(value) {
  return value && typeof value === 'object' ? value.value : value;
}

function assertApproxEqual(actual, expected) {
  assert.ok(Math.abs(actual - expected) < 0.000001, `${actual} !== ${expected}`);
}

async function run() {
  await runCase('registers and executes MoonBit command handlers', async () => {
    const value = await vscode.commands.executeCommand('vscode-mbt-tests.echo', 'api');
    assert.strictEqual(value, 'moonbit:api');

    const hasEcho = await vscode.commands.executeCommand(
      'vscode-mbt-tests.hasCommand',
      'vscode-mbt-tests.echo'
    );
    assert.strictEqual(hasEcho, true);
  });

  await runCase('creates and mutates a status bar item through the binding', async () => {
    const value = await vscode.commands.executeCommand('vscode-mbt-tests.statusBar');
    assert.strictEqual(value, 'vscode-mbt-tests.status|MoonBit binding smoke');
  });

  await runCase('applies a WorkspaceEdit to an open document', async () => {
    const fixturePath = path.join(__dirname, '..', 'fixture', 'workspace-edit.txt');
    try {
      fs.writeFileSync(fixturePath, 'binding', 'utf8');

      const value = await vscode.commands.executeCommand(
        'vscode-mbt-tests.workspaceEdit',
        fixturePath
      );

      assert.strictEqual(value, 'moonbit:binding');
    } finally {
      fs.rmSync(fixturePath, { force: true });
    }
  });

  await runCase('fires EventEmitter listeners and disposes subscriptions', async () => {
    const value = await vscode.commands.executeCommand('vscode-mbt-tests.event');
    assert.strictEqual(value, '1|sync-1|1|async-1');
  });

  await runCase('serves items from a MoonBit TreeDataProvider', async () => {
    const value = await vscode.commands.executeCommand('vscode-mbt-tests.treeView');
    const [
      getChildrenCount,
      getTreeItemCount,
      getParentCount,
      selection,
      title,
      description,
      message
    ] = value.split('|');

    assert.ok(Number(getChildrenCount) >= 2, `getChildren count: ${getChildrenCount}`);
    assert.ok(Number(getTreeItemCount) >= 1, `getTreeItem count: ${getTreeItemCount}`);
    assert.ok(Number(getParentCount) >= 1, `getParent count: ${getParentCount}`);
    assert.strictEqual(selection, 'child');
    assert.strictEqual(title, 'MoonBit Smoke Tree');
    assert.strictEqual(description, 'provider');
    assert.strictEqual(message, 'ready');
  });

  await runCase('opens content from a MoonBit TextDocumentContentProvider', async () => {
    const uriText = await vscode.commands.executeCommand('vscode-mbt-tests.contentProviderUri');
    const document = await vscode.workspace.openTextDocument(vscode.Uri.parse(uriText));
    assert.strictEqual(
      document.getText(),
      'moonbit-provider|/provider-resource|source=moonbit'
    );
  });

  await runCase('serves completions from a MoonBit CompletionItemProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon.'
    });
    const completions = await vscode.commands.executeCommand(
      'vscode.executeCompletionItemProvider',
      document.uri,
      new vscode.Position(0, 5),
      '.',
      1
    );

    const item = completions.items.find(item => item.label === 'moonbit-completion');
    assert.ok(item, 'completion item was not returned');
    assert.strictEqual(item.kind, vscode.CompletionItemKind.Function);
    assert.strictEqual(item.insertText, 'moonbitInserted');
    assert.deepStrictEqual(item.commitCharacters, [';']);
    assert.strictEqual(item.documentation, 'resolved by MoonBit');
  });

  await runCase('serves inline completions from a MoonBit InlineCompletionItemProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon'
    });
    const editor = await vscode.window.showTextDocument(document);
    editor.selection = new vscode.Selection(0, 4, 0, 4);
    await vscode.commands.executeCommand('vscode-mbt-tests.inlineCompletion', 'reset');
    await vscode.commands.executeCommand('editor.action.inlineSuggest.trigger', { explicit: true });

    const state = await waitForInlineCompletionState(({ lastUri, triggerKind }) =>
      lastUri === document.uri.toString() && triggerKind === 'invoke'
    );
    assert.ok(state.provideCount >= 1, `provide count: ${state.provideCount}`);
    assert.strictEqual(state.lastLine, 0);
    assert.strictEqual(state.lastCharacter, 4);
    assert.strictEqual(state.itemText, 'bit-inline');

    await vscode.commands.executeCommand('editor.action.inlineSuggest.commit');
    const text = await waitForDocumentText(document, value => value === 'moonbit-inline');
    assert.strictEqual(text, 'moonbit-inline');
  });

  await runCase('serves code actions from a MoonBit CodeActionProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon action'
    });
    const actions = await vscode.commands.executeCommand(
      'vscode.executeCodeActionProvider',
      document.uri,
      new vscode.Range(new vscode.Position(0, 0), new vscode.Position(0, 4)),
      vscode.CodeActionKind.QuickFix.value,
      1
    );

    assert.strictEqual(actions.length, 1);
    assert.strictEqual(actions[0].title, 'MoonBit quick fix');
    assert.strictEqual(actions[0].kind.value, vscode.CodeActionKind.QuickFix.value);
    assert.strictEqual(actions[0].isPreferred, true);
    assert.strictEqual(actions[0].command.title, 'Apply MoonBit fix');
    assert.strictEqual(actions[0].command.command, 'vscode-mbt-tests.echo');
  });

  await runCase('serves code lenses from a MoonBit CodeLensProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon lens'
    });
    const lenses = await vscode.commands.executeCommand(
      'vscode.executeCodeLensProvider',
      document.uri,
      1
    );

    assert.strictEqual(lenses.length, 1);
    assert.strictEqual(lenses[0].command.title, 'MoonBit CodeLens');
    assert.strictEqual(lenses[0].command.command, 'vscode-mbt-tests.echo');
    assert.deepStrictEqual(
      [
        lenses[0].range.start.line,
        lenses[0].range.start.character,
        lenses[0].range.end.line,
        lenses[0].range.end.character
      ],
      [0, 0, 0, 4]
    );
  });

  await runCase('serves definitions from a MoonBit DefinitionProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon definition'
    });
    const locations = await vscode.commands.executeCommand(
      'vscode.executeDefinitionProvider',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(locations.length, 1);
    assert.strictEqual(locations[0].uri.toString(), document.uri.toString());
    assert.deepStrictEqual(
      [
        locations[0].range.start.line,
        locations[0].range.start.character,
        locations[0].range.end.line,
        locations[0].range.end.character
      ],
      [0, 0, 0, 4]
    );
  });

  await runCase('serves implementations from a MoonBit ImplementationProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon implementation'
    });
    const locations = await vscode.commands.executeCommand(
      'vscode.executeImplementationProvider',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(locations.length, 1);
    assert.strictEqual(locations[0].uri.toString(), document.uri.toString());
    assert.deepStrictEqual(
      [
        locations[0].range.start.line,
        locations[0].range.start.character,
        locations[0].range.end.line,
        locations[0].range.end.character
      ],
      [0, 5, 0, 19]
    );
  });

  await runCase('serves type definitions from a MoonBit TypeDefinitionProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon type definition'
    });
    const locations = await vscode.commands.executeCommand(
      'vscode.executeTypeDefinitionProvider',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(locations.length, 1);
    assert.strictEqual(locations[0].uri.toString(), document.uri.toString());
    assert.deepStrictEqual(
      [
        locations[0].range.start.line,
        locations[0].range.start.character,
        locations[0].range.end.line,
        locations[0].range.end.character
      ],
      [0, 5, 0, 19]
    );
  });

  await runCase('serves declarations from a MoonBit DeclarationProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon declaration'
    });
    const locations = await vscode.commands.executeCommand(
      'vscode.executeDeclarationProvider',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(locations.length, 1);
    assert.strictEqual(locations[0].uri.toString(), document.uri.toString());
    assert.deepStrictEqual(
      [
        locations[0].range.start.line,
        locations[0].range.start.character,
        locations[0].range.end.line,
        locations[0].range.end.character
      ],
      [0, 5, 0, 16]
    );
  });

  await runCase('serves document highlights from a MoonBit DocumentHighlightProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon highlight'
    });
    const highlights = await vscode.commands.executeCommand(
      'vscode.executeDocumentHighlights',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(highlights.length, 1);
    assert.strictEqual(highlights[0].kind, vscode.DocumentHighlightKind.Write);
    assert.deepStrictEqual(
      [
        highlights[0].range.start.line,
        highlights[0].range.start.character,
        highlights[0].range.end.line,
        highlights[0].range.end.character
      ],
      [0, 0, 0, 4]
    );
  });

  await runCase('serves document links from a MoonBit DocumentLinkProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon link'
    });
    const links = await vscode.commands.executeCommand(
      'vscode.executeLinkProvider',
      document.uri,
      1
    );

    assert.strictEqual(links.length, 1);
    assert.strictEqual(links[0].target.toString(), 'https://example.com/moonbit');
    assert.strictEqual(links[0].tooltip, 'MoonBit link');
    assert.deepStrictEqual(
      [
        links[0].range.start.line,
        links[0].range.start.character,
        links[0].range.end.line,
        links[0].range.end.character
      ],
      [0, 0, 0, 4]
    );
  });

  await runCase('serves document symbols from a MoonBit DocumentSymbolProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon symbol'
    });
    const symbols = await vscode.commands.executeCommand(
      'vscode.executeDocumentSymbolProvider',
      document.uri
    );

    assert.strictEqual(symbols.length, 1);
    assert.strictEqual(symbols[0].name, 'moonSymbol');
    assert.strictEqual(symbols[0].detail, 'MoonBit symbol detail');
    assert.strictEqual(symbols[0].kind, vscode.SymbolKind.Function);
    assert.deepStrictEqual(
      [
        symbols[0].range.start.line,
        symbols[0].range.start.character,
        symbols[0].range.end.line,
        symbols[0].range.end.character
      ],
      [0, 0, 0, 10]
    );
    assert.deepStrictEqual(
      [
        symbols[0].selectionRange.start.line,
        symbols[0].selectionRange.start.character,
        symbols[0].selectionRange.end.line,
        symbols[0].selectionRange.end.character
      ],
      [0, 0, 0, 4]
    );
  });

  await runCase('serves workspace symbols from a MoonBit WorkspaceSymbolProvider', async () => {
    const symbols = await vscode.commands.executeCommand(
      'vscode.executeWorkspaceSymbolProvider',
      'moon'
    );
    const symbol = symbols.find(symbol => symbol.name === 'moonWorkspaceSymbol');

    assert.ok(symbol, 'workspace symbol was not returned');
    assert.strictEqual(symbol.kind, vscode.SymbolKind.Function);
    assert.strictEqual(symbol.containerName, 'MoonBit container');
    assert.strictEqual(symbol.location.uri.toString(), 'file:///moonbit-workspace-symbol.mbt');
    assert.deepStrictEqual(rangeTuple(symbol.location.range), [0, 0, 0, 4]);
  });

  await runCase('serves hovers from a MoonBit HoverProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon hover'
    });
    const hovers = await vscode.commands.executeCommand(
      'vscode.executeHoverProvider',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(hovers.length, 1);
    assert.strictEqual(hovers[0].contents[0].value, 'hover from MoonBit');
    assert.deepStrictEqual(
      [
        hovers[0].range.start.line,
        hovers[0].range.start.character,
        hovers[0].range.end.line,
        hovers[0].range.end.character
      ],
      [0, 0, 0, 4]
    );
  });

  await runCase('serves references from a MoonBit ReferenceProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon reference'
    });
    const locations = await vscode.commands.executeCommand(
      'vscode.executeReferenceProvider',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(locations.length, 1);
    assert.strictEqual(locations[0].uri.toString(), document.uri.toString());
    assert.deepStrictEqual(
      [
        locations[0].range.start.line,
        locations[0].range.start.character,
        locations[0].range.end.line,
        locations[0].range.end.character
      ],
      [0, 0, 0, 4]
    );
  });

  await runCase('serves rename edits from a MoonBit RenameProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon rename'
    });
    const edit = await vscode.commands.executeCommand(
      'vscode.executeDocumentRenameProvider',
      document.uri,
      new vscode.Position(0, 1),
      'renamedMoon'
    );
    const entries = edit.entries();

    assert.strictEqual(entries.length, 1);
    assert.strictEqual(entries[0][0].toString(), document.uri.toString());
    assert.strictEqual(entries[0][1].length, 1);
    assert.strictEqual(entries[0][1][0].newText, 'renamedMoon');
    assert.deepStrictEqual(
      [
        entries[0][1][0].range.start.line,
        entries[0][1][0].range.start.character,
        entries[0][1][0].range.end.line,
        entries[0][1][0].range.end.character
      ],
      [0, 0, 0, 4]
    );
  });

  await runCase('prepares rename ranges from a MoonBit RenameProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon rename'
    });
    const result = await vscode.commands.executeCommand(
      'vscode.prepareRename',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.deepStrictEqual(rangeTuple(result.range), [0, 0, 0, 4]);
    assert.strictEqual(result.placeholder, 'moon');
  });

  await runCase('serves signature help from a MoonBit SignatureHelpProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon('
    });
    const help = await vscode.commands.executeCommand(
      'vscode.executeSignatureHelpProvider',
      document.uri,
      new vscode.Position(0, 5),
      '('
    );

    assert.strictEqual(help.activeSignature, 0);
    assert.strictEqual(help.activeParameter, 0);
    assert.strictEqual(help.signatures.length, 1);
    assert.strictEqual(help.signatures[0].label, 'moon(value: String)');
    assert.strictEqual(documentationText(help.signatures[0].documentation), 'signature from MoonBit');
    assert.strictEqual(help.signatures[0].parameters.length, 1);
    assert.strictEqual(help.signatures[0].parameters[0].label, 'value');
    assert.strictEqual(
      documentationText(help.signatures[0].parameters[0].documentation),
      'parameter from MoonBit'
    );
  });

  await runCase('serves document formatting edits from a MoonBit DocumentFormattingEditProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-document-formatting',
      content: 'format me'
    });
    const edits = await vscode.commands.executeCommand(
      'vscode.executeFormatDocumentProvider',
      document.uri,
      { tabSize: 2, insertSpaces: true }
    );

    assert.strictEqual(applyTextEdits(document, edits), 'doc:2:spaces:format me');
  });

  await runCase('serves range formatting edits from a MoonBit DocumentRangeFormattingEditProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-range-formatting',
      content: 'abcde format'
    });
    const range = new vscode.Range(new vscode.Position(0, 0), new vscode.Position(0, 5));
    const edits = await vscode.commands.executeCommand(
      'vscode.executeFormatRangeProvider',
      document.uri,
      range,
      { tabSize: 4, insertSpaces: false }
    );

    assert.strictEqual(applyTextEdits(document, edits), 'range:4:tabs format');
  });

  await runCase('serves on-type formatting edits from a MoonBit OnTypeFormattingEditProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-on-type-formatting',
      content: 'type format'
    });
    const edits = await vscode.commands.executeCommand(
      'vscode.executeFormatOnTypeProvider',
      document.uri,
      new vscode.Position(0, 4),
      '}',
      { tabSize: 3, insertSpaces: true }
    );

    assert.strictEqual(applyTextEdits(document, edits), 'typetype:}:3:spaces format');
  });

  await runCase('serves tasks from a MoonBit TaskProvider', async () => {
    const tasks = await vscode.tasks.fetchTasks({ type: 'vscode-mbt-smoke-task' });
    const task = tasks.find(task => task.name === 'MoonBit smoke task');

    assert.ok(task, 'task provider did not return the MoonBit smoke task');
    assert.strictEqual(task.source, 'MoonBit');
    assert.strictEqual(task.detail, 'provided by MoonBit');
    assert.strictEqual(task.definition.type, 'vscode-mbt-smoke-task');
    assert.strictEqual(task.definition.script, 'smoke');
    assert.strictEqual(task.definition.fromMoonBit, true);
    assert.strictEqual(task.group, vscode.TaskGroup.Test);
    assert.strictEqual(task.execution.commandLine, 'echo moonbit-task');
  });

  await runCase('serves accounts from a MoonBit AuthenticationProvider', async () => {
    const accounts = await vscode.authentication.getAccounts('vscode-mbt-smoke-auth');

    assert.strictEqual(accounts.length, 1);
    assert.strictEqual(accounts[0].id, 'moonbit-account');
    assert.strictEqual(accounts[0].label, 'MoonBit Account');
  });

  await runCase('serves document colors from a MoonBit DocumentColorProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: '#123456'
    });
    const colors = await vscode.commands.executeCommand(
      'vscode.executeDocumentColorProvider',
      document.uri
    );

    assert.strictEqual(colors.length, 1);
    assert.deepStrictEqual(rangeTuple(colors[0].range), [0, 0, 0, 7]);
    assertApproxEqual(colors[0].color.red, 0.1);
    assertApproxEqual(colors[0].color.green, 0.2);
    assertApproxEqual(colors[0].color.blue, 0.3);
    assertApproxEqual(colors[0].color.alpha, 0.4);
  });

  await runCase('serves color presentations from a MoonBit DocumentColorProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: '#abcdef'
    });
    const presentations = await vscode.commands.executeCommand(
      'vscode.executeColorPresentationProvider',
      new vscode.Color(0.1, 0.2, 0.3, 0.4),
      {
        uri: document.uri,
        range: new vscode.Range(new vscode.Position(0, 0), new vscode.Position(0, 7))
      }
    );

    assert.strictEqual(presentations.length, 1);
    assert.strictEqual(presentations[0].label, 'moon-color');
    assert.strictEqual(presentations[0].textEdit.newText, '#123456');
    assert.deepStrictEqual(rangeTuple(presentations[0].textEdit.range), [0, 0, 0, 7]);
    assert.strictEqual(presentations[0].additionalTextEdits.length, 1);
    assert.strictEqual(presentations[0].additionalTextEdits[0].newText, ' from MoonBit');
  });

  await runCase('serves inlay hints from a MoonBit InlayHintsProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'hint'
    });
    const hints = await vscode.commands.executeCommand(
      'vscode.executeInlayHintProvider',
      document.uri,
      new vscode.Range(new vscode.Position(0, 1), new vscode.Position(0, 4))
    );

    assert.strictEqual(hints.length, 1);
    assert.deepStrictEqual(
      [hints[0].position.line, hints[0].position.character],
      [0, 1]
    );
    assert.strictEqual(hints[0].label, ': MoonBit');
    assert.strictEqual(hints[0].kind, vscode.InlayHintKind.Type);
  });

  await runCase('serves inline values from a MoonBit InlineValuesProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'value'
    });
    const stoppedLocation = new vscode.Range(new vscode.Position(0, 0), new vscode.Position(0, 5));
    const values = await vscode.commands.executeCommand(
      'vscode.executeInlineValueProvider',
      document.uri,
      stoppedLocation,
      { frameId: 42, stoppedLocation }
    );

    assert.strictEqual(values.length, 1);
    assert.strictEqual(values[0].text, 'frame:42');
    assert.deepStrictEqual(rangeTuple(values[0].range), [0, 0, 0, 5]);
  });

  await runCase('serves semantic tokens from a MoonBit DocumentSemanticTokensProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-semantic-tokens',
      content: 'moon'
    });
    const legend = await vscode.commands.executeCommand(
      'vscode.provideDocumentSemanticTokensLegend',
      document.uri
    );
    const tokens = await vscode.commands.executeCommand(
      'vscode.provideDocumentSemanticTokens',
      document.uri
    );

    assert.deepStrictEqual(legend.tokenTypes, ['function']);
    assert.deepStrictEqual([...tokens.data], [0, 0, 4, 0, 0]);
  });

  await runCase('serves range semantic tokens from a MoonBit DocumentRangeSemanticTokensProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-range-semantic-tokens',
      content: 'moon'
    });
    const range = new vscode.Range(new vscode.Position(0, 0), new vscode.Position(0, 4));
    const legend = await vscode.commands.executeCommand(
      'vscode.provideDocumentRangeSemanticTokensLegend',
      document.uri,
      range
    );
    const tokens = await vscode.commands.executeCommand(
      'vscode.provideDocumentRangeSemanticTokens',
      document.uri,
      range
    );

    assert.deepStrictEqual(legend.tokenTypes, ['function']);
    assert.deepStrictEqual([...tokens.data], [0, 1, 3, 0, 0]);
  });

  await runCase('serves call hierarchy from a MoonBit CallHierarchyProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moonCall'
    });
    const items = await vscode.commands.executeCommand(
      'vscode.prepareCallHierarchy',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(items.length, 1);
    assert.strictEqual(items[0].name, 'moonCall');
    assert.strictEqual(items[0].kind, vscode.SymbolKind.Function);
    assert.strictEqual(items[0].detail, 'MoonBit call detail');
    assert.deepStrictEqual(rangeTuple(items[0].range), [0, 0, 0, 8]);
    assert.deepStrictEqual(rangeTuple(items[0].selectionRange), [0, 0, 0, 4]);

    const incoming = await vscode.commands.executeCommand(
      'vscode.provideIncomingCalls',
      items[0]
    );
    assert.strictEqual(incoming.length, 1);
    assert.strictEqual(incoming[0].from.name, 'incoming-moonCall');
    assert.deepStrictEqual(rangeTuple(incoming[0].fromRanges[0]), [0, 0, 0, 4]);

    const outgoing = await vscode.commands.executeCommand(
      'vscode.provideOutgoingCalls',
      items[0]
    );
    assert.strictEqual(outgoing.length, 1);
    assert.strictEqual(outgoing[0].to.name, 'outgoing-moonCall');
    assert.deepStrictEqual(rangeTuple(outgoing[0].fromRanges[0]), [0, 4, 0, 8]);
  });

  await runCase('serves type hierarchy from a MoonBit TypeHierarchyProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'MoonType'
    });
    const items = await vscode.commands.executeCommand(
      'vscode.prepareTypeHierarchy',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(items.length, 1);
    assert.strictEqual(items[0].name, 'MoonType');
    assert.strictEqual(items[0].kind, vscode.SymbolKind.Class);
    assert.strictEqual(items[0].detail, 'MoonBit type detail');
    assert.deepStrictEqual(rangeTuple(items[0].range), [0, 0, 0, 8]);
    assert.deepStrictEqual(rangeTuple(items[0].selectionRange), [0, 0, 0, 4]);

    const supertypes = await vscode.commands.executeCommand(
      'vscode.provideSupertypes',
      items[0]
    );
    assert.strictEqual(supertypes.length, 1);
    assert.strictEqual(supertypes[0].name, 'SuperMoonType');

    const subtypes = await vscode.commands.executeCommand(
      'vscode.provideSubtypes',
      items[0]
    );
    assert.strictEqual(subtypes.length, 1);
    assert.strictEqual(subtypes[0].name, 'SubMoonType');
  });

  await runCase('serves folding ranges from a MoonBit FoldingRangeProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'start\nmiddle\nend'
    });
    const ranges = await vscode.commands.executeCommand(
      'vscode.executeFoldingRangeProvider',
      document.uri
    );

    assert.strictEqual(ranges.length, 1);
    assert.strictEqual(ranges[0].start, 0);
    assert.strictEqual(ranges[0].end, 2);
    assert.strictEqual(ranges[0].kind, vscode.FoldingRangeKind.Region);
  });

  await runCase('serves selection ranges from a MoonBit SelectionRangeProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'selection'
    });
    const ranges = await vscode.commands.executeCommand(
      'vscode.executeSelectionRangeProvider',
      document.uri,
      [new vscode.Position(0, 2)]
    );

    assert.strictEqual(ranges.length, 1);
    assert.deepStrictEqual(rangeTuple(ranges[0].range), [0, 2, 0, 4]);
    assert.deepStrictEqual(rangeTuple(ranges[0].parent.range), [0, 0, 0, 9]);
  });

  await runCase('serves linked editing ranges from a MoonBit LinkedEditingRangeProvider', async () => {
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'moon x moon'
    });
    const result = await vscode.commands.executeCommand(
      '_executeLinkedEditingProvider',
      document.uri,
      new vscode.Position(0, 1)
    );

    assert.strictEqual(result.ranges.length, 2);
    assert.deepStrictEqual(monacoRangeTuple(result.ranges[0]), [0, 0, 0, 4]);
    assert.deepStrictEqual(monacoRangeTuple(result.ranges[1]), [0, 7, 0, 11]);
  });

  await runCase('resolves views from a MoonBit WebviewViewProvider', async () => {
    await vscode.commands.executeCommand('vscode-mbt-tests.webviewView', 'reset');
    await vscode.commands.executeCommand('vscode-mbt-smoke-webview.focus');

    const state = await waitForWebviewViewState(({ resolveCount }) => resolveCount === 1);
    assert.strictEqual(state.viewType, 'vscode-mbt-smoke-webview');
    assert.strictEqual(state.title, 'MoonBit Smoke Webview');
    assert.strictEqual(state.description, 'resolved');
    assert.ok(state.html.includes('MoonBit WebviewView'));
  });

  await runCase('serves decorations from a MoonBit FileDecorationProvider', async () => {
    const fixturePath = path.join(__dirname, '..', 'fixture', 'file-decoration.txt');
    try {
      fs.writeFileSync(fixturePath, 'decorated', 'utf8');
      const uri = vscode.Uri.file(fixturePath);
      await vscode.commands.executeCommand('vscode-mbt-tests.fileDecoration', 'reset', uri.toString());
      await vscode.commands.executeCommand('revealInExplorer', uri);

      const state = await waitForFileDecorationState(({ sawTarget }) => sawTarget);
      assert.strictEqual(state.badge, 'M');
      assert.strictEqual(state.tooltip, 'MoonBit decoration');
    } finally {
      fs.rmSync(fixturePath, { force: true });
    }
  });

  await runCase('serves paste edits from a MoonBit DocumentPasteEditProvider', async () => {
    await vscode.commands.executeCommand('vscode-mbt-tests.documentPaste', 'reset');
    await vscode.env.clipboard.writeText('clipboard-source');
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'before after'
    });
    const editor = await vscode.window.showTextDocument(document);
    editor.selection = new vscode.Selection(0, 7, 0, 7);

    await vscode.commands.executeCommand('editor.action.pasteAs', { kind: 'text.moonbit' });
    const text = await waitForDocumentText(
      document,
      value => value === 'before moonbit-pasted:clipboard-sourceafter'
    );
    assert.strictEqual(text, 'before moonbit-pasted:clipboard-sourceafter');

    const state = parseDocumentPasteState(
      await vscode.commands.executeCommand('vscode-mbt-tests.documentPaste', 'read')
    );
    assert.strictEqual(state.provideCount, 1);
    assert.strictEqual(state.rangeCount, 1);
    assert.strictEqual(state.clipboardText, 'clipboard-source');
    assert.strictEqual(state.triggerKind, 'pasteAs');
    assert.strictEqual(state.onlyKind, 'text.moonbit');
    assert.strictEqual(state.editTitle, 'MoonBit paste edit');
  });

  await runCase('serves ranges from a MoonBit CommentingRangeProvider', async () => {
    await vscode.commands.executeCommand('vscode-mbt-tests.commentingRange', 'reset');
    const document = await vscode.workspace.openTextDocument({
      language: 'vscode-mbt-smoke-language',
      content: 'commentable\nline'
    });
    await vscode.window.showTextDocument(document);
    await vscode.commands.executeCommand('editor.action.nextCommentingRange');

    const state = await waitForCommentingRangeState(({ lastUri }) => lastUri === document.uri.toString());
    assert.ok(state.provideCount >= 1, `provide count: ${state.provideCount}`);
    assert.strictEqual(state.rangeCount, 1);
    assert.strictEqual(state.enableFileComments, true);
  });

  await runCase('serves original resources from a MoonBit QuickDiffProvider', async () => {
    const fixturePath = path.join(__dirname, '..', 'fixture', 'quick-diff.txt');
    try {
      fs.writeFileSync(fixturePath, 'modified quick diff', 'utf8');
      const uri = vscode.Uri.file(fixturePath);
      await vscode.commands.executeCommand('vscode-mbt-tests.quickDiff', 'reset');
      const document = await vscode.workspace.openTextDocument(uri);
      await vscode.window.showTextDocument(document);
      await vscode.commands.executeCommand('editor.action.dirtydiff.next');

      const state = await waitForQuickDiffState(({ lastUri }) => lastUri === uri.toString());
      assert.ok(state.provideCount >= 1, `provide count: ${state.provideCount}`);
      assert.strictEqual(state.originalUri, 'vscode-mbt-smoke:/quick-diff-original');
    } finally {
      fs.rmSync(fixturePath, { force: true });
    }
  });

  await runCase('serves files from a MoonBit FileSystemProvider', async () => {
    const content = 'moonbit file system provider';
    const uriText = await vscode.commands.executeCommand('vscode-mbt-tests.fileSystemProviderUri');
    const uri = vscode.Uri.parse(uriText);

    const stat = await vscode.workspace.fs.stat(uri);
    assert.strictEqual(stat.type, vscode.FileType.File);
    assert.strictEqual(stat.size, Buffer.byteLength(content, 'utf8'));
    assert.strictEqual(stat.permissions, vscode.FilePermission.Readonly);

    const bytes = await vscode.workspace.fs.readFile(uri);
    assert.strictEqual(new TextDecoder().decode(bytes), content);

    const entries = await vscode.workspace.fs.readDirectory(vscode.Uri.parse('vscode-mbt-fs:/'));
    assert.deepStrictEqual(entries, [['hello.txt', vscode.FileType.File]]);

    const moonbitEntries = await vscode.commands.executeCommand(
      'vscode-mbt-tests.fileSystemReadDirectory'
    );
    assert.strictEqual(moonbitEntries, 'hello.txt|file');

    const watcher = vscode.workspace.createFileSystemWatcher(
      new vscode.RelativePattern(vscode.Uri.parse('vscode-mbt-fs:/'), '*')
    );
    watcher.dispose();
  });
}

module.exports = { run };
