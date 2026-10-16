# Harness — Minimal Multi-Agent Pipeline for Claude Code

A lightweight four-agent pipeline built entirely from native Claude Code primitives. No external dependencies, no runtime overhead — just agents, rules, and a hook.

## Pipeline

```
lead (Opus 5.5)  →  builder (Sonnet 5.5)  →  reviewer (Haiku 5.5)  →  verifier (Haiku 5.5)
    plan                implement                 review                  verify
```

## Agents

| Agent | Model | Role | Tools |
|-------|-------|------|-------|
| **lead** | Opus 5.5 | Read-only planner. Decomposes requests into a DAG of subtasks. | Read, Grep, Glob |
| **builder** | Sonnet 5.5 | Implements code following the plan. | Read, Write, Edit, Grep, Glob, Bash |
| **reviewer** | Haiku 5.5 | Read-only 5-axis code review (correctness, security, performance, style, completeness). | Read, Grep, Glob, Bash |
| **verifier** | Haiku 5.5 | Read-only evidence-based verification. Runs builds, tests, linters. | Read, Grep, Glob, Bash |

## Core Rules

1. **Writer and reviewer are always separate** — no self-approval
2. **Plan before code** — builder waits for lead's plan
3. **One writer per file** — parallel builders get non-overlapping ownership
4. **Blockers block** — CRITICAL/HIGH findings must be fixed before verification
5. **Evidence over claims** — verifier produces command output, not assertions
6. **No fake completion** — TODOs, test.skip, stubs are blockers
7. **Minimal scope** — each agent stays in its lane

## Hook

The `stop-lint-typecheck.sh` hook runs once per turn (on Stop) when inside a TypeScript/JavaScript project. It's non-blocking (always exits 0) and runs:
- `tsc --noEmit` (30s timeout)
- `eslint` on git-changed files only (30s timeout)

## Install

```bash
claude plugin add /path/to/claude-harness-plugin
```

Or from a git repo:

```bash
claude plugin add https://github.com/YOUR_USERNAME/claude-harness-plugin
```

## When to Use the Full Pipeline

| Situation | Pipeline |
|-----------|----------|
| Multi-file change | lead → builder → reviewer → verifier |
| New feature | lead → builder → reviewer → verifier |
| Security-sensitive code | lead → builder → reviewer → verifier |
| Single-file bug fix | builder → verifier |
| Documentation only | Direct edit |
| Config change | builder → verifier |

## Inspired By

Built on the "Harness Engineering" principles from [@mirku21](https://x.com/mirku21) — three layers (harness, loop, graph) using native Claude Code primitives instead of plugin-based orchestration.
