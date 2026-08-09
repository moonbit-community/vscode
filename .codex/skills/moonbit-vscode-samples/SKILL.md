---
name: moonbit-vscode-samples
description: Rewrite VS Code extension samples from microsoft/vscode-extension-samples into MoonBit extensions that use this repository's bound VS Code API (`moonbit-community/vscode/*`). Use when asked to port, translate, or reimplement an upstream sample extension in MoonBit with exact upstream behavior and sample-scoped validation.
---

# MoonBit VS Code Samples Porting

## Goal
Port each VS Code sample so it matches the upstream sample behavior and implementation intent as closely as possible, while remaining idiomatic MoonBit and using this repository's typed bindings.

## Reference Source
Use upstream sample source from:
- `references/vscode-extension-samples`

If missing, initialize submodules from repo root with:
- `git submodule update --init --recursive`

## Non-Negotiables
1. Match the official sample exactly in user-visible behavior, command IDs, provider IDs, messages, and lifecycle behavior.
2. Prefer bound APIs over JS FFI in sample code.
3. Do not add utility JS FFI in samples for common tasks already covered by MoonBit or bindings.
4. For HTTP in JS samples, prefer `moonbitlang/async/http` instead of custom `fetch` FFI.
5. Keep sample code free of raw `JsValue` and `#external` declarations unless there is no typed API path.
6. Avoid useless `ignore(...)` wrappers. Use explicit discard bindings like `let _ = ...` when needed.
7. Make the sample runnable directly in VS Code by adding:
- `.vscode/launch.json`
- `.vscode/tasks.json`
8. Copy the upstream sample `README.md` and adapt only the setup/run instructions for the MoonBit port.
9. Keep runtime artifact and build mode aligned: if `package.json.main` points to `/_build/js/release/...`, then sample scripts/tasks/README commands must build with `moon build --target js --release`.

## File Mapping In This Repository
Put ported samples in this layout:

```text
test/samples/<sample-name>/
  .vscode/launch.json
  .vscode/tasks.json
  README.md
  extension.mbt
  moon.mod.json
  moon.pkg.json
  package.json
  settings.json
```

## Porting Workflow
1. Locate and read upstream `package.json`, `src/extension.ts`, and `README.md`.
2. Port behavior first, preserving IDs and message text.
3. Implement with `moonbit-community/vscode/*` bindings and MoonBit stdlib/async packages.
4. Copy upstream `README.md` and keep its structure/content, but update build/run steps for MoonBit (`moon check`, `moon build`, sample-local `F5`).
5. Ensure `package.json.main`, npm scripts, `.vscode/tasks.json`, and README run commands all use the same build mode (release/debug) so F5 runs the latest compiled artifact.
6. Add sample-local `.vscode/launch.json` and `.vscode/tasks.json` so `F5` works from the sample folder.
7. If APIs are missing in bindings, add typed binding support in main module first, then finish sample port.

## JS/TS -> MoonBit Translation Rules
- Replace `import * as vscode from 'vscode'` with scoped imports such as `moonbit-community/vscode/core`, `moonbit-community/vscode/commands`, `moonbit-community/vscode/window`, `moonbit-community/vscode/workspace`, and other API modules in this repo.
- Replace `context.subscriptions.push(disposable)` with:
  - `let subscriptions = ctx.subscriptions()`
  - `subscriptions.push(disposable)`
- Replace `vscode.commands.registerCommand(...)` with `@commands.register_command(...)` or `@commands.register_command_async(...)`.
- Preserve async behavior by using `async fn` handlers and async binding calls.
- Keep exported `activate` synchronous; for async startup work use `@vscode.activate_async(ctx, async_startup_fn)` instead of importing `@js_async` directly in samples.
- Represent optional arguments/results with `Option` (`None`/`Some(...)`) instead of JS `undefined`/`null`.
- Keep JS FFI out of final fixture code whenever a typed binding or MoonBit package can do the job.

## Handling Missing Bindings
When the sample uses an API that is not bound yet:
1. Implement the binding in the relevant top-level package (`authentication`, `chat`, `comments`, `core`, `debug`, `env`, `extensions`, `l10n`, `languages`, `lm`, `notebooks`, `scm`, `tasks`, `tests`, `window`, `workspace`).
2. Keep public signatures typed and avoid leaking `JsValue` in public APIs.
3. Expose overloads as explicit MoonBit functions.
4. Validate the main module before returning to sample-port work.

## Validation Policy
When focused on one sample, validate only that sample unless explicitly asked to run broader checks.

Required sample-local validation:
- `cd test/samples/<sample-name>`
- `moon check --target js`
- `moon build --target js`

Do not run full repository checks or UI test suites unless explicitly requested.

If binding code in the main module was changed as part of the sample port, also run:
- `moon check --target js`
- `moon build --target js`
- `moon info --target js`
