# Development Workflow: Spec-Driven with Subagents

Step-by-step guide to building any feature using a workflow optimized for subagents, quality gates, and extended thinking.

---

## Visual Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         SPEC-DRIVEN DEVELOPMENT WORKFLOW                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  YOU (Developer)         CLAUDE (Subagents)           QUALITY GATES          │
│  ──────────────          ──────────────────           ──────────────          │
│                                                                              │
│  1. Describe the idea ─▶ Spec Writer creates spec ─▶ Gate 1: Structure ✓    │
│     ↕ feedback                                                               │
│  2. Answer open questions                                                    │
│                                                                              │
│  3. "Audit the spec" ──▶ Architect explores code ───▶ Gate 2: Analysis ✓    │
│     ↕ feedback            and enriches spec                                  │
│                                                                              │
│  4. "Review" ──────────▶ Traffic light 🟢🟡🔴 ──────▶ Gate 3: Readiness ✓  │
│     ↕ approve / adjust                                                       │
│                                                                              │
│  5. "Generate plan" ───▶ Architect + ULTRATHINK ────▶ Gate 4: Plan ✓        │
│     ↕ approve plan        (trade-offs, devil's                               │
│                            advocate, risks)                                  │
│                                                                              │
│  6. "Implement P1" ────▶ Implementer (TDD) ─────────▶ Gate 5: Tests ✓       │
│     ↕ review code         Red → Green → Refactor      typecheck ✓ lint ✓    │
│                                                                              │
│  7. "Implement P2" ────▶ Implementer (TDD) ─────────▶ Gate 5: Tests ✓       │
│     ↕ review code                                                            │
│                                                                              │
│  8. ... up to Phase N                                                        │
│                                                                              │
│  9. Feature DONE ✅                                                           │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Create the Spec

### What you say

```
I want a spec for [feature-name]: [brief description of what you want]
```

### Example

```
I want a spec for [feature-name]: short paragraph describing the goal,
who it's for, and the rough behavior.
```

### What happens internally

1. The **Skill: spec-create** triggers.
2. It delegates to the **Subagent: Spec Writer**.
3. It reads `CLAUDE.md` and existing specs for context.
4. It generates the spec at `.claude/specs/[feature-name].md`.
5. **Gate 1** validates structure automatically.
6. It shows you the spec + open questions.

### What you do next

- Read the open questions.
- Answer them in chat or edit the spec directly.
- When you're satisfied, move to step 2.

### Quality Gate 1 — Checklist

- [ ] File exists at `.claude/specs/<feature>.md`.
- [ ] Sections: Context, What I want, Behavior, Anti-behaviors, Acceptance criteria.
- [ ] At least 3 acceptance criteria.
- [ ] Open questions documented.

---

## Step 2: Audit the Spec

### What you say

```
Audit the spec for [feature-name]
```

### What happens internally

1. The **Skill: spec-audit** triggers.
2. It delegates to the **Subagent: Architect**.
3. The Architect explores the WHOLE project:
   - Folder structure and modules.
   - Architectural patterns in use.
   - Naming conventions.
   - Existing tests and how they are organized.
   - Relevant dependencies.
   - Similar files (to copy the pattern).
4. It enriches the spec with a "Technical Analysis" section.
5. **Gate 2** validates completeness.

### What you do next

- Read the Architect's findings.
- Resolve any risks or conflicts that need your input.
- Answer the technical questions that emerged.

### Quality Gate 2 — Checklist

- [ ] "Technical Analysis" section present.
- [ ] Files to modify / create with exact paths.
- [ ] Project patterns documented.
- [ ] Risks evaluated.

---

## Step 3: Review the Spec

### What you say

```
Review the spec for [feature-name]
```

### What happens internally

1. The **Skill: spec-review** triggers.
2. It reads the full spec (including the technical analysis).
3. It produces a **readiness traffic light**:
   - 🟢 **Green**: well defined, no ambiguity.
   - 🟡 **Yellow**: ambiguous but assumable (documents the assumption).
   - 🔴 **Red**: blocking, needs your decision.

### What you do next

- All 🟢 → "proceed to plan".
- 🟡 → review the assumptions, accept or correct.
- 🔴 → resolve before continuing.

### Quality Gate 3 — Checklist

