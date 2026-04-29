#!/bin/bash
# Quality Gate 2: Validate audit completeness
# Usage: ./validate-audit.sh <spec-file-path>

SPEC_FILE="$1"

if [ -z "$SPEC_FILE" ] || [ ! -f "$SPEC_FILE" ]; then
  echo "❌ Error: Spec file not found: $SPEC_FILE"
  exit 1
fi

ERRORS=0

# Check for technical analysis section
if ! grep -q "## Análisis Técnico" "$SPEC_FILE"; then
  echo "❌ MISSING: 'Análisis Técnico' section not found"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ FOUND: Análisis Técnico section"
fi

# Check for files to modify
if ! grep -q "### Archivos a modificar" "$SPEC_FILE"; then
  echo "❌ MISSING: 'Archivos a modificar' subsection"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ FOUND: Archivos a modificar"
fi

# Check for patterns
if ! grep -q "### Patrones del proyecto" "$SPEC_FILE"; then
  echo "❌ MISSING: 'Patrones del proyecto' subsection"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ FOUND: Patrones del proyecto"
fi

# Check for risks
if ! grep -q "### Riesgos" "$SPEC_FILE"; then
  echo "❌ MISSING: 'Riesgos' subsection"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ FOUND: Riesgos evaluados"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -gt 0 ]; then
  echo "🔴 GATE 2 FAILED: $ERRORS errors"
  exit 1
else
  echo "🟢 GATE 2 PASSED: Audit is complete"
  exit 0
fi
