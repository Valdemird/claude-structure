#!/bin/bash
# Quality Gate 4: Validate plan completeness
# Usage: ./validate-plan.sh <spec-file-path>

SPEC_FILE="$1"

if [ -z "$SPEC_FILE" ] || [ ! -f "$SPEC_FILE" ]; then
  echo "❌ Error: Spec file not found: $SPEC_FILE"
  exit 1
fi

ERRORS=0
WARNINGS=0

# Check for plan section
if ! grep -q "## Plan:" "$SPEC_FILE"; then
  echo "❌ MISSING: Plan section not found"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ FOUND: Plan section"
fi

# Check for phases (at least 2)
PHASE_COUNT=$(grep -c "### Fase [0-9]" "$SPEC_FILE" 2>/dev/null || echo "0")
if [ "$PHASE_COUNT" -lt 2 ]; then
  echo "❌ INSUFFICIENT: Only $PHASE_COUNT phases (minimum 2)"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ PHASES: $PHASE_COUNT phases found"
fi

# Check for TDD markers
if ! grep -q "TDD" "$SPEC_FILE"; then
  echo "❌ MISSING: No TDD markers found in plan"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ FOUND: TDD methodology present"
fi

# Check for trade-offs (Ultrathink output)
if ! grep -q -i "trade-off\|tradeoff\|alternativa" "$SPEC_FILE"; then
  echo "⚠️  RECOMMENDED: No trade-off analysis found (Ultrathink may not have run)"
  WARNINGS=$((WARNINGS + 1))
else
  echo "✅ FOUND: Trade-off analysis present"
fi

# Check for devil's advocate
if ! grep -q -i "devil.*advocate\|argumento.*contra" "$SPEC_FILE"; then
  echo "⚠️  RECOMMENDED: No devil's advocate section found"
  WARNINGS=$((WARNINGS + 1))
else
  echo "✅ FOUND: Devil's advocate analysis"
fi

# Check for rollback plans
if ! grep -q -i "rollback\|revert\|deshacer" "$SPEC_FILE"; then
  echo "⚠️  RECOMMENDED: No rollback plans found"
  WARNINGS=$((WARNINGS + 1))
else
  echo "✅ FOUND: Rollback plans present"
fi

# Check for out of scope
if ! grep -q "Fuera del scope\|Out of scope" "$SPEC_FILE"; then
  echo "⚠️  RECOMMENDED: No 'Fuera del scope' section"
  WARNINGS=$((WARNINGS + 1))
else
  echo "✅ FOUND: Scope boundaries defined"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -gt 0 ]; then
  echo "🔴 GATE 4 FAILED: $ERRORS errors, $WARNINGS warnings"
  exit 1
else
  echo "🟢 GATE 4 PASSED: $WARNINGS warnings (non-blocking)"
  exit 0
fi