- [ ] No unresolved 🔴 items.
- [ ] 🟡 assumptions documented and accepted.
- [ ] Developer confirms "proceed".

---

## Step 4: Generate the Plan (with Ultrathink)

### What you say

```
Generate the plan for [feature-name]
```

### What happens internally — WHERE ULTRATHINK SHINES

1. The **Skill: spec-plan** triggers.
2. It delegates to the **Subagent: Architect** with extended thinking on.
3. The Architect thinks DEEPLY before planning:

   **Trade-offs**: For every decision, evaluate at least 2 alternatives with pros/cons.

   **Devil's Advocate**: Argue AGAINST your own proposal. What could fail? What assumption could be wrong?

   **Blast Radius**: If a phase goes wrong, what breaks? Is it reversible?

   **Tech Debt**: Are we creating debt? Acceptable or problematic?

4. It produces a phased plan with TDD (Red / Green / Refactor).
5. **Gate 4** validates plan completeness.

### What you do next

- Read the trade-offs table → do you agree with the choices?
- Read the devil's advocate → any unacceptable risks?
- Read each phase → does the scope and order make sense?
- Approve: "I approve the plan, start Phase 1".
- Or adjust: "Swap Phase 2 and Phase 3 because…".

### Quality Gate 4 — Checklist

- [ ] At least 2 phases defined.
- [ ] Every phase has TDD (Red / Green / Refactor).
- [ ] Trade-offs documented with alternatives.
- [ ] Devil's advocate present.
- [ ] Rollback plan per phase.
- [ ] "Out of scope" defined.
- [ ] Developer approves explicitly.

---

## Step 5: Implement Phase by Phase

### What you say

```
Implement phase 1 of [feature-name]
```

### What happens internally

1. The **Skill: spec-implement** triggers.
2. It delegates to the **Subagent: Implementer**.
3. It follows strict TDD:

```
RED      → Write tests that FAIL (code does not exist yet).
GREEN    → Write the MINIMUM code to make them pass.
REFACTOR → Clean up without breaking tests.
```

4. After the phase, it runs verifications:
   - `${TEST_CMD}` → tests pass.
   - `${TYPECHECK_CMD}` → no type errors.
   - `${LINT_CMD}` → lint clean.
   - `${FORMAT_CMD}` → formatting consistent.

5. **Gate 5** validates everything automatically.

### What you do next

- Read the phase report.
- Review the code (optional but recommended).
- If OK: "green light, implement Phase 2".
- If not: "adjust [X] before continuing".

### Implementer STOP protocol

The Implementer will automatically STOP if it finds:

- ⛔ Existing code contradicts the plan.
- ⛔ Needs a dependency that's not in the plan.
- ⛔ An existing test breaks.
- ⛔ More files affected than expected.
- ⛔ An existing bug that affects implementation.

**This is good.** It means something unexpected happened and you need to decide.

### Quality Gate 5 — Checklist (per phase)

- [ ] Phase tests: all pass.
- [ ] Type check: no errors.
- [ ] Lint: clean (post auto-fix).
- [ ] No unreported deviations.
- [ ] Developer gives green light.

---

## Quick Command Summary

| Step | You say                                  | Typical duration   |
| ---- | ---------------------------------------- | ------------------ |
| 1    | "Create spec for [feature]: [desc]"      | 5 min              |
| 2    | "Audit spec for [feature]"               | 10–15 min          |
| 3    | "Review spec for [feature]"              | 5 min              |
| 4    | "Generate plan for [feature]"            | 10–15 min          |
| 5    | "Implement phase [N] of [feature]"       | 15–45 min / phase  |

**Typical total per feature**: 1–3 hours (depending on complexity).

---

## Tips for Maximum Effectiveness

### Before starting

- Make sure your idea is in the roadmap in `CLAUDE.md`.
- If there are dependencies on other features, mention them in the spec.

### During the process

- **Don't skip steps.** Time "saved" by skipping audit or review is paid 3× in corrections.
- **Answer the open questions.** A spec with unresolved questions produces a mediocre plan.
- **Review the plan's trade-offs.** The Architect might pick something you don't love — say so before implementing.

### About Ultrathink

