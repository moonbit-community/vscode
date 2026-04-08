---
name: moonbit-vscode-test-harness
description: Write VS Code UI tests with ExTester by reading ExTester docs first, collecting observable signals with ExTester APIs, and asserting one stable evidence path.
---

# ExTester-First Test Harness for MoonBit

## Scope
This skill is only about using ExTester (`vscode-extension-tester`) to write stable VS Code UI tests.
Do not use this skill for API binding design or MoonBit refactoring.

## Where to Read ExTester (Mandatory Order)
Use the local reference clone in this skill:
`references/vscode-extension-tester`

Read in this order before writing or changing tests:
1. `references/vscode-extension-tester/README.md`
2. `references/vscode-extension-tester/docs/Home.md`
3. `references/vscode-extension-tester/docs/Test-Setup.md`
4. `references/vscode-extension-tester/docs/Writing-Simple-Tests.md`
5. `references/vscode-extension-tester/docs/Page-Object-APIs.md`

Then read only page objects needed for your target behavior:
- `docs/Workbench.md` for command execution (`new Workbench().executeCommand(...)`)
- `docs/OutputView.md` for output-channel evidence
- `docs/TextEditor.md` for editor text/title/file-path evidence
- `docs/TerminalView.md` for terminal evidence
- `docs/StatusBar.md` for status bar evidence
- `docs/Notification.md` and `docs/ModalDialog.md` for error/interaction evidence

For practical patterns, inspect:
- `references/vscode-extension-tester/tests/test-project`

## ExTester Setup and Run
From a test fixture root:

```bash
npm install
npm run ui-test
```

Preferred runner command shape:

```bash
extest setup-and-run "./out/ui-test/*.test.js" \
  --code_version max \
  --code_settings settings.json \
  --extensions_dir .test-extensions \
  --mocha_config ui-test/.mocharc.js
```

## Mandatory Workflow: Evidence First, Assertion Second
Never start with final assertions.
Always run this sequence:

1. Discovery pass
- Execute the target command with ExTester (`Workbench.executeCommand`).
- Read every observable signal ExTester can fetch (output text, editor text/title, terminal text, notifications, modal dialog text, status bar strings).
- Save raw observations in test logs or temporary debug output.

2. Candidate evidence list
- Create a short list of possible assertions from discovery results.
- Keep only user-visible signals retrieved via ExTester page objects.

3. Stability scoring
Choose one primary evidence that is:
- Deterministic across repeated runs
- Directly caused by the tested behavior
- Not timing-fragile (no arbitrary sleeps required)
- Not locale/theme dependent unless the feature itself is locale/theme specific
- Readable with one clear ExTester API call path

4. Assertion lock
- Write one primary assertion for the chosen evidence.
- Add only minimal secondary assertions needed for safety (for example, "no unexpected modal dialog").

5. Stabilization
- Replace fixed sleeps with condition polling.
- Re-run until stable.
- If flaky, return to discovery pass and pick a better primary evidence.

## Evidence Collection Patterns (ExTester API)
Use these API paths during discovery:

```typescript
import {
  BottomBarPanel,
  EditorView,
  ModalDialog,
  TextEditor,
  Workbench,
} from "vscode-extension-tester";

// Trigger behavior
await new Workbench().executeCommand("your command");

// Output channel evidence
const output = await new BottomBarPanel().openOutputView();
await output.selectChannel("Your Channel");
const outputText = await output.getText();

// Editor evidence
const editor = (await new EditorView().openEditor("file.txt")) as TextEditor;
const editorText = await editor.getText();

// Modal guard evidence
const dialog = new ModalDialog();
let modalMessage = "";
try {
  modalMessage = await dialog.getMessage();
} catch {
  modalMessage = "";
}
```

## Test Flow Template
Use this shape in `ui-test/*.test.ts`:

1. Setup
- Open needed view/editor state.
- Ensure expected channel/file is ready.

2. Trigger
- Run command with `Workbench.executeCommand`.

3. Collect
- Read the selected primary evidence with ExTester API.

4. Assert
- Assert the primary evidence exactly.
- Assert no unexpected modal dialog.

5. Cleanup
- Close transient editors/views if needed.
- Keep teardown deterministic.

## Hard Rules
- Do not assert internal extension memory/state as primary evidence.
- Do not rely on arbitrary `sleep`.
- Do not keep multiple competing primary assertions; pick one stable signal.
- If no stable signal exists, redesign extension behavior to expose one user-visible ExTester-readable signal, then test it.
