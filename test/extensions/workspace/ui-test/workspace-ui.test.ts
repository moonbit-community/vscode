import * as fs from 'fs/promises';
import * as path from 'path';
import { expect } from 'chai';
import {
  BottomBarPanel,
  EditorView,
  ModalDialog,
  OutputView,
  VSBrowser,
  Workbench,
} from 'vscode-extension-tester';

const fixtureRoot = path.resolve(__dirname, '..', '..', 'fixture');
const outputChannel = 'MoonBit Workspace';

const workspaceTextPath = path.join(fixtureRoot, 'moonbit-workspace-text.txt');
const createdPath = path.join(fixtureRoot, 'moonbit-workspace-created.txt');
const renamedPath = path.join(fixtureRoot, 'moonbit-workspace-renamed.txt');
const watchedPath = path.join(fixtureRoot, 'moonbit-workspace-watch-file.txt');
const fspDirPath = path.join(fixtureRoot, 'moonbit-workspace-fsp-dir');
const fspWritePath = path.join(fixtureRoot, 'moonbit-workspace-fsp-write.txt');
const fspRenamedPath = path.join(fixtureRoot, 'moonbit-workspace-fsp-renamed.txt');
const fspCopyPath = path.join(fixtureRoot, 'moonbit-workspace-fsp-copy.txt');
const notebookPath = path.join(fixtureRoot, 'moonbit-workspace-notebook.moonbitworkspace');
const settingsPath = path.join(fixtureRoot, '.vscode', 'settings.json');
const legacyResultPath = path.join(fixtureRoot, 'moonbit-workspace-check.txt');

async function ensureCommand(command: string, timeoutMs: number) {
  const deadline = Date.now() + timeoutMs;
  let lastError: unknown = undefined;
  while (Date.now() < deadline) {
    let executed = false;
    try {
      const workbench = new Workbench();
      await workbench.executeCommand(command);
      executed = true;
    } catch (error) {
      // Command palette not ready yet.
      lastError = error;
    }
    if (!executed) {
      await VSBrowser.instance.driver.sleep(500);
      continue;
    }
    await VSBrowser.instance.driver.sleep(500);
    await assertNoUnexpectedModal(`after command ${command}`, 1500);
    return;
  }
  if (lastError instanceof Error) {
    throw new Error(
      `Timed out waiting to execute command: ${command}. Last error: ${lastError.message}`,
    );
  }
  throw new Error(`Timed out waiting to execute command: ${command}`);
}

async function modalDetailsOrNone(timeoutMs: number) {
  try {
    const modal = new ModalDialog();
    await modal.wait(timeoutMs);
    const message = await modal.getMessage().catch(() => '');
    const details = await modal.getDetails().catch(() => '');
    const buttons = await modal.getButtons();
    const buttonLabels = await Promise.all(buttons.map((button) => button.getText()));
    if (buttonLabels.includes('OK')) {
      await modal.pushButton('OK');
    } else if (buttonLabels.includes("Don't Save")) {
      await modal.pushButton("Don't Save");
    } else if (buttonLabels.includes('Quit Anyway')) {
      await modal.pushButton('Quit Anyway');
    } else if (buttonLabels.includes('Cancel')) {
      await modal.pushButton('Cancel');
    } else {
      await modal.close().catch(() => undefined);
    }
    return {
      message,
      details,
      buttons: buttonLabels,
    };
  } catch {
    return undefined;
  }
}

async function assertNoUnexpectedModal(context: string, timeoutMs: number) {
  const modal = await modalDetailsOrNone(timeoutMs);
  if (!modal) {
    return;
  }
  const detailsText = modal.details.trim().length > 0 ? ` details=${modal.details}` : '';
  throw new Error(
    `Unexpected modal ${context}: message=${modal.message}${detailsText} buttons=${modal.buttons.join('|')}`,
  );
}

async function closeEditorsAndAssertNoModal(context: string) {
  try {
    const editorView = new EditorView();
    await editorView.closeAllEditors();
  } catch {
    // Ignore when there are no open editors.
  }
  await VSBrowser.instance.driver.sleep(300);
  await assertNoUnexpectedModal(`while closing editors (${context})`, 1500);
}

