#!/bin/bash
# Quality Gate 1: Validate spec structure after creation
# Usage: ./validate-spec-structure.sh <spec-file-path>

SPEC_FILE="$1"

if [ -z "$SPEC_FILE" ]; then
  echo "❌ Error: No spec file provided"
  exit 1
fi

if [ ! -f "$SPEC_FILE" ]; then
  echo "❌ Error: Spec file not found: $SPEC_FILE"
  exit 1
fi

ERRORS=0
WARNINGS=0

# Required sections
REQUIRED_SECTIONS=("## Contexto" "## Qué quiero" "## Comportamiento esperado" "## Lo que NO debe hacer" "## Criterios de aceptación")

for section in "${REQUIRED_SECTIONS[@]}"; do
  if ! grep -q "$section" "$SPEC_FILE"; then
    echo "❌ MISSING: Section '$section' not found"
    ERRORS=$((ERRORS + 1))
  else
    echo "✅ FOUND: $section"
  fi
done

# Check for acceptance criteria (at least 3 checkboxes)
CRITERIA_COUNT=$(grep -c "\- \[ \]" "$SPEC_FILE" 2>/dev/null || echo "0")
if [ "$CRITERIA_COUNT" -lt 3 ]; then
  echo "❌ INSUFFICIENT: Only $CRITERIA_COUNT acceptance criteria (minimum 3)"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ CRITERIA: $CRITERIA_COUNT acceptance criteria found"
fi

# Optional but recommended sections
OPTIONAL_SECTIONS=("## Preguntas abiertas" "## Restricciones conocidas" "## Edge cases")
for section in "${OPTIONAL_SECTIONS[@]}"; do
  if ! grep -q "$section" "$SPEC_FILE"; then
    echo "⚠️  RECOMMENDED: Section '$section' not found"
    WARNINGS=$((WARNINGS + 1))
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -gt 0 ]; then
  echo "🔴 GATE 1 FAILED: $ERRORS errors, $WARNINGS warnings"
  exit 1
else
  echo "🟢 GATE 1 PASSED: 0 errors, $WARNINGS warnings"
  exit 0
fi
