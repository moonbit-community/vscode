# VS Code Official Sample Porting

This directory tracks MoonBit rewrites of official VS Code extension samples using the typed `username/vscode/*` bindings from this repository.

## Porting Order

The queue is intentionally ordered from simple to complex so binding gaps show up gradually.

1. Command-only samples
  - `helloworld-minimal-sample` (ported)
  - `helloworld-sample` (ported)
  - `notifications-sample` (ported)
  - `progress-sample` (ported)
  - `statusbar-sample` (ported)
  - `configuration-sample`
  - `basic-multi-root-sample` (ported)
2. Single-provider editor samples
   - `completions-sample`
   - `codelens-sample`
   - `code-actions-sample`
   - `contentprovider-sample`
   - `document-editing-sample`
3. Stateful editor and UI samples
   - `document-paste`
   - `drop-on-document`
   - `decorator-sample`
   - `comment-sample`
   - `custom-editor-sample`
4. Workspace and platform integration
   - `extension-terminal-sample`
   - `fsconsumer-sample`
   - `fsprovider-sample`
   - `nodefs-provider-sample`
   - `authenticationprovider-sample`
   - `github-authentication-sample`
5. Advanced platform APIs
   - `l10n-sample`
   - `chat-context-sample`
   - `chat-sample`
   - `chat-tutorial`
   - `lm-api-tutorial`
   - `mcp-extension-sample`
6. Multi-component samples
   - `helloworld-web-sample`
   - `jupyter-kernel-execution-sample`
   - `jupyter-server-provider-sample`
   - `lsp-*`

## Current Rule

Each port should match the upstream sample's command IDs, contribution points, visible messages, and lifecycle behavior before moving on to the next step in the queue.
