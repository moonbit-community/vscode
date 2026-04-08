# Status Bar Sample

This is a sample extension that adds a status bar entry showing the current number of selected lines.

![Show number of selected lines](https://raw.githubusercontent.com/Microsoft/vscode-extension-samples/main/statusbar-sample/preview.gif)


## VS Code API

### `vscode` module

- [`window.createStatusBarItem`](https://code.visualstudio.com/api/references/vscode-api#window.createStatusBarItem)

## Running This MoonBit Port

- Open this folder (`test/samples/statusbar-sample`) in VS Code
- `moon check --target js`
- `moon build --target js --release`
- Run the `Run Extension` target in the Debug View (or press `F5`)
