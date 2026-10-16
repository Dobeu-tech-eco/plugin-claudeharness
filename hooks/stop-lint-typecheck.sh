#!/usr/bin/env bash
# Stop hook: run lint + typecheck once per turn (if tooling exists).
# Non-blocking — exits 0 always. Prints warnings to stderr so Claude sees them.
# Runs only when inside a git repo with a package.json.

set -euo pipefail

# Fast bail if not in a project
[ -f "package.json" ] || exit 0

# Check for node_modules — skip if deps aren't installed
[ -d "node_modules" ] || exit 0

# Typecheck (tsc --noEmit, 30s timeout)
if grep -q '"tsc"' package.json 2>/dev/null || [ -f "tsconfig.json" ]; then
  if command -v npx >/dev/null 2>&1; then
    timeout 30 npx tsc --noEmit 2>&1 | tail -20 >&2 || true
  fi
fi

# Lint (eslint on changed files only, 30s timeout)
if [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.cjs" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then
  changed=$(git diff --name-only --diff-filter=ACMR HEAD 2>/dev/null | grep -E '\.(ts|tsx|js|jsx)$' || true)
  if [ -n "$changed" ]; then
    echo "$changed" | xargs timeout 30 npx eslint --no-error-on-unmatched-pattern 2>&1 | tail -20 >&2 || true
  fi
fi

exit 0
