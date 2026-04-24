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