async function waitForCondition(
  label: string,
  predicate: () => Promise<boolean>,
  timeoutMs: number,
) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    try {
      if (await predicate()) {
        return;
      }
    } catch {
      // Keep waiting.
    }
    await VSBrowser.instance.driver.sleep(500);
  }
  throw new Error(`Timed out waiting for condition: ${label}`);
}

async function getOutputView() {
  const bottomBar = new BottomBarPanel();
  const output = await bottomBar.openOutputView();
  await output.selectChannel(outputChannel);
  await output.getDriver().sleep(500);
  return output;
}

async function waitForOutputMatch(
  output: OutputView,
  pattern: RegExp,
  timeoutMs: number,
) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    const contents = await output.getText();
    if (pattern.test(contents)) {
      return contents;
    }
    await VSBrowser.instance.driver.sleep(500);
  }
  throw new Error(`Timed out waiting for output match: ${pattern.source}`);
}

async function readUtf8(filePath: string) {
  return fs.readFile(filePath, 'utf8');
}

async function exists(filePath: string) {
  try {
    await fs.stat(filePath);
    return true;
  } catch {
    return false;
  }
}

async function readJson<T>(filePath: string): Promise<T> {
  const text = await readUtf8(filePath);
  return JSON.parse(text) as T;
}

describe('Workspace namespace bindings', function () {
  this.timeout(120000);

  afterEach(async () => {
    await closeEditorsAndAssertNoModal('after test');
  });

  after(async () => {
    await assertNoUnexpectedModal('before suite shutdown', 2000);
  });

  it('checks core workspace behavior', async () => {
    await ensureCommand('moonbit.workspace.checkCore', 15000);
    const output = await getOutputView();
    const contents = await waitForOutputMatch(
      output,
      /workspace\.core core-\d+ done/,
      20000,
    );

    const runMatch = contents.match(/workspace\.core (core-\d+) start/);
    if (!runMatch) {
      throw new Error(contents);
    }
    const runTag = runMatch[1];

    expect(contents).to.include(`workspace.core ${runTag} value workspace`);
    expect(contents).to.include(`workspace.core ${runTag} value config`);
    expect(contents).to.include(`workspace.core ${runTag} value apply_edit=true`);
    expect(contents).to.include(`workspace.core ${runTag} value save`);
    expect(contents).to.include(`workspace.core ${runTag} value docs`);
    expect(contents).to.include('untitled=');
    expect(contents).to.include('untitled_closed=true');
    expect(contents).to.include(`workspace.core ${runTag} value find`);
    expect(contents).to.include(`workspace.core ${runTag} value decode plain=moonbit-utf8`);
    expect(contents).to.include(`workspace.core ${runTag} value final_text=beta`);
    expect(contents).to.include(`workspace.core ${runTag} event text_change`);
    expect(contents).to.not.include('workspace.core error');

    await waitForCondition(
      'workspace text file updated to beta',
      async () => (await readUtf8(workspaceTextPath)) === 'beta',
      20000,
    );
    expect(await readUtf8(workspaceTextPath)).to.equal('beta');

    const settings = await readJson<Record<string, string>>(settingsPath);
    expect(settings['moonbit.workspace.value']).to.equal('after');
    expect(await exists(legacyResultPath)).to.equal(false);
  });

  it('checks file event and watcher behavior', async () => {
    await ensureCommand('moonbit.workspace.checkFileEvents', 15000);
    const output = await getOutputView();
    const contents = await waitForOutputMatch(
      output,
      /workspace\.files files-\d+ done/,
      20000,
    );

    const runMatch = contents.match(/workspace\.files (files-\d+) start/);
    if (!runMatch) {
      throw new Error(contents);
    }
    const runTag = runMatch[1];

    expect(contents).to.include(`workspace.files ${runTag} event file_will_create`);
    expect(contents).to.include(`workspace.files ${runTag} event file_did_create`);
    expect(contents).to.include(`workspace.files ${runTag} event file_will_rename`);
    expect(contents).to.include(`workspace.files ${runTag} event file_did_rename`);
    expect(contents).to.include(`workspace.files ${runTag} event file_will_delete`);
    expect(contents).to.include(`workspace.files ${runTag} event file_did_delete`);
    expect(contents).to.include(`workspace.files ${runTag} value file_edits`);
    expect(contents).to.include('created_exists=false');
    expect(contents).to.include('renamed_exists=false');
    expect(contents).to.include('watch_exists=false');
    expect(contents).to.not.include('workspace.files error');

    expect(await exists(createdPath)).to.equal(false);
    expect(await exists(renamedPath)).to.equal(false);
    expect(await exists(watchedPath)).to.equal(false);
  });

  it('checks provider callback behavior', async () => {
    await ensureCommand('moonbit.workspace.checkProviders', 15000);
    const output = await getOutputView();
    const contents = await waitForOutputMatch(
      output,
      /workspace\.providers providers-\d+ done/,
      20000,
    );

    const runMatch = contents.match(/workspace\.providers (providers-\d+) start/);
    if (!runMatch) {
      throw new Error(contents);
    }
    const runTag = runMatch[1];

    expect(contents).to.include(`workspace.providers ${runTag} callback content_provider`);
    expect(contents).to.include(`workspace.providers ${runTag} callback task_provider.provide`);
    expect(contents).to.include(`workspace.providers ${runTag} callback task_provider.resolve`);
    expect(contents).to.include(`workspace.providers ${runTag} callback fs_provider.stat`);
    expect(contents).to.include(`workspace.providers ${runTag} callback fs_provider.read_directory`);
    expect(contents).to.include(`workspace.providers ${runTag} callback fs_provider.create_directory`);
    expect(contents).to.include(`workspace.providers ${runTag} callback fs_provider.read_file`);
    expect(contents).to.include(`workspace.providers ${runTag} callback fs_provider.write_file`);
    expect(contents).to.include(`workspace.providers ${runTag} callback fs_provider.rename`);
    expect(contents).to.include(`workspace.providers ${runTag} callback fs_provider.copy`);
    expect(contents).to.include(`workspace.providers ${runTag} callback fs_provider.delete`);
    expect(contents).to.include(`workspace.providers ${runTag} event fs_provider_did_change_file`);
    expect(contents).to.include(`workspace.providers ${runTag} value content_doc=moonbit-content-provider:/workspace/check`);
    expect(contents).to.include(`workspace.providers ${runTag} value tasks`);
    expect(contents).to.include(`workspace.providers ${runTag} value fs_provider`);
    expect(contents).to.not.include('workspace.providers error');

    await waitForCondition(
      'fs provider renamed file written',
      async () => (await readUtf8(fspRenamedPath)) === 'beta',
      20000,
    );
    expect(await readUtf8(fspRenamedPath)).to.equal('beta');
    expect(await exists(fspDirPath)).to.equal(true);
    expect(await exists(fspWritePath)).to.equal(false);
    expect(await exists(fspCopyPath)).to.equal(false);
  });

  it('checks notebook behavior', async () => {
    await ensureCommand('moonbit.workspace.checkNotebook', 15000);
    const output = await getOutputView();
    const contents = await waitForOutputMatch(
      output,
      /workspace\.notebook notebook-\d+ done/,
      20000,
    );

    const runMatch = contents.match(/workspace\.notebook (notebook-\d+) start/);
    if (!runMatch) {
      throw new Error(contents);
    }
    const runTag = runMatch[1];

    expect(contents).to.include(`workspace.notebook ${runTag} callback notebook.deserialize`);
    expect(contents).to.include(`workspace.notebook ${runTag} event notebook_open`);
    expect(contents).to.include(`workspace.notebook ${runTag} value notebook`);
    expect(contents).to.include('type_type=moonbit-workspace-notebook');
    expect(contents).to.include('type_untitled=true');
    expect(contents).to.include('untitled=false');
    expect(contents).to.include('dirty=false');
    expect(contents).to.include('save=true');
    expect(contents).to.include('closed=true');
    expect(contents).to.not.include('workspace.notebook error');

    expect(await readUtf8(notebookPath)).to.equal('workspace notebook');
  });
});
