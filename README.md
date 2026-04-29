# claude-structure

A stack-agnostic [Claude Code](https://docs.claude.com/en/docs/claude-code) template that turns the chat into a disciplined, spec-driven development pipeline: **Spec Writer → Architect → Implementer**, plus auto-invoked skills for bug fixing, frontend design, security/architecture/performance audits, and a meta skill to create new skills.

Drop the `.claude/` folder into any project and you get:

- **3 specialized subagents** (`spec-writer`, `architect`, `implementer`) with clear roles and STOP protocols.
- **13 skills** that auto-invoke when their context fits, instead of you remembering slash commands.
- **5 quality gates** as bash hooks that block bad work from sneaking through.
- **A workflow document** describing the end-to-end pipeline (`WORKFLOW.md`).

This repo is the result of running 80+ real sessions and keeping only what proved essential. Skill selection is backed by hard usage data — `bugfix`, `frontend-design`, and `skill-creator` are in there because they got used week after week, not because they sound nice.

---

## Quick start

```bash
# 1. Clone this repo somewhere
git clone https://github.com/valdemird/claude-structure.git

# 2. Copy the .claude folder into your project
cp -r claude-structure/.claude /path/to/your/project/

# 3. Rename the CLAUDE.md template and fill it in
cd /path/to/your/project
mv .claude/CLAUDE.md.template CLAUDE.md
$EDITOR CLAUDE.md   # describe your stack, conventions, commands

# 4. (Optional) export toolchain commands so the hook & implementer use the right tools
export TEST_CMD="pytest"          # or "npx vitest run", "go test", etc.
export TYPECHECK_CMD="mypy"
export LINT_CMD="ruff check"
export FORMAT_CMD="black"
```

That's it. Open Claude Code in your project and the skills will activate automatically based on the conversation.

---

## What's inside

```
.claude/
├── CLAUDE.md.template     ← Project memory, with placeholders to fill in
├── settings.json          ← Permissions + Gate 1 hook wiring
├── agents/                ← Specialized subagents
│   ├── architect.md
│   ├── implementer.md
│   └── spec-writer.md
├── hooks/                 ← Quality-gate bash scripts (deterministic, not LLM-judged)
│   ├── validate-spec-structure.sh   ← Gate 1: spec structure
│   ├── validate-audit.sh            ← Gate 2: technical analysis
│   ├── validate-plan.sh             ← Gate 4: plan completeness
│   └── validate-implementation.sh   ← Gate 5: typecheck / lint / tests
└── skills/                ← Auto-invoked workflows
    ├── spec-create/       ← Create a spec → Gate 1
    ├── spec-audit/        ← Audit a spec → Gate 2
    ├── spec-review/       ← Readiness traffic light → Gate 3
    ├── spec-plan/         ← Plan with Ultrathink → Gate 4
    ├── spec-implement/    ← Implement a phase with TDD → Gate 5
    ├── spec-orchestrator/ ← End-to-end spec workflow
    ├── architecture/      ← Architecture review of a module / codebase
    ├── security-audit/    ← OWASP-aligned security review
    ├── performance/       ← Performance hot-paths review
    ├── mobile-audit/      ← Mobile UX audit for web apps
    ├── bugfix/            ← Disciplined bug fix with TDD
    ├── frontend-design/   ← Distinctive, production-grade UI
    └── skill-creator/     ← Meta: create / improve other skills
```

---

## When does each skill fire?

| Skill                | Fires when you say…                                                  |
| -------------------- | -------------------------------------------------------------------- |
| `spec-create`        | "I want a spec for X", "create a spec for Y"                         |
| `spec-audit`         | "audit the spec for X"                                               |
| `spec-review`        | "review the spec for X"                                              |
| `spec-plan`          | "generate the plan for X", "plan the implementation"                 |
| `spec-implement`     | "implement phase N of X"                                             |
| `spec-orchestrator`  | "take this idea end-to-end as a spec"                                |
| `architecture`       | "do an architecture review", "audit the structure of this module"    |
| `security-audit`     | "is this secure?", "check for XSS / SQLi / SSRF / auth issues"       |
| `performance`        | "audit performance", "find bottlenecks"                              |
| `mobile-audit`       | "audit the mobile experience", "this is broken on iOS Safari"        |
| `bugfix`             | "fix the bug where…", "X is broken / not working / regressed"        |
| `frontend-design`    | "build me a landing page", "design this component"                   |
| `skill-creator`      | "create a new skill for…", "improve the X skill"                     |

You don't need to memorize triggers — Claude Code picks them up from context. Skills auto-invoke; subagents run isolated; hooks enforce structure deterministically. That layering is the whole point.

---

## Toolchain (override per-project)

The Implementer agent and the Gate 5 hook run commands via env vars so this template works for any stack.

| Variable          | Default (Node.js)        | Python example     | Go example            |
| ----------------- | ------------------------ | ------------------ | --------------------- |
| `TEST_CMD`        | `npx vitest run`         | `pytest`           | `go test`             |
| `TEST_ALL_CMD`    | `npm test`               | `pytest`           | `go test ./...`       |
| `TYPECHECK_CMD`   | `npx tsc --noEmit`       | `mypy`             | `go vet ./...`        |
| `LINT_CMD`        | `npx eslint`             | `ruff check`       | `golangci-lint run`   |
| `FORMAT_CMD`      | `npx prettier --write`   | `black`            | `gofmt -w`            |
| `BUILD_CMD`       | `npm run build`          | —                  | `go build ./...`      |

You can also skip individual checks: `SKIP_TYPECHECK=1`, `SKIP_LINT=1`, `SKIP_TESTS=1`, `SKIP_FORMAT=1`.

---

## The workflow at a glance

```
1. spec-create   → Spec Writer drafts a spec        → Gate 1: structure
2. spec-audit    → Architect explores codebase      → Gate 2: technical analysis
3. spec-review   → Traffic light 🟢🟡🔴             → Gate 3: readiness
4. spec-plan     → Architect plans with Ultrathink  → Gate 4: trade-offs / phases / rollback
5. spec-implement→ Implementer runs strict TDD      → Gate 5: typecheck + lint + tests
```

See [`WORKFLOW.md`](./WORKFLOW.md) for the full step-by-step guide with examples.

---

## Why this exists

`/plan` (Claude Code's built-in plan mode) is great, but it is a single-step manual trigger. This template adds three things `/plan` doesn't give you:

1. **Persistent specs in `.claude/specs/`** — the source of truth for what a feature is, surviving across sessions.
2. **Deterministic quality gates** — bash hooks that fail fast when a spec / plan / implementation doesn't meet structural rules. The model can't "forget" them.
3. **Subagents with isolated context** — the Architect doesn't pollute the Implementer's context, and vice versa.

Together, those three solve the recurring "the model went off the rails on a long task" problem better than any single feature.

---

## License

[MIT](./LICENSE) — use freely, attribution appreciated.