- The plan is better when the spec is clearer → invest in steps 1–3.
- If a plan feels superficial, say: "Think more deeply about the trade-offs of Phase 2".
- You can ask: "Play devil's advocate specifically on [decision X]".

### About TDD

- If a test fails after a refactor → the refactor broke something, revert it.
- If a test passes without code → the test is wrong, rewrite it.
- Never change a test so it passes → change the code.

### About Quality Gates

- The gates protect you, they don't block you.
- If a gate fails, read its output — it tells you exactly what's missing.
- You can run a gate manually: `bash .claude/hooks/validate-spec-structure.sh .claude/specs/[feature].md`.

---

## File Structure

This is the layout in the **plugin source repository** (which is also what you copy when not using the plugin install path):

```
claude-structure/                    # plugin root
├── .claude-plugin/
│   ├── plugin.json                  # plugin manifest
│   └── marketplace.json             # marketplace entry
├── agents/                          # auto-discovered subagents
│   ├── spec-writer.md               # Technical PM → creates specs
│   ├── architect.md                 # Staff Engineer → audits + plans
│   └── implementer.md               # Senior Dev → implements with TDD
│
├── skills/                          # auto-discovered skills
│   ├── spec-orchestrator/SKILL.md   # End-to-end spec workflow
│   ├── spec-create/SKILL.md         # Create spec → Gate 1
│   ├── spec-audit/SKILL.md          # Audit spec → Gate 2
│   ├── spec-review/SKILL.md         # Review + traffic light → Gate 3
│   ├── spec-plan/SKILL.md           # Plan + Ultrathink → Gate 4
│   ├── spec-implement/SKILL.md      # Implement phase → Gate 5
│   ├── architecture/SKILL.md
│   ├── security-audit/SKILL.md
│   ├── performance/SKILL.md
│   ├── mobile-audit/SKILL.md
│   ├── bugfix/SKILL.md
│   ├── frontend-design/SKILL.md
│   └── skill-creator/SKILL.md
│
├── hooks/                           # plugin hook config + scripts
│   ├── hooks.json                   # plugin wiring (uses ${CLAUDE_PLUGIN_ROOT})
│   ├── validate-spec-structure.sh   # Gate 1
│   ├── validate-audit.sh            # Gate 2
│   ├── validate-plan.sh             # Gate 4
│   └── validate-implementation.sh   # Gate 5
│
└── templates/                       # for copy-paste users only
    ├── CLAUDE.md.template           # rename to CLAUDE.md in your project root
    └── settings.json                # copy to <your-project>/.claude/settings.json
```

When you **install this as a plugin**, Claude Code auto-discovers everything from the plugin root — you don't need to do anything beyond `/plugin install claude-structure@claude-structure`.

When you **copy-paste**, you bring `agents/`, `skills/`, `hooks/` into your project's `.claude/`, and `templates/` provides starter `CLAUDE.md` and `settings.json` files for you to fill in.

In both cases the spec output lives in your project at `.claude/specs/<feature>.md`.

---

## End-to-End Example

```
You: I want a spec for [feature-name]: [brief description of the feature].

Claude: [Spec Writer generates spec, Gate 1 passes]
        "Spec created. Open questions:
         1. [open question 1]
         2. [open question 2]"

You: [answers to the questions]

Claude: [Updates spec with your answers]

You: Audit the spec for [feature-name]

Claude: [Architect explores the project, enriches spec, Gate 2 passes]
        "Findings: [technical analysis]
         Risks: [risk list]
         Question: [decision the developer must make]"

You: [your decision]

You: Review the spec for [feature-name]

Claude: "Traffic light:
         🟢 [things that are clear]
         🟡 [things assumed]
         Verdict: READY WITH ASSUMPTIONS"

You: I accept the assumption. Generate the plan.

Claude: [Architect + Ultrathink generates plan]
        "Trade-offs: [table]
         Devil's Advocate: [counter-argument]
         Phase 1: [name]
         Phase 2: [name]
         Phase 3: [name]"

You: I approve. Implement phase 1.

Claude: [Implementer runs TDD]
        "RED: failing test ❌
         GREEN: implementation → passes ✅
         REFACTOR: cleanup → still passes ✅
         Gate 5: typecheck ✅ | lint ✅ | tests ✅"

You: Green light, implement phase 2.

... [continues until the last phase]
```
