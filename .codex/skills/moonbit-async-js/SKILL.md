---
name: moonbit-async-js
description: Use when working with MoonBit `moonbitlang/async` on the JS/Node backend, especially to explain or implement event-loop scheduling, Promise/AbortSignal interop, or exporting MoonBit async functions to JavaScript.
---

# MoonBit Async JS

## Overview
Explain and apply the JS backend behavior of `moonbitlang/async`: how coroutines are scheduled on top of the JS event loop, how Promise interop works, and how cancellation is wired through `AbortSignal`.

## Repo dependency source
For this repository, `moonbitlang/async` is sourced from a local path dependency:

```json
"moonbitlang/async": { "path": "../async" }
```

Treat this as the default when reasoning about behavior or proposing changes:
- Read code from the local `../async` checkout (bug-fix branch), not from a published release.
- Prefer validating against local source under `../async/src/js_async` and `../async/src/internal/event_loop`.
- Do not switch back to a versioned registry dependency unless explicitly requested.

## Quick start
- Confirm `moon.mod.json` still points `moonbitlang/async` to `../async`.
- Confirm the target is JS and import `moonbitlang/async/js_async` when Promise interop is needed.
- Use `@js_async.Promise::wait` to await a JS Promise inside MoonBit.
- Use `@js_async.run_promise` for JS APIs that accept `AbortSignal` and should be cancellable.
- Use `@js_async.Promise::from_async` only when exporting MoonBit async to JS (no structured concurrency).
- Use `@async.pause` in CPU-bound loops to yield to the JS event loop.
- Avoid `@async.with_event_loop`; it is native-only and deprecated for JS.

## Event loop semantics (JS backend)
- Treat `@event_loop.reschedule()` as the bridge to the JS event loop: it runs one round of ready coroutines, then yields via `setTimeout(0, ...)` if more are ready.
- Treat `@async.sleep(ms)` as a JS timer that wakes the coroutine and calls `reschedule`.

## Promise interop patterns
Use these patterns in MoonBit code targeting JS.

### Await a JS Promise (non-cancellable)
```moonbit
let value = @js_async.Promise::wait(jsPromise)
```
If no `AbortController` is supplied, `wait` is protected from cancellation.

### Await a JS Promise with cancellation
```moonbit
let value = @js_async.run_promise(signal => jsApiCall(signal))
```
Prefer this when the JS API accepts `AbortSignal`.

### Export MoonBit async to JS
```moonbit
let p = @js_async.Promise::from_async(() => doWork(), abort_signal=signal)
```
Only use this for JS interop; it runs outside structured concurrency and rejects with `AbortError` on cancellation.

## References
- `references/js-backend.md` for implementation details and scheduling notes.
