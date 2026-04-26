const assert = require('assert');
const { spawnSync } = require('child_process');
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
const diffDir = path.join(testRoot, 'diffs');
const baselinePlatform = `${process.platform}-${process.arch}`;
const baselineDir = path.join(__dirname, 'baselines', baselinePlatform);
const fixtureDecorationFile = path.join(workspacePath, 'file-decoration-visual.txt');
const fixtureDropFile = path.join(workspacePath, 'document-drop-visual.mbt');
const updateBaselines = process.argv.includes('--update-baselines');
const screenshotNames = [
  'status-bar.png',
  'tree-view.png',
  'webview-view.png',
  'file-decoration.png',
  'document-drop.png',
  'terminal-link.png',
  'terminal-profile.png'
];
const maxDiffPixels = Number.parseInt(process.env.VSCODE_MBT_UI_MAX_DIFF_PIXELS || '1000', 10);

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
    await stabilizeWorkbench(window);
    await setPrimarySidebarWidth(window, 320);

    await captureStatusBar(window);
    await captureTreeView(window);
    await captureWebviewView(window);
    await captureFileDecoration(window);
    await captureDocumentDrop(window);
    await captureTerminalLink(window);
    await captureTerminalProfile(window);
  } catch (error) {
    await captureFailureScreenshot(electronApp);
    throw error;
  } finally {
    await electronApp.close();
  }

  if (updateBaselines) {
    updateBaselineScreenshots();
  } else {
    compareScreenshots();
  }

  console.log(`Smoke UI screenshots written to ${screenshotDir}`);
  if (!updateBaselines) {
    console.log(`Smoke UI diffs written to ${diffDir}`);
  }
}

function resetTestWorkspace() {
  fs.rmSync(testRoot, { recursive: true, force: true });
  fs.mkdirSync(testHome, { recursive: true });
  fs.mkdirSync(extensionsDir, { recursive: true });
  fs.mkdirSync(workspacePath, { recursive: true });
  fs.mkdirSync(screenshotDir, { recursive: true });
  fs.mkdirSync(diffDir, { recursive: true });
  writeUserSettings();
  fs.writeFileSync(fixtureDecorationFile, 'moonbit file decoration visual smoke\n');
  fs.writeFileSync(fixtureDropFile, 'drop-target\n');
}

