# Azure DevOps Auth Provider - Authentication Provider API Sample

Demonstrates VS Code's authentication provider API by registering and using an Azure DevOps Personal Access Token authentication provider.

## VS Code API

### `vscode` module

- [`authentication.registerAuthenticationProvider`](https://code.visualstudio.com/api/references/vscode-api#authentication.registerAuthenticationProvider)
- [`authentication.getSession`](https://code.visualstudio.com/api/references/vscode-api#authentication.getSession)

## Running the example

- Open this folder (`test/samples/authenticationprovider-sample`) in VS Code 1.100+
- `moon check --target js`
- `moon build --target js --release`
- `F5` to start debugging

Run the `Login with Azure DevOps` command to log in.
