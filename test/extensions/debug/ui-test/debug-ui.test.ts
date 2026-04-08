import * as fs from 'fs/promises';
import * as path from 'path';
import {
  EditorView,
  ModalDialog,
  VSBrowser,
  Workbench,
} from 'vscode-extension-tester';

const fixtureRoot = path.resolve(__dirname, '..', '..', 'fixture');
const resultPath = path.join(fixtureRoot, 'debug-result.txt');

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

async function waitForFileContains(filePath: string, text: string, timeoutMs: number) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    try {
      const contents = await fs.readFile(filePath, 'utf8');
      if (contents.includes(text)) {
        return contents;
      }
    } catch {
      // File not ready yet.
    }
    await VSBrowser.instance.driver.sleep(500);
  }
  throw new Error(`Timed out waiting for file ${filePath} to contain: ${text}`);
}

async function removeFile(filePath: string) {
  try {
    await fs.rm(filePath, { force: true });
  } catch {
    // Ignore cleanup failures.
  }
}

describe('Debug namespace bindings', function () {
  this.timeout(40000);

  afterEach(async () => {
    await closeEditorsAndAssertNoModal('after test');
  });

  after(async () => {
    await assertNoUnexpectedModal('before suite shutdown', 2000);
  });

  it('checks debug namespace', async () => {
    await removeFile(resultPath);
    await ensureCommand('moonbit.debug.checkBindings', 10000);
    const contents = await waitForFileContains(resultPath, 'debug ok', 10000);

    if (!contents.includes('after_source_add=')) {
      throw new Error(contents);
    }
    if (!contents.includes('after_add_base=')) {
      throw new Error(contents);
    }
    if (!contents.includes('after_function_add=')) {
      throw new Error(contents);
    }
    if (!contents.includes('start_name=')) {
      throw new Error(contents);
    }
    if (!contents.includes('start_configuration=')) {
      throw new Error(contents);
    }
    if (!contents.includes('stop=')) {
      throw new Error(contents);
    }
    if (!contents.includes('source_scheme=')) {
      throw new Error(contents);
    }
    if (!contents.includes('executable=node')) {
      throw new Error(contents);
    }
    if (!contents.includes('server=4711')) {
      throw new Error(contents);
    }
    if (!contents.includes('pipe=moonbit-debug-pipe')) {
      throw new Error(contents);
    }
  });
});
