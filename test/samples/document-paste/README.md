# Document Paste Edit Sample

This sample example shows how to use the document paste APIs. This api let's extension hook into VS Code's normal copy and paste operations in text documents.

With this API you can:

- On copy, write data to the clipboard. This includes writing metadata that the can be picked up on paste.

- On paste, generate a custom edit that applies the paste. This can change the content being pasted or make more complex workspace edits, such as creating new files.

- Extensions can provide multiple ways that content can be pasted. Users can select how content should be pasted using the UI or with the `editor.pasteAs.preferences` setting.

Requires VS Code 1.97+.

## Running This MoonBit Port

- Open this folder (`test/samples/document-paste`) in VS Code
- `moon check --target js`
- `moon build --target js --release`
- Run the `Run Extension` target in the Debug View (or press `F5`)
