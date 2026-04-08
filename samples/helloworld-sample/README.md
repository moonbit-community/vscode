# Hello World Sample

This is a Hello World example that shows you how to use VS Code API.

Guide for this sample: https://code.visualstudio.com/api/get-started/your-first-extension.

## Demo

![demo](https://raw.githubusercontent.com/Microsoft/vscode-extension-samples/main/helloworld-sample/demo.gif)

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