function writeUserSettings() {
  const userDir = path.join(userDataDir, 'User');
  fs.mkdirSync(userDir, { recursive: true });
  fs.writeFileSync(
    path.join(userDir, 'settings.json'),
    JSON.stringify(
      {
        'breadcrumbs.enabled': false,
        'editor.codeLens': false,
        'editor.cursorBlinking': 'solid',
        'editor.minimap.enabled': false,
        'editor.occurrencesHighlight': 'off',
        'editor.renderLineHighlight': 'none',
        'editor.scrollbar.horizontal': 'hidden',
        'editor.scrollbar.vertical': 'hidden',
        'editor.selectionHighlight': false,
        'git.decorations.enabled': false,
        'terminal.integrated.cursorBlinking': false,
        'terminal.integrated.gpuAcceleration': 'off',
        'telemetry.telemetryLevel': 'off',
        'update.mode': 'none',
        'workbench.startupEditor': 'none'
      },
      undefined,
      2
    )
  );
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

async function captureDocumentDrop(window) {
  const droppedText = 'playwright-drop';
  await runCommand(window, 'MoonBit Smoke: Document Drop Visual');
  await waitForVisibleText(window, 'drop-target');
  await dispatchEditorDrop(window, droppedText);
  await waitForVisibleText(window, `moonbit-dropped:${droppedText}`);
  await window.mouse.move(20, 20);
  await window.waitForTimeout(150);
  await screenshot(window, 'document-drop.png');
}

async function captureTerminalLink(window) {
  await runCommand(window, 'MoonBit Smoke: Terminal Link Visual');
  const linkText = 'moonbit-terminal-link';
  await waitForVisibleText(window, linkText);
  await setBottomPanelHeight(window, 220);
  const link = window.locator(`text=${linkText}`).first();
  const box = await link.boundingBox();
  assert.ok(box, 'terminal link text was visible but had no bounding box');
  const x = box.x + box.width / 2;
  const y = box.y + box.height / 2;
  const linkModifier = os.platform() === 'darwin' ? 'Meta' : 'Control';
  await clickTerminalLink(window, x, y, linkModifier);
  await window.mouse.move(20, 20);
  await window.waitForTimeout(250);
  await screenshot(window, 'terminal-link.png');
  await closeActiveTerminal(window);
}

async function captureTerminalProfile(window) {
  await runCommand(window, 'MoonBit Smoke: Terminal Profile Visual');
  await waitForVisibleText(window, 'moonbit-profile-terminal');
  await setBottomPanelHeight(window, 220);
  await screenshot(window, 'terminal-profile.png');
}

async function dispatchEditorDrop(window, text) {
  const editor = window.locator('.monaco-editor').first();
  await editor.waitFor({ state: 'visible', timeout: 15000 });
  const box = await editor.boundingBox();
  assert.ok(box, 'editor was visible but had no bounding box');
  const x = box.x + Math.min(160, box.width / 2);
  const y = box.y + Math.min(120, box.height / 2);
  const dataTransfer = await window.evaluateHandle(value => {
    const transfer = new DataTransfer();
    transfer.setData('text/plain', value);
    return transfer;
  }, text);
  try {
    await window.mouse.move(x, y);
    for (const type of ['dragenter', 'dragover', 'drop']) {
      await editor.dispatchEvent(type, {
        bubbles: true,
        cancelable: true,
        clientX: x,
        clientY: y,
        dataTransfer
      });
    }
  } finally {
    await dataTransfer.dispose();
  }
}

async function clickTerminalLink(window, x, y, modifier) {
  let lastError;
  for (let attempt = 0; attempt < 3; attempt += 1) {
    await window.keyboard.down(modifier);
    try {
      await window.mouse.move(x, y, { steps: 8 });
      await waitForVisibleText(window, 'MoonBit terminal link', 1000).catch(() => {});
      await window.mouse.click(x, y);
    } finally {
      await window.keyboard.up(modifier);
    }

    try {
      await waitForVisibleText(window, 'MoonBit terminal link handled', 5000);
      return;
    } catch (error) {
      lastError = error;
      await window.waitForTimeout(250);
    }
  }
  throw lastError;
}

async function closeActiveTerminal(window) {
  await runCommand(window, 'Terminal: Kill the Active Terminal Instance');
  await window.waitForTimeout(250);
}

async function runCommand(window, title) {
  let lastError;
  for (let attempt = 0; attempt < 6; attempt += 1) {
    await window.keyboard.press(os.platform() === 'darwin' ? 'Meta+Shift+P' : 'Control+Shift+P');
    const input = window.locator('.quick-input-widget input').first();
    await input.waitFor({ state: 'visible', timeout: 10000 });
    await input.fill(`>${title}`);
    try {
      await selectQuickPick(window, title, 3000);
      return;
    } catch (error) {
      lastError = error;
      await window.keyboard.press('Escape');
      await window.locator('.quick-input-widget').waitFor({ state: 'hidden', timeout: 10000 })
        .catch(() => {});
      await window.waitForTimeout(500);
    }
  }
  throw lastError;
}

async function selectQuickPick(window, title, timeout = 10000) {
  const command = window.locator('.quick-input-widget .monaco-list-row', { hasText: title }).first();
  await command.waitFor({ state: 'visible', timeout });
  await command.click();
  await window.locator('.quick-input-widget').waitFor({ state: 'hidden', timeout: 10000 })
    .catch(() => {});
}

async function waitForVisibleText(window, text, timeout = 15000) {
  await window.locator(`text=${text}`).first().waitFor({ state: 'visible', timeout });
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
    clip: {
      x: 0,
      y: 0,
      width: 1100,
      height: 900
    }
  });
}

async function stabilizeWorkbench(window) {
  await window.addStyleTag({
    content: `
      .part.auxiliarybar,
      .editor-group-watermark,
      .part.activitybar .badge,
      .part.statusbar .right-items,
      .notifications-toasts,
      .monaco-hover,
      .monaco-editor .cursors-layer,
      .xterm-cursor-layer {
        visibility: hidden !important;
      }
    `
  });
}

