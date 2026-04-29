#!/bin/bash
# Quality Gate 5: Validate implementation phase completion.
# Stack-agnostic: parameterize commands via env vars (with sensible Node.js defaults).
#
# Usage:
#   ./validate-implementation.sh [test-pattern]
#
# Override per-project (e.g. in CLAUDE.md or your shell):
#   TYPECHECK_CMD="mypy"           ./validate-implementation.sh
#   TEST_CMD="pytest"              ./validate-implementation.sh
#   LINT_CMD="ruff check"          ./validate-implementation.sh
#   FORMAT_CMD="black"             ./validate-implementation.sh
#
# Skip individual checks:
#   SKIP_TYPECHECK=1 SKIP_LINT=1 SKIP_TESTS=1 SKIP_FORMAT=1

TEST_PATTERN="${1:-}"
ERRORS=0

TYPECHECK_CMD="${TYPECHECK_CMD:-npx tsc --noEmit}"
LINT_CMD="${LINT_CMD:-npx eslint}"
TEST_CMD="${TEST_CMD:-npx vitest run}"
TEST_ALL_CMD="${TEST_ALL_CMD:-npm test}"
FORMAT_CMD="${FORMAT_CMD:-npx prettier --write}"

echo "🔍 Running post-implementation quality checks..."
echo ""

# 1. Type check
if [ "${SKIP_TYPECHECK:-0}" = "1" ]; then
  echo "━━━ Type check skipped (SKIP_TYPECHECK=1) ━━━"
else
  echo "━━━ Type Check ($TYPECHECK_CMD) ━━━"
  if eval "$TYPECHECK_CMD" 2>&1; then
    echo "✅ Type check: clean"
  else
    echo "❌ Type check: errors found"
    ERRORS=$((ERRORS + 1))
  fi
fi
echo ""

# 2. Lint
if [ "${SKIP_LINT:-0}" = "1" ]; then
  echo "━━━ Lint skipped (SKIP_LINT=1) ━━━"
elif [ -n "$TEST_PATTERN" ]; then
  echo "━━━ Lint ($LINT_CMD) ━━━"
  if eval "$LINT_CMD $TEST_PATTERN" 2>&1; then
    echo "✅ Lint: clean"
  else
    echo "❌ Lint: errors remain"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "⚠️  Lint: skipped (no file pattern provided)"
fi
echo ""

# 3. Tests
if [ "${SKIP_TESTS:-0}" = "1" ]; then
  echo "━━━ Tests skipped (SKIP_TESTS=1) ━━━"
else
  echo "━━━ Tests ━━━"
  if [ -n "$TEST_PATTERN" ]; then
    if eval "$TEST_CMD $TEST_PATTERN" 2>&1; then
      echo "✅ Tests: passing"
    else
      echo "❌ Tests: failures detected"
      ERRORS=$((ERRORS + 1))
    fi
  else
    if eval "$TEST_ALL_CMD" 2>&1; then
      echo "✅ Tests: passing"
    else
      echo "❌ Tests: failures detected"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi
echo ""

# 4. Format
if [ "${SKIP_FORMAT:-0}" = "1" ]; then
  echo "━━━ Format skipped (SKIP_FORMAT=1) ━━━"
elif [ -n "$TEST_PATTERN" ]; then
  echo "━━━ Format ($FORMAT_CMD) ━━━"
  eval "$FORMAT_CMD $TEST_PATTERN" 2>&1
  echo "✅ Format: applied"
else
  echo "⚠️  Format: skipped (no file pattern)"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -gt 0 ]; then
  echo "🔴 GATE 5 FAILED: $ERRORS checks failed"
  echo "Fix the issues before marking this phase as complete."
  exit 1
else
  echo "🟢 GATE 5 PASSED: all checks clean"
  echo "Phase is ready for developer review."
  exit 0
fi
