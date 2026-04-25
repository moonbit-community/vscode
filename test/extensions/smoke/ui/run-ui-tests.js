const assert = require('assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { downloadAndUnzipVSCode } = require('@vscode/test-electron');

const repoRoot = path.resolve(__dirname, '..', '..', '..', '..');
const smokeRoot = path.resolve(__dirname, '..');
const workspacePath = path.join(smokeRoot, 'fixture');
const testRoot = path.join(repoRoot, '.vscode-test', 'smoke-ui');
const userDataDir = path.join(testRoot, 'user-data');
const extensionsDir = path.join(testRoot, 'extensions');
const testHome = path.join(testRoot, 'home');
const screenshotDir = path.join(testRoot, 'screenshots');
const fixtureDecorationFile = path.join(workspacePath, 'file-decoration-visual.txt');

async function main() {
  resetTestWorkspace();

  const vscodeExecutablePath = await resolveVSCodeExecutablePath();
  const { _electron } = loadPlaywrightCore(vscodeExecutablePath);
  assert.ok(_electron, 'playwright-core did not expose the Electron launcher');

  const electronApp = await _electron.launch({
    executablePath: vscodeExecutablePath,
    args: [
      workspacePath,
      `--extensionDevelopmentPath=${smokeRoot}`,
      `--user-data-dir=${userDataDir}`,
      `--extensions-dir=${extensionsDir}`,
      '--disable-gpu',
      '--headless',
      '--disable-extension',
      'vscode.git',
      '--disable-updates',
      '--disable-workspace-trust',
      '--skip-release-notes',
      '--skip-welcome',
      '--sync',
      'off',
      '--use-inmemory-secretstorage'
    ],
    env: {
      ...process.env,
      HOME: testHome,
      VSCODE_MBT_SMOKE_UI: '1'
    }
  });

  try {
    const window = await electronApp.firstWindow();
    await window.waitForLoadState('domcontentloaded');
    await window.locator('.monaco-workbench').waitFor({ timeout: 30000 });
    await window.setViewportSize({ width: 1400, height: 900 });

    await captureStatusBar(window);
    await captureTreeView(window);
    await captureWebviewView(window);
    await captureFileDecoration(window);
  } catch (error) {
    await captureFailureScreenshot(electronApp);
    throw error;
  } finally {
    await electronApp.close();
  }

  console.log(`Smoke UI screenshots written to ${screenshotDir}`);
}

function resetTestWorkspace() {
  fs.rmSync(testRoot, { recursive: true, force: true });
  fs.mkdirSync(testHome, { recursive: true });
  fs.mkdirSync(extensionsDir, { recursive: true });
  fs.mkdirSync(workspacePath, { recursive: true });
  fs.mkdirSync(screenshotDir, { recursive: true });
  fs.writeFileSync(fixtureDecorationFile, 'moonbit file decoration visual smoke\n');
}

async function resolveVSCodeExecutablePath() {
  if (process.env.VSCODE_EXECUTABLE_PATH) {
    return process.env.VSCODE_EXECUTABLE_PATH;
  }

  const cached = findCachedVSCodeExecutablePath();
  if (cached) {
    return cached;
  }

  return downloadAndUnzipVSCode();
}

function findCachedVSCodeExecutablePath() {
  const cacheRoot = path.join(repoRoot, '.vscode-test');
  if (!fs.existsSync(cacheRoot)) {
    return undefined;
  }

  for (const entry of fs.readdirSync(cacheRoot)) {
    const root = path.join(cacheRoot, entry);
    const executablePath = executablePathForVSCodeRoot(root);
    if (executablePath && fs.existsSync(executablePath)) {
      return executablePath;
    }
  }

  return undefined;
}

function executablePathForVSCodeRoot(root) {
  if (process.platform === 'darwin') {
    return path.join(root, 'Visual Studio Code.app', 'Contents', 'MacOS', 'Electron');
  }
  if (process.platform === 'win32') {
    return path.join(root, 'Code.exe');
  }
  return path.join(root, 'code');
}

function loadPlaywrightCore(vscodeExecutablePath) {
  try {
    return require('playwright-core');
  } catch (_) {
    const bundled = bundledPlaywrightCorePath(vscodeExecutablePath);
    if (!bundled || !fs.existsSync(bundled)) {
      throw new Error(
        'playwright-core is not installed and the downloaded VS Code build does not include it'
      );
    }
    return require(bundled);
  }
}

function bundledPlaywrightCorePath(vscodeExecutablePath) {
  if (process.platform === 'darwin') {
    return path.resolve(
      path.dirname(vscodeExecutablePath),
      '..',
      'Resources',
      'app',
      'node_modules',
      'playwright-core'
    );
  }
  return path.resolve(
    path.dirname(vscodeExecutablePath),
    'resources',
    'app',
    'node_modules',
    'playwright-core'
  );
}

async function captureStatusBar(window) {
  await runCommand(window, 'MoonBit Smoke: Status Bar');
  await waitForVisibleText(window, 'MoonBit binding smoke');
  await screenshot(window, 'status-bar.png');
}

async function captureTreeView(window) {
  await runCommand(window, 'MoonBit Smoke: Tree View Visual');
  await waitForVisibleText(window, 'MoonBit Smoke Tree');
  await waitForVisibleText(window, 'child');
  await screenshot(window, 'tree-view.png');
}

async function captureWebviewView(window) {
  await runCommand(window, 'MoonBit Smoke: Webview View Visual');
  await waitForVisibleText(window, 'MoonBit Smoke Webview');
  await waitForFrameText(window, 'MoonBit WebviewView');
  await screenshot(window, 'webview-view.png');
}

async function captureFileDecoration(window) {
  await runCommand(window, 'MoonBit Smoke: File Decoration Visual');
  const row = window.locator('.monaco-list-row', { hasText: 'file-decoration-visual.txt' }).first();
  await row.waitFor({ state: 'visible', timeout: 15000 });
  await window
    .locator('[aria-label*="MoonBit decoration"], [title*="MoonBit decoration"]')
    .first()
    .waitFor({ state: 'visible', timeout: 15000 });
  await screenshot(window, 'file-decoration.png');
}

async function runCommand(window, title) {
  await window.keyboard.press(os.platform() === 'darwin' ? 'Meta+Shift+P' : 'Control+Shift+P');
  const input = window.locator('.quick-input-widget input').first();
  await input.waitFor({ state: 'visible', timeout: 10000 });
  await input.fill(`>${title}`);
  const command = window.locator('.quick-input-widget .monaco-list-row', { hasText: title }).first();
  await command.waitFor({ state: 'visible', timeout: 10000 });
  await command.click();
  await window.locator('.quick-input-widget').waitFor({ state: 'hidden', timeout: 10000 })
    .catch(() => {});
}

async function waitForVisibleText(window, text) {
  await window.locator(`text=${text}`).first().waitFor({ state: 'visible', timeout: 15000 });
}

async function waitForFrameText(window, text) {
  const started = Date.now();
  while (Date.now() - started < 15000) {
    for (const frame of window.frames()) {
      try {
        const body = await frame.locator('body').innerText({ timeout: 250 });
        if (body.includes(text)) {
          return;
        }
      } catch (_) {
        // Some VS Code frames are not ready while webviews are settling.
      }
    }
    await window.waitForTimeout(250);
  }
  throw new Error(`Timed out waiting for frame text: ${text}`);
}

async function screenshot(window, name) {
  await window.screenshot({
    path: path.join(screenshotDir, name),
    fullPage: true
  });
}

async function captureFailureScreenshot(electronApp) {
  try {
    const windows = electronApp.windows();
    const window = windows[0];
    if (window) {
      await window.screenshot({
        path: path.join(screenshotDir, 'failure.png'),
        fullPage: true
      });
    }
  } catch (_) {
    // Keep the original failure as the reported error.
  }
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
