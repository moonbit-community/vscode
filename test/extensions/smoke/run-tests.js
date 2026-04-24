const path = require('path');
const fs = require('fs');
const { runTests } = require('@vscode/test-electron');

async function main() {
  const extensionDevelopmentPath = __dirname;
  const extensionTestsPath = path.join(__dirname, 'suite', 'index.js');
  const workspacePath = path.join(__dirname, 'fixture');
  const testHome = path.join(__dirname, '..', '..', '..', '.vscode-test', 'home');
  fs.mkdirSync(testHome, { recursive: true });

  await runTests({
    extensionDevelopmentPath,
    extensionTestsPath,
    extensionTestsEnv: {
      HOME: testHome
    },
    launchArgs: [
      workspacePath,
      '--disable-extensions',
      '--sync',
      'off',
      // Keep VS Code auth storage out of the OS keychain during tests.
      '--use-inmemory-secretstorage'
    ]
  });
  assertNoDisposeError();
}

function assertNoDisposeError() {
  const logsRoot = path.join(__dirname, '..', '..', '..', '.vscode-test', 'user-data', 'logs');
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
