---
name: spec-review
description: Produces a traffic-light readiness report (🟢 ready, 🟡 proceed-with-assumption, 🔴 blocking) before moving to planning. Auto-proceeds on green/yellow; only red blocks. Triggers on "review spec", "is the spec ready?", "readiness check".
---

# Skill: Spec Review

Final spec readiness check, producing a traffic-light report before moving to planning.

## When it activates

When the user wants to review a spec before planning — "review spec", "is the spec ready?", "readiness check", "traffic light".

## Instructions

### 1. Read the full spec

Read `.claude/specs/<feature-name>.md` including the Technical Analysis section if present.

### 2. Show the spec

Present the spec contents to the developer.

### 3. Evaluate readiness — traffic light

For each dimension:

**🟢 Ready (green):** clearly defined, no ambiguity, with explicit criteria.

**🟡 Proceed with documented assumption (yellow):** ambiguous but reasonable to assume. Document the assumption: "Will assume X because Y".

**🔴 Blocking (red):** critical missing decision that cannot be assumed. Without it, the plan will be wrong.

### 4. Output

```markdown
## Readiness Traffic Light: [feature-name]

### 🟢 Ready
- [list of well-defined items]

### 🟡 Proceed with assumption
- [ambiguous item] → Assumption: [what we'll assume]

### 🔴 Blocking
- [missing decision]

### Verdict: [READY / READY-WITH-ASSUMPTIONS / BLOCKED]
```

### 5. Auto-proceed rules

- **Verdict = READY** → automatically continue to `spec-plan`. No human approval required.
- **Verdict = READY-WITH-ASSUMPTIONS** → in `AUTO_MODE=1`, automatically continue and document the assumptions in the plan. Otherwise show the assumptions and proceed unless the developer objects within the same turn.
- **Verdict = BLOCKED** → STOP. Surface the 🔴 items and ask the developer to resolve them. This is the only blocking case.

The 🔴 → STOP rule is the genuine contract: when the spec is missing a decision the agents cannot make, blocking is correct. Yellow assumptions are documented and proceed automatically.
