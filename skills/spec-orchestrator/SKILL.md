# Skill: Spec Orchestrator

Orchestrates the full spec-driven development workflow by delegating to specialized subagents.

## When it activates

When the user wants to develop a new feature end-to-end, or says "spec workflow", "new feature", "build this feature".

## Full workflow

This skill coordinates 5 sequential phases. Most gates are structural (deterministic hooks). The only human-approval gate is after Phase 4 (plan approval) — and even that is skipped when `AUTO_MODE=1`.

```
┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────────┐  ┌──────────────┐
│ 1. CREATE  │─▶│ 2. AUDIT   │─▶│ 3. REVIEW  │─▶│ 4. PLAN      │─▶│ 5. IMPLEMENT │
│ Spec Writer│  │ Architect  │  │ Orchestrator│ │ Architect     │ │ Implementer  │
│            │  │            │  │            │  │ +Ultrathink   │ │              │
└─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └──────┬───────┘  └──────┬───────┘
      │               │               │                │                  │
   Gate 1         Gate 2          Gate 3           Gate 4              Gate 5
   structural     structural      traffic light    plan structural     hook: tests
   hook auto      hook auto       🔴 only blocks   hook auto +         + typecheck
                                                  HUMAN APPROVAL       + lint clean
                                                  (skipped if           (auto-runs
                                                  AUTO_MODE=1)          every phase
                                                                        if AUTO_MODE)
```

## How to use

### Full flow (recommended)

```
"I want to build the [feature-name] feature"
```

The orchestrator runs every phase, delegating to the right subagent. With `AUTO_MODE=1`, the entire pipeline runs end-to-end without stopping.

### Individual phases

```
"Create the spec for [feature-name]"        → delegates to Spec Writer
"Audit the spec for [feature-name]"         → delegates to Architect
"Review the spec for [feature-name]"        → runs review (auto-proceeds unless 🔴)
"Generate the plan for [feature-name]"      → delegates to Architect (with Ultrathink)
"Implement phase 2 of [feature-name]"       → delegates to Implementer
```

## Auto-mode contract

The workflow has only **two real human-decision points**:

1. **Plan approval (Gate 4)** — the design contract. Skipped in `AUTO_MODE=1`.
2. **STOP protocol** — the Implementer auto-stops on genuine ambiguity (existing code contradicts plan, missing dependency, broken existing test, ambiguous plan, etc.).

Everything else proceeds automatically. Structural hooks enforce shape; the traffic light only blocks on 🔴.

## Quality Gates between phases

### Gate 1: Spec created → ready for audit
- [ ] File exists at `.claude/specs/<feature>.md`.
- [ ] All required sections present (Context, What I want, Behavior, Acceptance criteria).
- [ ] At least 3 acceptance criteria.
- [ ] Open questions documented.
- Enforced by `validate-spec-structure.sh` (PostToolUse hook). **Not human-gated.**

### Gate 2: Audit complete → ready for review
- [ ] "Technical Analysis" section exists.
- [ ] Files to modify/create listed with exact paths.
- [ ] Project patterns documented.
- [ ] Risks detected and documented.
- Enforced by `validate-audit.sh`. **Not human-gated.**

### Gate 3: Review passed → ready for plan
- [ ] No 🔴 items unresolved.
- [ ] 🟡 assumptions documented.
- Auto-proceeds unless 🔴 is present. **Only 🔴 blocks.**

### Gate 4: Plan approved → ready for implementation
- [ ] Plan has clear phases with TDD (Red/Green/Refactor).
- [ ] Each phase has files with exact paths.
- [ ] Architecture decisions documented with alternatives.
- [ ] Rollback plan per phase.
- [ ] **Developer approval** (skipped in `AUTO_MODE=1`).

### Gate 5: Phase complete → ready for next phase
- [ ] All phase tests pass.
- [ ] Type check clean.
- [ ] Lint clean.
- [ ] No unreported deviations from the plan.
- Enforced by `validate-implementation.sh`. **Not human-gated.**
- In `AUTO_MODE=1`, the Implementer auto-proceeds to Phase N+1.

## Delegation protocol

When delegating to a subagent:

1. **Load the right agent** from `.claude/agents/`.
2. **Pass the necessary context**: feature name, current phase, gate state.
3. **Validate the output** against the structural hook before advancing.
4. **Report** to the developer after each phase (or only at the end in `AUTO_MODE=1`).

## Error handling

- If a structural hook fails → the agent fixes the issue and re-runs.
- If a subagent hits a STOP-protocol blocker → escalate to the developer immediately.
- If the developer wants to skip a phase → warn about the risks but allow it (document the decision in the spec).
- If the spec conflicts with existing code → prefer the existing code and update the spec.
