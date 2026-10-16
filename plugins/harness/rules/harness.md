# Harness — Workflow Rules

These rules govern how the four harness agents (`lead`, `builder`, `reviewer`, `verifier`) coordinate work. They apply whenever a task is complex enough to warrant decomposition (multi-file, ambiguous, or architecturally significant).

## The Pipeline

```
lead  →  builder  →  reviewer  →  verifier
plan     implement    review       verify
```

Every non-trivial task flows through all four stages. Stages cannot be skipped or reordered.

## Core Rules

### 1. Writer and reviewer are always separate

The agent that writes code (`builder`) is never the same agent that reviews it (`reviewer`) or verifies it (`verifier`). No self-approval.

### 2. Plan before code

`builder` does not start until `lead` has produced a plan. If there is no plan, there is no implementation.

### 3. One writer per file

Only one `builder` instance writes to a given file at a time. Parallel builders must have non-overlapping file ownership.

### 4. Blockers block

If `reviewer` returns BLOCK (any CRITICAL or HIGH finding), `builder` must fix before `verifier` runs. If `verifier` returns BLOCKED, the cycle repeats until clean.

### 5. Evidence over claims

"It works" is not evidence. `verifier` must produce command output (test results, build logs, type-check output) to prove completion.

### 6. No fake completion

These patterns are blockers, not evidence of done:
- `TODO`, `FIXME`, `HACK` comments
- `test.skip`, `.only`, `xit`, `xdescribe`
- Empty function bodies or stub implementations
- `throw new Error('not implemented')`

### 7. Minimal scope

Each agent stays in its lane:
- `lead` never writes code
- `builder` never reviews its own work
- `reviewer` never writes fixes
- `verifier` never writes fixes

## When to Use the Full Pipeline

| Signal | Action |
|--------|--------|
| Multi-file change | Full pipeline |
| New feature | Full pipeline |
| Security-sensitive code | Full pipeline |
| Single-file bug fix | builder → verifier (skip lead + reviewer for trivial fixes) |
| Documentation only | Direct edit (no pipeline needed) |
| Config change | builder → verifier |

## Parallel Execution

When `lead` produces independent subtasks (no dependency edges between them), run multiple `builder` instances in parallel — one per subtask, each with exclusive file ownership.
