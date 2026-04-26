# Smoke Extension Tests

The smoke extension exercises the MoonBit VS Code API bindings from a real extension host. It has two test layers:

- `npm run test:integration` runs API behavior checks through VS Code commands and extension-host assertions.
- `npm run test:ui` launches VS Code headless, drives UI behavior with Playwright, captures screenshots, and compares them with committed baselines.

Run both layers with:

```sh
npm run test:smoke
```

## Screenshot Baselines

UI screenshots are platform-specific because VS Code and Electron render text and workbench chrome differently by OS and CPU architecture. Baselines live under:

```text
test/extensions/smoke/ui/baselines/<platform>/
```

For example, Apple Silicon macOS uses:

```text
test/extensions/smoke/ui/baselines/darwin-arm64/
```

`npm run test:ui` is compare-only. It fails when a baseline is missing or when an image differs by more than `VSCODE_MBT_UI_MAX_DIFF_PIXELS`, which defaults to `1000`. Diff images are written to:

```text
.vscode-test/smoke-ui/diffs/
```

The comparison uses ImageMagick. Install either `magick` or `compare` before running `npm run test:ui`.

## Updating Baselines

Only update baselines after reviewing the behavior change in the generated screenshots:

```sh
npm run test:ui:update
npm run test:ui
```

Then inspect:

```text
test/extensions/smoke/ui/baselines/<platform>/
.vscode-test/smoke-ui/screenshots/
```

Commit the changed baseline PNGs with the code or test change that intentionally changed the UI behavior.

## New Platforms

When running screenshot tests on a new platform, `npm run test:ui` reports missing baselines. Generate them with `npm run test:ui:update`, inspect every screenshot, then commit the new `baselines/<platform>` directory.

## CI

The manual `Smoke Tests` workflow runs on macOS arm64 because the committed UI baselines are currently `darwin-arm64`. Add another baseline directory before enabling screenshot comparison on another runner platform.
