const path = require('path');
const fs = require('fs');
const os = require('os');
const vscodeVersion = require('../../../package.json').config.vscodeTestVersion;
const { runTests, downloadAndUnzipVSCode } = require('@vscode/test-electron');

async function main() {
  const extensionDevelopmentPath = __dirname;
  const extensionTestsPath = path.join(__dirname, 'suite', 'index.js');
  const workspacePath = path.join(__dirname, 'fixture');
  const testHome = path.join(__dirname, '..', '..', '..', '.vscode-test', 'home');
  const userDataDir = fs.mkdtempSync(path.join(os.tmpdir(), 'vscode-mbt-integration-'));
  const disposeMarker = path.join(__dirname, '..', '..', '..', '.vscode-test', 'smoke-dispose-marker.txt');
  fs.mkdirSync(testHome, { recursive: true });
  fs.rmSync(disposeMarker, { force: true });

  let vscodeExecutablePath = await downloadAndUnzipVSCode(vscodeVersion);
  if (process.platform === 'darwin' && !fs.existsSync(vscodeExecutablePath)) {
    const codePath = path.join(path.dirname(vscodeExecutablePath), 'Code');
    if (fs.existsSync(codePath)) vscodeExecutablePath = codePath;
  }

  await runTests({
    vscodeExecutablePath,
    extensionDevelopmentPath,
    extensionTestsPath,
    extensionTestsEnv: {
      HOME: testHome,
      VSCODE_MBT_SMOKE_DISPOSE_MARKER: disposeMarker
    },
    launchArgs: [
      workspacePath,
      `--user-data-dir=${userDataDir}`,
      '--disable-extensions',
      '--sync',
      'off',
      // Keep VS Code auth storage out of the OS keychain during tests.
      '--use-inmemory-secretstorage'
    ]
  });
  assertNoDisposeError(userDataDir);
  assertDisposablesWereDisposed(disposeMarker);
  fs.rmSync(userDataDir, { recursive: true, force: true });
}

function assertDisposablesWereDisposed(disposeMarker) {
  if (!fs.existsSync(disposeMarker)) {
    throw new Error(`MoonBit disposable marker was not written: ${disposeMarker}`);
  }
  const entries = fs.readFileSync(disposeMarker, 'utf8').split(/\r?\n/);
  const expectedEntries = [
    'as-disposable',
    'callback-disposable',
    'combined-callback-disposable',
    'combined-as-disposable',
    'fs-watch',
    'fs-watch-disposable'
  ];
  const missingEntries = expectedEntries.filter(entry => !entries.includes(entry));
  if (missingEntries.length > 0) {
    throw new Error(
      `MoonBit disposable marker was missing entries: ${missingEntries.join(', ')}\n${disposeMarker}`
    );
  }
}

function assertNoDisposeError(userDataDir) {
  const logsRoot = path.join(userDataDir, 'logs');
  const latestLog = latestDirectory(logsRoot);
  if (!latestLog) {
    return;
  }
  const matches = readFiles(latestLog).filter(file => {
    const text = fs.readFileSync(file, 'utf8');
    return text.includes(
      "An error occurred when disposing the subscriptions for extension 'vscode-mbt-tests.vscode-mbt-smoke-extension'"
    );
  });
  if (matches.length > 0) {
    throw new Error(`VS Code extension host reported smoke extension dispose errors:\n${matches.join('\n')}`);
  }
}

function latestDirectory(parent) {
  if (!fs.existsSync(parent)) {
    return undefined;
  }
  return fs.readdirSync(parent, { withFileTypes: true })
    .filter(entry => entry.isDirectory())
    .map(entry => path.join(parent, entry.name))
    .sort((left, right) => fs.statSync(right).mtimeMs - fs.statSync(left).mtimeMs)[0];
}

function readFiles(root) {
  const files = [];
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const current = path.join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...readFiles(current));
    } else if (entry.isFile() && current.endsWith('.log')) {
      files.push(current);
    }
  }
  return files;
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
