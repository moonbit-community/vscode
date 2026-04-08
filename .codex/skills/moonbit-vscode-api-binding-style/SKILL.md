---
name: moonbit-vscode-api-binding-style
description: Bind VS Code extension APIs into MoonBit with typed public signatures and minimal JS leakage. Use when designing FFI modules, overload mapping, enum bindings, and async callback bridges.
---

# MoonBit VS Code API Binding Style

## When to Use
Use this skill when implementing or refactoring MoonBit bindings for VS Code
extension APIs.

## Source of Truth
Start from:
- `references/vscode.d.ts` (vendored `@types/vscode` API surface)
- Official VS Code API docs for behavior notes

Update the vendored type file after dependency bumps:

```bash
npm install
npm run update:vscode-dts
```

This runs `scripts/update-vscode-dts.mjs`.

## Binding Design Rules
- Keep public signatures typed for MoonBit users.
- Use `Option` for optional parameters.
- Convert `None` -> JS `undefined` only at the FFI boundary.
- Split TypeScript overloads into separate MoonBit functions.
- Avoid `JsValue` in public signatures.
- Avoid `@js_async.Promise` in public signatures.
- If JS expects a Promise callback, accept MoonBit `async` callbacks publicly and wrap using `Promise::from_async` internally.
- Prefer explicit function names over shape/object arguments when overloads differ in intent.
- Prefer type methods (`Type::new`, `Type::from_*`, `Type::as_*`) over free helper functions.
- Prefer instance call style (`value.method(...)`) for non-static operations.
- Bind numeric enums with MoonBit enum-const FFI (no per-variant runtime getter helpers).
- Prefer MoonBit concrete types in API-level signatures (`struct`, `enum`, concrete wrapper types).
- For TypeScript data-only interfaces (options/parameter objects/plain records), model them as MoonBit concrete types (typically `struct`) instead of exposing raw JS object shapes.
- Convert MoonBit concrete types to JS objects at the FFI layer, and convert JS values back to concrete MoonBit types at API read boundaries.
- For TypeScript behavioral interfaces (providers, callback objects with methods), model the public contract as a MoonBit `trait`.
  - Do not use `*Like` naming for interface traits.
  - Prefer the interface name directly (`TaskProvider`, `FileSystemProvider`, ...).
  - Do not expose `*ProviderTrait` names in public APIs.
  - In `core`, keep runtime JS object carriers named `*ProviderObject`.
  - `core` should own provider traits whenever the runtime object type lives in `core`.
  - `register_*` APIs in non-core packages should constrain `@core.*Provider` traits and convert with `@core.*_provider_from_trait(...)`.
  - Do not add per-package bridge traits whose only purpose is forwarding to core (`as_core_*`, single-method wrapper traits).
  - Keep raw external object types as FFI-boundary glue only, and convert trait values to raw JS objects at registration/construction boundaries.
- For typed TS unions modeled as MoonBit enums, prefer direct enum variants in the public API.
- Do not add redundant enum helper constructors (for example `from_bool`, `from_options`) when they only mirror variants and add no conversion logic.
- In examples/call sites, when type context is known, prefer concise variant construction (for example `BoolValue(true)`) over long `Type::Variant(...)` prefixes.

## Step-by-Step Workflow
1. Pick target API in `references/vscode.d.ts` and list overloads, optional params, and return type behavior.
2. Define MoonBit public signatures:
   - one function per overload
   - `Option` for optional params
   - typed enum/union wrappers where needed
3. Implement internal FFI adapter layer:
   - optional-to-undefined conversion
   - callback/promise wrapping
   - internal `JsValue` conversions only
4. Expose ergonomic methods on relevant types instead of free functions.
5. Add usage examples or fixture calls in `test/extensions/window/extension.mbt` style.
6. Validate with MoonBit build/check and extension test fixtures.

## API Mapping Patterns
- Optional TS argument:
  - TS: `showInformationMessage(message: string, ...items?: string[])`
  - MoonBit public: use `Option[...]` for optional collections.
- Promise callback TS contract:
  - MoonBit public: `async` callback
  - FFI internal: wrap callback with `Promise::from_async`
- Overloads:
  - TS overload set -> several named MoonBit functions with explicit semantics.

## Quality Checklist
- Public API has no raw JS runtime types.
- Each TS overload is represented without ambiguity.
- Optional behavior is explicit in types.
- Methods are attached to relevant types where possible.
- Enum constants are typed and compile-time visible.
- Data-only TS interfaces are represented as MoonBit concrete types (typically structs) at API level.
- JS object construction/parsing is isolated to FFI helpers.
- Union-enum APIs do not include redundant helper constructors that duplicate variant construction.
- Examples use concise enum variant construction when type context makes it unambiguous.

## References
- `references/vscode.d.ts`
- `test/extensions/window/extension.mbt`
