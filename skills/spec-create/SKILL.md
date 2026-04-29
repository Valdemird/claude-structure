---
name: spec-create
description: Creates an initial structured spec for a new feature, delegating to the Spec Writer subagent. Triggers on "create a spec for X", "spec for Y", "I want to build Z", or when the user describes a feature they want to design.
---

# Skill: Spec Create

Creates an initial structured spec for a new feature, delegating to the Spec Writer subagent.

## When it activates

When the user wants to create a new spec — e.g. "create a spec for X", "spec for Y", "I want to build Z".

## Instructions

### 1. Gather context

Read these files before drafting:

- `CLAUDE.md` — roadmap and current priorities.
- `.claude/specs/` — existing specs (for format consistency and to avoid duplicates).

### 2. Delegate to the Spec Writer

Use the subagent at `.claude/agents/spec-writer.md` to generate the spec.

Pass:
- **Feature name**: kebab-case feature name.
- **Description**: what the developer said they want.
- **Additional context**: relevant info from the roadmap or existing specs.

### 3. Quality Gate — automatic structural validation

The PostToolUse hook (`validate-spec-structure.sh`) runs automatically when the spec file is written. The structural checklist:

- [ ] File created at `.claude/specs/<feature-name>.md`.
- [ ] "Context" section present and non-empty.
- [ ] "What I want" section present and clear.
- [ ] "Expected behavior" section with happy path + edge cases.
- [ ] "Anti-behaviors" section present.
- [ ] "Acceptance criteria" with at least 3 checkboxes.
- [ ] "Open questions" section documented (may be empty).

If the hook reports a structural issue, the Spec Writer fixes it before moving on. **No human approval is required at this gate** — the structure is enforced deterministically.

### 4. Output

Produce:
1. The full generated spec.
2. The list of open questions detected.
3. A short next-step note: "Run `spec-audit` next, or answer open questions inline first."

**Do not explore the code yet. Just produce the spec from what you have.**

The workflow then proceeds automatically to `spec-audit` unless the developer interrupts.
