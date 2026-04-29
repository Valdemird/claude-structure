---
name: spec-plan
description: Generates a phased TDD implementation plan with deep thinking (trade-offs, devil's advocate, blast radius, tech debt), delegating to the Architect subagent. The plan is the single human-approval contract gate (skipped under AUTO_MODE=1). Triggers on "generate the plan for X", "plan the implementation".
---

# Skill: Spec Plan (with Ultrathink)

Generates a phased implementation plan with TDD, delegating to the Architect subagent with extended thinking enabled.

## When it activates

When the user wants to plan the implementation of a spec — "plan", "generate plan", "how to implement".

## Instructions

### 1. Engage extended thinking (Ultrathink)

**IMPORTANT**: This skill requires deep thinking. Before producing the plan, think **very deeply** about:

#### Trade-offs analysis

- For every meaningful design decision, evaluate at least 2 alternatives.
- Document pros/cons of each.
- Justify the choice with evidence from the existing code.

#### Devil's Advocate

- Argue **against** your own proposal.
- What are you assuming that could be false?
- What changed since the spec was written that might invalidate it?
- What would a Senior reviewer say if they read this plan cold?

#### Risk analysis

- What could fail in each phase?
- What's the blast radius if something goes wrong?
- Is it reversible? How costly is the rollback?

#### Tech debt

- Are we creating tech debt?
- Is it acceptable (pragmatic) or problematic (structural)?
- Is there existing debt this feature makes worse?

### 2. Read the audited spec

Read `.claude/specs/<feature-name>.md` in full, including the Technical Analysis section.

### 3. Delegate to the Architect

Use the subagent at `.claude/agents/architect.md` to generate the plan.

Plan format:

```markdown
## Plan: [Feature Name]

### Trade-off analysis (Ultrathink)
| Decision | Option A | Option B | Chosen | Reason |
| -------- | -------- | -------- | ------ | ------ |

### Devil's Advocate
- [counter-argument and why we proceed anyway]

### Phase 1 — [Descriptive name]
**Goal:** what is working when this phase ends.
**Files:**
- create: [exact path]
- modify: [exact path]

**TDD — Red:**
- [ ] Test: [description + file] → expects failure ❌

**TDD — Green:**
- [ ] [code to write] → tests pass ✅

**TDD — Refactor:**
- [ ] [improvements] → tests still pass ✅

**Verification:** [how to validate]
**Rollback:** [how to undo]

### Phase N — ...

### Implementation decisions
- [decision + justification]

### Out of scope
- [what is NOT being built]

### Risks
| Risk | Probability | Impact | Mitigation |
| ---- | ----------- | ------ | ---------- |
```

### 4. Quality Gate — automatic structural validation

The hook `validate-plan.sh` enforces:

- [ ] Plan has at least 2 phases.
- [ ] Each phase has TDD (Red/Green/Refactor).
- [ ] Each phase has specific files with exact paths.
- [ ] Trade-offs table present with alternatives evaluated.
- [ ] Devil's Advocate section present and non-empty.
- [ ] Risks documented with mitigation.
- [ ] Rollback plan per phase.
- [ ] "Out of scope" section present.

If the hook fails, the Architect fixes it before continuing.

### 5. Output and the contract gate

This is the **single human-approval gate** in the workflow. The plan is the contract — once approved, the implementer runs autonomously through every phase.

```
If AUTO_MODE=1 (env var):
  Print the full plan.
  Print: "AUTO_MODE active — proceeding to Phase 1 implementation immediately. Interrupt to abort."
  Continue to spec-implement Phase 1.

If AUTO_MODE is unset or 0 (default):
  Print the full plan.
  Ask: "Approve this plan or adjust before Phase 1?"
  Wait for explicit approval before invoking spec-implement.
```

This is the only approval gate that remains by design. Every other gate is structural (deterministic hooks) or informational (traffic light). Once the plan is approved (or AUTO_MODE skips it), the implementer auto-runs every phase, only stopping for the STOP-protocol triggers.

## Rules

- Maximum 4–5 phases for medium features.
- Each phase verifiable independently.
- Strict TDD: tests BEFORE code.
- If something is ambiguous, document the assumption.
- The plan must be executable without further questions.
