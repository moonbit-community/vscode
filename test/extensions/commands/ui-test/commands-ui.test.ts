import { expect } from 'chai';
import {
  EditorView,
  ModalDialog,
  StatusBar,
  TextEditor,
  VSBrowser,
  Workbench,
} from 'vscode-extension-tester';

async function waitForStatusItem(
  statusBar: StatusBar,
  label: string,
  timeoutMs: number,
) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    const item = await statusBar.getItem(label);
    if (item !== undefined) {
      return item;
    }
    await VSBrowser.instance.driver.sleep(500);
  }
  throw new Error(`Timed out waiting for status bar item: ${label}`);
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
  const deadline = Date.now() + 5000;
  while (Date.now() < deadline) {
    try {
      const workbench = new Workbench();
      await workbench.executeCommand('workbench.action.revertAndCloseActiveEditor');
      await VSBrowser.instance.driver.sleep(200);
      continue;
    } catch {
      break;
    }
  }
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

describe('Commands UI bindings', function () {
  this.timeout(40000);

  afterEach(async () => {
    await closeEditorsAndAssertNoModal('after test');
  });

  after(async () => {
    await assertNoUnexpectedModal('before suite shutdown', 2000);
  });

  it('opens editor', async () => {
    await ensureCommand('moonbit.commands.openEditor', 10000);

    const editor = new TextEditor();
    const contents = await editor.getText();
    expect(contents).to.include('MoonBit command editor ok');
  });

  it('executeCommand triggers openEditor', async () => {
    await ensureCommand('moonbit.commands.runNestedOpenEditor', 10000);

    const editor = new TextEditor();
    const contents = await editor.getText();
    expect(contents).to.include('MoonBit command editor ok');
  });

  it('inserts text via text editor command', async () => {
    await ensureCommand('moonbit.commands.openEditor', 10000);

    const editor = new TextEditor();
    const contents = await editor.getText();
    expect(contents).to.include('MoonBit command editor ok');

    await ensureCommand('moonbit.commands.insertText', 10000);
    const updated = await editor.getText();
    expect(updated).to.include('MoonBit edit ok');
  });

  it('inserts text via async text editor command', async () => {
    await ensureCommand('moonbit.commands.openEditor', 10000);

    const editor = new TextEditor();
    await ensureCommand('moonbit.commands.insertTextAsync', 10000);
    const updated = await editor.getText();
    expect(updated).to.include('MoonBit async edit ok');
  });

  it('lists commands', async () => {
    await ensureCommand('moonbit.commands.showCommandCount', 10000);

    const statusBar = new StatusBar();
    const item = await waitForStatusItem(statusBar, 'Commands ok', 10000);
    expect(item).to.not.equal(undefined);
  });

  it('checks command existence', async () => {
    await ensureCommand('moonbit.commands.ensureCommand', 10000);

    const statusBar = new StatusBar();
    const item = await waitForStatusItem(statusBar, 'Command exists', 10000);
    expect(item).to.not.equal(undefined);
  });

  it('shows status bar item', async () => {
    await ensureCommand('moonbit.commands.showStatus', 10000);

    const statusBar = new StatusBar();
    const item = await waitForStatusItem(
      statusBar,
      'MoonBit commands ready',
      10000,
    );
    expect(item).to.not.equal(undefined);
  });
});
