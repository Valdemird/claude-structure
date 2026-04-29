---
name: spec-implement
description: Implements a phase of the plan via the Implementer subagent with strict TDD (Red/Green/Refactor). Auto-proceeds across phases when AUTO_MODE=1; stops only on STOP-protocol triggers. Triggers on "implement phase N", "run phase".
---

# Skill: Spec Implement

Implements a specific phase of the plan, delegating to the Implementer subagent with strict TDD.

## When it activates

When the user wants to implement a phase — "implement phase", "run phase", "implement", "phase 1", "phase 2".

In `AUTO_MODE=1`, this skill is also auto-invoked by `spec-plan` once the plan is generated, and runs every phase back-to-back without stopping.

## Instructions

### 1. Identify what to implement

From the developer input or the orchestrator handoff:
- **Feature name**: the spec name.
- **Phase number**: which phase to implement, or `all` to run every remaining phase sequentially.

### 2. Verify pre-requisites

Before implementing:
- The spec exists at `.claude/specs/<feature>.md`.
- The implementation plan is in the spec.
- For phase N > 1: the previous phase was completed (its tests pass).

### 3. Delegate to the Implementer

Use the subagent at `.claude/agents/implementer.md` to execute the phase.

The Implementer follows strictly:

```
1. RED — Write failing tests
   → Create the test files described in the plan.
   → Run: ${TEST_CMD} [file] → must FAIL.
   → If it passes without code → test is wrong, rewrite.

2. GREEN — Minimal implementation
   → Write only the code needed to pass.
   → Run: ${TEST_CMD} [file] → must PASS.
   → If it fails → iterate (do NOT change tests).

3. REFACTOR — Clean up without breaking
   → Improve names, reduce duplication.
   → Run: ${TEST_CMD} [file] → must KEEP passing.
```

### 4. Post-phase verification (Quality Gate 5)

The Implementer runs in order:

```bash
${TEST_CMD} [phase files]
${TYPECHECK_CMD}
${LINT_CMD} [modified files]
${FORMAT_CMD} [modified files]
${TEST_ALL_CMD}   # only when the phase touches multiple modules
```

The hook `validate-implementation.sh` enforces:

- [ ] Phase tests: all pass.
- [ ] Type check: clean.
- [ ] Lint: clean (post auto-fix).
- [ ] No unreported deviations from the plan.
- [ ] Post-phase report generated.

If the hook fails, the Implementer fixes the issue before continuing.

### 5. STOP protocol

The Implementer **stops and reports** if any of these happen — these are the only blocking conditions. They represent genuine ambiguity that requires a human decision:

- ⛔ Existing code contradicts the plan.
- ⛔ A required dependency is not in the plan.
- ⛔ An existing test breaks because of the changes.
- ⛔ More files are affected than listed.
- ⛔ An existing bug interferes with the implementation.
- ⛔ Plan ambiguity that allows multiple interpretations.

**Never improvise. Stopping > breaking something silently.**

### 6. Phase report

```markdown
## Phase [N] — Complete ✅

### Files created
- [path]: [description]

### Files modified
- [path]: [what changed]

### Tests
- [X] new, [Y] passing, [Z] failing
- Verifications: typecheck ✅ | lint ✅ | format ✅

### Decisions made
- [decision]: [reason]

### Plan deviations
- [none / description]
```

### 7. Auto-proceed between phases

```
If AUTO_MODE=1:
  Print the phase report.
  Immediately invoke the Implementer for Phase N+1.
  Continue until all phases are complete or a STOP-protocol trigger fires.

If AUTO_MODE is unset or 0 (default):
  Print the phase report.
  Ask: "Phase [N] complete. Review and green-light Phase [N+1], or adjust?"
  Wait for the developer's go-ahead.
```

The default behavior is interactive (one phase per turn) for first-time users. Set `AUTO_MODE=1` for fully autonomous multi-phase runs once you trust the workflow.
