# MoonBit async JS backend notes

## Event loop bridge (JS target)
- Source: `moonbitlang/async/src/internal/event_loop/event_loop.js.mbt`.
- `@event_loop.reschedule()`:
  - Return early if `@coroutine.no_more_work()`.
  - Call `@coroutine.reschedule()` to run one round of ready coroutines.
  - If more coroutines are ready after that round, schedule another round with `setTimeout(0, reschedule)`.
  - This yields to the JS event loop (macrotask), so JS I/O and timers get a chance to run and prevents starvation.
- `@async.sleep(ms)`:
  - Implemented with `setTimeout`.
  - On timer fire: `coro.wake()` then `reschedule()`.
  - On cancellation: the timer is cancelled before propagating the error.

## Coroutine scheduling details
- Source: `moonbitlang/async/src/internal/coroutine/scheduler.mbt`.
- `@coroutine.reschedule()` executes only the coroutines that were ready at the start of the call.
- Newly woken or spawned coroutines during that round are deferred until the next `reschedule` call.

## Promise interop (JS target)
- Source: `moonbitlang/async/src/js_async/js_async.mbt`.
- `Promise::wait(promise, abort_controller?)`:
  - Attaches `promise.then(resolve, reject)` and stores result/error.
  - On resolve/reject, wakes the waiting coroutine and calls `@event_loop.reschedule()`.
  - If `abort_controller` is provided, cancellation aborts the controller.
  - If absent, uses `@coroutine.protect_from_cancel`, so the wait is non-cancellable.
- `run_promise(f)`:
  - Creates an `AbortController`, passes its `signal` to `f`.
  - Awaits the returned promise via `Promise::wait` with the controller for cancellation.
- `Promise::from_async(f, abort_signal?)`:
  - Spawns a MoonBit coroutine and exposes it as a JS Promise.
  - If cancelled via `abort_signal`, rejects with JS `AbortError`.
  - If MoonBit raises an error, rejects with its string representation.
  - Runs in a global context; there is no structured concurrency.

## Node/JS event loop interplay summary
- Promise resolution runs in the JS microtask queue, and the `then` callback calls `reschedule()` immediately.
- If more MoonBit coroutines become ready during that round, `reschedule` schedules a `setTimeout(0, ...)` macrotask to continue, yielding back to the JS event loop.
