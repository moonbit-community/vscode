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
