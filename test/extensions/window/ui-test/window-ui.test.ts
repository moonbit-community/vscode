import { expect } from 'chai';
import {
  BottomBarPanel,
  EditorView,
  ModalDialog,
  OutputView,
  VSBrowser,
  Workbench,
} from 'vscode-extension-tester';

const outputChannel = 'MoonBit Window';

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

async function getOutputView() {
  const bottomBar = new BottomBarPanel();
  const output = await bottomBar.openOutputView();
  await output.selectChannel(outputChannel);
  await output.getDriver().sleep(400);
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
    await VSBrowser.instance.driver.sleep(400);
  }
  throw new Error(`Timed out waiting for output match: ${pattern.source}`);
}

function runTagFrom(contents: string, scope: string, prefix: string) {
  const regex = new RegExp(`${scope} (${prefix}-\\d+) start`);
  const match = contents.match(regex);
  if (!match) {
    throw new Error(contents);
  }
  return match[1];
}

describe('Window namespace bindings', function () {
  this.timeout(180000);

  afterEach(async () => {
    await closeEditorsAndAssertNoModal('after test');
  });

  after(async () => {
    await assertNoUnexpectedModal('before suite shutdown', 2000);
  });

  it('checks core window/editor/notebook behavior', async () => {
    await ensureCommand('moonbit.window.checkCore', 20000);
    const output = await getOutputView();
    const contents = await waitForOutputMatch(
      output,
      /window\.core core-\d+ done/,
      30000,
    );

    const runTag = runTagFrom(contents, 'window.core', 'core');

    expect(contents).to.include(`window.core ${runTag} value api=window_state`);
    expect(contents).to.include(`window.core ${runTag} value api=tab_groups`);
    expect(contents).to.include(`window.core ${runTag} value api=show_text_document`);
    expect(contents).to.include(`window.core ${runTag} value api=show_text_document_uri`);
    expect(contents).to.include(`window.core ${runTag} value api=create_text_editor_decoration_type`);
    expect(contents).to.include(`window.core ${runTag} value api=show_notebook_document`);
    expect(contents).to.include(`window.core ${runTag} callback notebook.deserialize`);
    expect(contents).to.not.include('window.core error');
  });

  it('checks quick input and message behavior', async () => {
    await ensureCommand('moonbit.window.checkQuickInput', 30000);
    const output = await getOutputView();
    const contents = await waitForOutputMatch(
      output,
      /window\.quickinput quickinput-\d+ done/,
      45000,
    );

    const runTag = runTagFrom(contents, 'window.quickinput', 'quickinput');

    expect(contents).to.include(`window.quickinput ${runTag} value api=create_input_box`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=create_quick_pick`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_input_box`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_quick_pick`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_quick_pick_many`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_quick_pick_strings`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_quick_pick_strings_many`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_information_message`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_information_message_items`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_warning_message`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_warning_message_items`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_error_message`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_error_message_items`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_workspace_folder_pick skipped_non_interactive=true`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_open_dialog skipped_non_interactive=true`);
    expect(contents).to.include(`window.quickinput ${runTag} value api=show_save_dialog skipped_non_interactive=true`);
    expect(contents).to.not.include('window.quickinput error');
  });

  it('checks terminal/progress/status behavior', async () => {
    await ensureCommand('moonbit.window.checkTerminal', 20000);
    const output = await getOutputView();
    const contents = await waitForOutputMatch(
      output,
      /window\.terminal terminal-\d+ done/,
      30000,
    );

    const runTag = runTagFrom(contents, 'window.terminal', 'terminal');

    expect(contents).to.include(`window.terminal ${runTag} value api=create_output_channel`);
    expect(contents).to.include(`window.terminal ${runTag} value api=create_log_output_channel`);
    expect(contents).to.include(`window.terminal ${runTag} value api=create_status_bar_item`);
    expect(contents).to.include(`window.terminal ${runTag} value api=create_status_bar_item_with_id`);
    expect(contents).to.include(`window.terminal ${runTag} value api=set_status_bar_message`);
    expect(contents).to.include(`window.terminal ${runTag} value api=progress`);
    expect(contents).to.include(`window.terminal ${runTag} value api=terminal_snapshot`);
    expect(contents).to.not.include('window.terminal error');
  });

  it('checks window provider and registration behavior', async () => {
    await ensureCommand('moonbit.window.checkProviders', 25000);
    const output = await getOutputView();
    const contents = await waitForOutputMatch(
      output,
      /window\.providers providers-\d+ done/,
      35000,
    );

    const runTag = runTagFrom(contents, 'window.providers', 'providers');

    expect(contents).to.include(`window.providers ${runTag} value api=tree_view`);
    expect(contents).to.include(`window.providers ${runTag} value api=register_uri_handler`);
    expect(contents).to.include(`window.providers ${runTag} value api=create_webview_panel`);
    expect(contents).to.include(`window.providers ${runTag} value api=create_webview_panel_show_options`);
    expect(contents).to.include(`window.providers ${runTag} value api=register_webview_view_provider`);
    expect(contents).to.include(`window.providers ${runTag} value api=register_custom_text_editor_provider`);
    expect(contents).to.include(`window.providers ${runTag} value api=register_terminal_link_provider`);
    expect(contents).to.include(`window.providers ${runTag} value api=register_terminal_profile_provider`);
    expect(contents).to.include(`window.providers ${runTag} value api=register_file_decoration_provider`);
    expect(contents).to.include(`window.providers ${runTag} callback uri_handler`);
    expect(contents).to.include(`window.providers ${runTag} callback custom_editor`);
    expect(contents).to.include(`window.providers ${runTag} callback file_decoration_provider.provide`);
    expect(contents).to.not.include('window.providers error');
  });
});
