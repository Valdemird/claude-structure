# Skill: Bugfix

Disciplined workflow for diagnosing and fixing bugs with TDD. Eliminates the "fix → fail → re-fix" cycle by forcing deep analysis before writing code.

## When it activates

When the user reports a bug, says "fix", "broken", "not working", "regression", or describes incorrect behavior.

## Instructions

Toolchain commands are parameterized via environment variables. Defaults assume a Node.js + TypeScript project but you should override them for your stack (override defaults in `CLAUDE.md` or your shell):

| Variable          | Default                  |
| ----------------- | ------------------------ |
| `${TEST_CMD}`     | `npx vitest run`         |
| `${TEST_ALL_CMD}` | `npm test`               |
| `${TYPECHECK_CMD}`| `npx tsc --noEmit`       |
| `${LINT_CMD}`     | `npx eslint`             |
| `${FORMAT_CMD}`   | `npx prettier --write`   |

### Phase 1: Reproduce and Diagnose

**Do NOT write any code yet.**

1. **Understand the bug**: Read the user's report. If ambiguous, ask before continuing.

2. **Locate the relevant code**: Use Grep / Glob / Read to find the files involved. Do not assume — read the real code.

3. **Trace the full chain**: Follow the data flow from entry point to failure:
   - **UI/CSS bugs**: Trace the constraint chain from the broken element up to the viewport root. List `display`, `position`, `height`, `overflow`, `flex` for every ancestor.
   - **Logic bugs**: Trace the data flow step by step. Read the actual functions, do not assume they do what their name suggests.
   - **Data bugs**: Check the schema, the queries, and the real data in the database.

4. **Present the diagnosis**:

```markdown
## Diagnosis

**Symptom**: [what the user sees]
**Root cause**: [the real cause, not the symptom]
**Why it happens**: [the causal chain]
**Affected files**: [list with paths]

### Evidence
- [line X of file Y does Z, but should do W]
```

**Wait for developer confirmation before moving to Phase 2.**

### Phase 2: Write a failing test (RED)

1. Write a test that **fails** reproducing the exact bug:

```bash
${TEST_CMD} [test-file]
```

2. The test must fail for the right reason (the bug), not a setup error.

3. If a unit test is not possible (visual / CSS bug), document the manual reproduction steps instead.

### Phase 3: Minimal fix (GREEN)

1. Implement the **minimal** fix that makes the test pass.
2. Do not refactor, do not "improve" adjacent code, do not add features.
3. Run the test: it must pass.

```bash
${TEST_CMD} [test-file]
```

### Phase 4: Full verification

Run in order:

```bash
# Full test suite
${TEST_ALL_CMD}

# Type check
${TYPECHECK_CMD}

# Lint
${LINT_CMD} [modified files]

# Format
${FORMAT_CMD} [modified files]
```

If anything fails, fix it before reporting.

### Phase 5: Report

```markdown
## Bug Fix Complete

**Bug**: [short description]
**Root cause**: [what caused it]
**Fix**: [what changed and why]

### Modified files
- `path/file.ts`: [what changed]

### Tests
- [N] new, [M] total passing
- typecheck: OK | lint: OK | format: OK

### Regressions verified
- [list of existing tests that still pass]
```

## Critical rules

- **If the first attempt fails**: Do NOT repeat the same approach. Stop, re-analyze the root cause, and explain what changed in your diagnosis.
- **Fix root cause, not symptom**: Avoid bandaids. Remove dead code instead of guarding around it. If a feature flag is making the bug appear, evaluate whether the flag should be removed.
- **CSS / layout bugs**: Trace the full constraint chain (see Phase 1). Do not add `overflow-hidden` or `max-height` to mask a missing height constraint on an ancestor.
- **Never change a test so it passes** — change the code.
- **Commits**: use Conventional Commits format (`fix(scope): description`).
