# Hello World Minimal Sample

This is a MoonBit port of the official [Hello World Sample](https://github.com/microsoft/vscode-extension-samples/tree/main/helloworld-sample).

It keeps the original behavior of the upstream [`helloworld-minimal-sample`](https://github.com/microsoft/vscode-extension-samples/tree/main/helloworld-minimal-sample) while replacing the JavaScript implementation with this repository's `username/vscode/*` bindings.

## VS Code API

### `vscode` module

- [`commands.registerCommand`](https://code.visualstudio.com/api/references/vscode-api#commands.registerCommand)
- [`window.showInformationMessage`](https://code.visualstudio.com/api/references/vscode-api#window.showInformationMessage)

### Contribution Points

- [`contributes.commands`](https://code.visualstudio.com/api/references/contribution-points#contributes.commands)

## Running the Sample

- Run `moon check --target js` in this folder.
- Run `moon build --target js --release`.
- Run the `Run Extension` target in the Debug View, or press `F5` from this sample folder.
