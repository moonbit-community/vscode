# Hello World Sample

This is a Hello World Web Extension example that shows you how to write a extension that runs in VS Code Web (alone)

Guide for this sample: https://code.visualstudio.com/api/extension-guides/web-extensions.


## VS Code API

### `vscode` module

- [`commands.registerCommand`](https://code.visualstudio.com/api/references/vscode-api#commands.registerCommand)
- [`window.showInformationMessage`](https://code.visualstudio.com/api/references/vscode-api#window.showInformationMessage)

### Contribution Points

- [`browser`](https://code.visualstudio.com/api/references/extension-manifest)

- [`contributes.commands`](https://code.visualstudio.com/api/references/contribution-points#contributes.commands)

## Running the Sample

- Run `npm install` in terminal to install dependencies
- Run the `Run Web Extension` target in the Debug View. This will:
	- Start a task `npm: watch` to compile the code
	- Run the extension in a new VS Code window that contains a web extension host

## Running This MoonBit Port

- Open this folder (`test/samples/helloworld-web-sample`) in VS Code
- `moon check --target js`
- `moon build --target js`
- Run the `Run Extension` target in the Debug View (or press `F5`)
