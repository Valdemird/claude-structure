# claude-structure

A stack-agnostic [Claude Code](https://docs.claude.com/en/docs/claude-code) template that turns the chat into a disciplined, spec-driven development pipeline: **Spec Writer → Architect → Implementer**, plus auto-invoked skills for bug fixing, frontend design, security/architecture/performance audits, and a meta skill to create new skills.

Drop the `.claude/` folder into any project and you get:

- **3 specialized subagents** (`spec-writer`, `architect`, `implementer`) with clear roles and STOP protocols.
- **13 skills** that auto-invoke when their context fits, instead of you remembering slash commands.
- **4 deterministic quality-gate hooks** that enforce structure on specs, audits, plans, and implementations.
- **One real human-approval gate** (plan approval) — and `AUTO_MODE=1` skips even that for fully autonomous runs.
- **A workflow document** describing the end-to-end pipeline (`WORKFLOW.md`).

This repo is the result of running 80+ real sessions and keeping only what proved essential. Skill selection is backed by hard usage data — `bugfix`, `frontend-design`, and `skill-creator` are in there because they got used week after week, not because they sound nice.

---

## Quick start

### Option A — install as a Claude Code plugin (recommended)

```bash
# In Claude Code:
/plugin marketplace add Valdemird/claude-structure
/plugin install claude-structure@claude-structure
```

### Option B — copy the folder

```bash
git clone https://github.com/Valdemird/claude-structure.git
cp -r claude-structure/.claude /path/to/your/project/

cd /path/to/your/project
mv .claude/CLAUDE.md.template CLAUDE.md
$EDITOR CLAUDE.md   # describe your stack, conventions, commands

# Optional: export toolchain commands so the hooks & implementer use the right tools
export TEST_CMD="pytest"          # or "npx vitest run", "go test", etc.
export TYPECHECK_CMD="mypy"
export LINT_CMD="ruff check"
export FORMAT_CMD="black"

# Optional: turn on autonomous multi-phase implementation
export AUTO_MODE=1
```

Open Claude Code in your project and the skills activate automatically based on the conversation.

---

## What's inside

```
claude-structure/
├── .claude-plugin/
│   ├── plugin.json          ← Plugin manifest (auto-discovered)
│   └── marketplace.json     ← Marketplace entry for /plugin marketplace add
├── .claude/
│   ├── CLAUDE.md.template   ← Project memory, with placeholders
│   ├── settings.json        ← Permissions + hook wiring
│   ├── agents/              ← Specialized subagents
│   │   ├── architect.md
│   │   ├── implementer.md
│   │   └── spec-writer.md
│   ├── hooks/               ← Quality-gate bash scripts (deterministic)
│   │   ├── validate-spec-structure.sh
│   │   ├── validate-audit.sh
│   │   ├── validate-plan.sh
│   │   └── validate-implementation.sh
│   └── skills/              ← Auto-invoked workflows
│       ├── spec-create/
│       ├── spec-audit/
│       ├── spec-review/
│       ├── spec-plan/
│       ├── spec-implement/
│       ├── spec-orchestrator/
│       ├── architecture/
│       ├── security-audit/
│       ├── performance/
│       ├── mobile-audit/
│       ├── bugfix/
│       ├── frontend-design/
│       └── skill-creator/
├── .github/workflows/validate.yml  ← CI: shell, JSON, manifest, frontmatter
├── README.md
├── WORKFLOW.md
└── LICENSE
```

---

## When does each skill fire?

| Skill                | Fires when you say…                                                  |
| -------------------- | -------------------------------------------------------------------- |
| `spec-create`        | "I want a spec for X", "create a spec for Y"                         |
| `spec-audit`         | "audit the spec for X"                                               |
| `spec-review`        | "review the spec for X"                                              |
| `spec-plan`          | "generate the plan for X", "plan the implementation"                 |
| `spec-implement`     | "implement phase N of X" (or end-to-end in `AUTO_MODE=1`)            |
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

## AUTO_MODE: autonomous multi-phase runs

Set `AUTO_MODE=1` in your shell to make the workflow run end-to-end without stopping between phases:

| `AUTO_MODE` unset (default)                           | `AUTO_MODE=1`                                              |
| ----------------------------------------------------- | ---------------------------------------------------------- |
| Plan approval pauses for explicit go-ahead.            | Plan approval is informational; implementation auto-starts. |
| Implementer pauses between phases for green-light.     | Implementer runs every phase back-to-back.                  |
| Bugfix pauses after diagnosis.                         | Bugfix proceeds straight to test + fix.                     |
| Traffic light 🔴 still blocks.                         | Traffic light 🔴 still blocks.                              |
| STOP-protocol triggers still block.                    | STOP-protocol triggers still block.                         |

The genuinely blocking conditions remain in both modes:

- **🔴 in spec-review** — the spec is missing a decision the agents cannot make.
- **STOP protocol in the Implementer** — existing code contradicts the plan, an unlisted dependency is needed, an existing test breaks, or the plan is ambiguous.

Everything else is structural (bash hooks, deterministic) or informational. There are no "press enter to continue" prompts in `AUTO_MODE=1`.

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
1. spec-create   → Spec Writer drafts a spec        → Gate 1: structure (hook)
2. spec-audit    → Architect explores codebase      → Gate 2: technical analysis (hook)
3. spec-review   → Traffic light 🟢🟡🔴             → Gate 3: 🔴 blocks, 🟡/🟢 auto-proceed
4. spec-plan     → Architect plans with Ultrathink  → Gate 4: structure (hook) + HUMAN APPROVAL
5. spec-implement→ Implementer runs strict TDD      → Gate 5: typecheck + lint + tests (hook)
```

See [`WORKFLOW.md`](./WORKFLOW.md) for the full step-by-step guide with examples.

---

## How this compares to other Claude Code workflows

| Capability                                | this repo            | [cc-sdd](https://github.com/gotalab/cc-sdd) | [Pimzino/spec-workflow](https://github.com/Pimzino/claude-code-spec-workflow) | [wshobson/agents](https://github.com/wshobson/agents) | [VoltAgent/awesome-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) |
| ----------------------------------------- | -------------------- | ------------------------------------------- | ----------------------------------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Spec-driven workflow                      | ✅                   | ✅                                          | ✅                                                                            | partial                                               | ❌                                                                                        |
| Subagents with STOP protocol              | ✅                   | ✅                                          | partial                                                                       | ✅                                                    | ✅                                                                                        |
| Deterministic hooks (not LLM-judged)      | ✅                   | partial                                     | ❌                                                                            | partial                                               | ❌                                                                                        |
| Stack-agnostic (Python / Go / Rust / Node)| ✅ via env vars      | ✅                                          | ❌ (Node-leaning)                                                             | ✅                                                    | ✅                                                                                        |
| Autonomous multi-phase mode               | ✅ `AUTO_MODE=1`     | ✅ `/kiro-impl`                             | ❌                                                                            | partial                                               | ❌                                                                                        |
| Plugin install (`/plugin marketplace add`)| ✅                   | ✅                                          | ✅                                                                            | ✅                                                    | partial                                                                                   |
| CI validation of the template itself      | ✅                   | ✅                                          | partial                                                                       | partial                                               | ❌                                                                                        |
| Curated skill set                         | ✅ 13 (data-driven)  | ✅ ~10                                      | ✅ ~6                                                                         | ❌ 184 agents + 150 skills                            | ❌ 100+                                                                                   |
| Skill selection backed by usage data      | ✅ 81 sessions       | ❌                                          | ❌                                                                            | ❌                                                    | ❌                                                                                        |

**When to pick which:**

- **`claude-structure` (this repo)**: opinionated, curated, stack-agnostic, with a single human-approval gate by design. Good fit if you trust the workflow and want autonomous runs without ceremony.
- **`cc-sdd`**: similar philosophy, more elaborate phase routing (discovery / requirements / design / tasks). Better fit for larger teams that want explicit contract boundaries between roles.
- **`Pimzino/claude-code-spec-workflow`**: simpler, Node-leaning, great for solo Next.js / TypeScript projects.
- **`wshobson/agents`**: kitchen sink. Pick this if you want every conceivable subagent already written and don't mind pruning.
- **`VoltAgent/awesome-claude-code-subagents`**: a directory to browse, not a workflow. Use it to find agents to drop into a different setup.

---

## Why this exists

Claude Code's built-in `/plan` is great, but it is a single-step manual trigger. This template adds five things `/plan` doesn't give you:

1. **Persistent specs in `.claude/specs/`** — the source of truth for what a feature is, surviving across sessions.
2. **Deterministic quality gates** — bash hooks that fail fast when a spec / plan / implementation doesn't meet structural rules. The model can't "forget" them.
3. **Subagents with isolated context** — the Architect doesn't pollute the Implementer's context, and vice versa.
4. **Autonomous mode** — `AUTO_MODE=1` runs the whole pipeline end-to-end with one approval gate (the plan), or zero.
5. **Curated, data-driven skill set** — 13 skills selected after analyzing 81 real sessions. The ones that didn't earn their place are not here.

Together, those five solve the "the model went off the rails on a long task" problem better than any single feature.

---

## License

[MIT](./LICENSE) — use freely, attribution appreciated.
