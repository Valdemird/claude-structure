# Skill: Spec Audit

Audits a spec against the real codebase, delegating exploration to the Architect subagent.

## When it activates

When the user wants to audit a spec — e.g. "audit the spec for X", "review the spec technically", "check the spec against the code".

## Instructions

### 1. Verify the spec exists

Read `.claude/specs/<feature-name>.md`. If it doesn't exist, suggest running `spec-create` first.

### 2. Delegate to the Architect

Use the subagent at `.claude/agents/architect.md` for the technical audit.

The Architect must:

- Read the full spec.
- Explore the project deeply (without writing any code).
- Analyze: structure, patterns, conventions, tests, dependencies.
- Find files similar to what we want to build.

### 3. The Architect enriches the spec

Append a `## Technical Analysis` section:

```markdown
---

## Technical Analysis

### Files to modify
| File | Reason |
| ---- | ------ |

### New files to create
| File | Content |
| ---- | ------- |

### Project patterns to respect
-

### Existing dependencies to reuse
-

### Detected risks or conflicts
-

### Additional edge cases discovered in the code
-

### Open questions before implementing
-
```

### 4. Quality Gate — automatic structural validation

The hook `validate-audit.sh` validates that the analysis section exists and is populated:

- [ ] "Technical Analysis" section present.
- [ ] At least 1 file to modify listed with exact path.
- [ ] Project patterns documented (minimum 2).
- [ ] Risks evaluated (may be "none detected" for simple features).
- [ ] Edge cases reviewed.

If the hook reports an issue, the Architect fixes it. **No human approval needed at this gate.**

### 5. Output

Produce:
1. Summary of findings.
2. Any gaps or ambiguities still in the spec.
3. Anything in the code that complicates the implementation.
4. Open questions that should be answered before planning.

The workflow proceeds automatically to `spec-review` next.

**Do not write code. Only analyze and enrich the spec.**
