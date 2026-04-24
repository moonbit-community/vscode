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
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