async function setPrimarySidebarWidth(window, width) {
  const sidebar = window.locator('.part.sidebar').first();
  await sidebar.waitFor({ state: 'visible', timeout: 10000 });
  for (let attempt = 0; attempt < 3; attempt += 1) {
    const box = await sidebar.boundingBox();
    assert.ok(box, 'primary sidebar was visible but had no bounding box');
    if (Math.abs(box.width - width) <= 2) {
      break;
    }
    const y = box.y + Math.min(120, box.height / 2);
    await window.mouse.move(box.x + box.width - 1, y);
    await window.mouse.down();
    await window.mouse.move(box.x + width, y, { steps: 12 });
    await window.mouse.up();
    await window.waitForTimeout(250);
  }
  await window.mouse.move(20, 20);
  await window.waitForTimeout(250);
}

async function setBottomPanelHeight(window, height) {
  const panel = window.locator('.part.panel').first();
  await panel.waitFor({ state: 'visible', timeout: 10000 });
  for (let attempt = 0; attempt < 3; attempt += 1) {
    const box = await panel.boundingBox();
    assert.ok(box, 'bottom panel was visible but had no bounding box');
    if (Math.abs(box.height - height) <= 2) {
      break;
    }
    const x = box.x + Math.min(500, box.width / 2);
    const targetY = box.y + box.height - height;
    await window.mouse.move(x, box.y + 1);
    await window.mouse.down();
    await window.mouse.move(x, targetY, { steps: 12 });
    await window.mouse.up();
    await window.waitForTimeout(250);
  }
  await window.mouse.move(20, 20);
  await window.waitForTimeout(250);
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

function updateBaselineScreenshots() {
  fs.mkdirSync(baselineDir, { recursive: true });
  for (const name of screenshotNames) {
    fs.copyFileSync(path.join(screenshotDir, name), path.join(baselineDir, name));
  }
  console.log(`Updated Smoke UI baselines in ${baselineDir}`);
}

function compareScreenshots() {
  assertBaselinesExist();
  const compareCommand = resolveImageCompareCommand();
  const failures = [];

  for (const name of screenshotNames) {
    const baseline = path.join(baselineDir, name);
    const actual = path.join(screenshotDir, name);
    const diff = path.join(diffDir, name);
    const result = comparePng(compareCommand, baseline, actual, diff);
    if (result.diffPixels > maxDiffPixels) {
      failures.push(`${name}: ${result.diffPixels} pixels differ`);
    } else if (fs.existsSync(diff)) {
      fs.rmSync(diff, { force: true });
    }
  }

  if (failures.length > 0) {
    throw new Error(
      [
        'Smoke UI screenshot regression detected.',
        ...failures,
        `Review diffs in ${diffDir}`,
        'Run npm run test:ui:update to accept intentional UI changes.'
      ].join('\n')
    );
  }
}

function assertBaselinesExist() {
  const missing = screenshotNames.filter(name => !fs.existsSync(path.join(baselineDir, name)));
  if (missing.length > 0) {
    throw new Error(
      [
        `Missing Smoke UI baselines for ${baselinePlatform}:`,
        ...missing.map(name => `- ${path.join(baselineDir, name)}`),
        'Run npm run test:ui:update to create them.'
      ].join('\n')
    );
  }
}

function resolveImageCompareCommand() {
  if (commandWorks('magick', ['-version'])) {
    return { command: 'magick', argsPrefix: ['compare'] };
  }
  if (commandWorks('compare', ['-version'])) {
    return { command: 'compare', argsPrefix: [] };
  }
  throw new Error('Smoke UI screenshot comparison requires ImageMagick: install `magick` or `compare`.');
}

function commandWorks(command, args) {
  const result = spawnSync(command, args, { encoding: 'utf8' });
  return result.status === 0;
}

function comparePng(compareCommand, baseline, actual, diff) {
  const args = [
    ...compareCommand.argsPrefix,
    '-metric',
    'AE',
    '-fuzz',
    '1%',
    baseline,
    actual,
    diff
  ];
  const result = spawnSync(compareCommand.command, args, { encoding: 'utf8' });
  if (result.status !== 0 && result.status !== 1) {
    throw new Error(
      `ImageMagick compare failed for ${path.basename(actual)}:\n${result.stderr || result.stdout}`
    );
  }
  return { diffPixels: parseDiffPixels(result.stderr || result.stdout) };
}

function parseDiffPixels(output) {
  const text = String(output);
  const parenthesized = text.match(/\((\d+)\)/);
  if (parenthesized) {
    return Number.parseInt(parenthesized[1], 10);
  }

  const match = text.match(/\d+/);
  return match ? Number.parseInt(match[0], 10) : 0;
}
