# Project Directives For Codex

This repository has strict execution rules. Follow all of them on every task.

## 1) Primary Goal

- The project goal is to bind the full VS Code API surface in MoonBit.
- Prefer work that increases binding coverage, correctness, and typed API quality.

## 2) Commit Regularly

- Commit regularly to avoid losing progress.
- Make small, focused commits at meaningful milestones.
- Do not wait for a very large batch of changes before committing.

## 3) MoonBit Must Be Clean (No Errors, No Warnings)

- Before finishing work, ensure `moon check` and `moon build` pass with no errors and no warnings.
- Treat warnings as failures.
- Also run `moon info` for the main module to refresh interface files (`pkg.generated.mbti`).
- `moon info` is required only for the main module, not for test extensions.
  Validate both:
- the main binding module(s) in this repository

Suggested validation commands:

```bash
# Main project
moon check --target js
moon build --target js
moon info --target js
```

## Completion Policy

- Do not consider a task complete until rules 1-4 are satisfied, or a blocker is explicitly reported.
