# Skills and Agents

Quick reference for what's in this repo and how it gets used in Claude Code.

This document is for **end users**. If you want to contribute or write new skills, read `MANIFEST.md` instead — it's the design spec.

---

## What's here

```
skills/             Auto-invoked Claude Code skills
agents/             Specialized subagents
docs/               Long-form guides linked from skills
SECURITY.md         Production security checklist
MANIFEST.md         Design spec for skill authors
install.sh          One-line installer for end users
```

---

## How it works

Once installed (see below), Claude Code loads everything in `~/.claude/`:

- **Skills** are auto-invoked when their `description` matches the user's request. You can also call them explicitly with `/<skill-name>`.
- **Agents** are launched on demand by Claude (or via the `Agent` tool with `subagent_type: <name>`). They run in isolation and return a single message.

Skills and agents coexist. Skills handle workflows; agents handle focused, single-purpose tasks.

---

## Skills

Each skill is a directory under `skills/` containing a `SKILL.md` plus optional `templates/`, `scripts/`, and `examples/`.

| Skill | Purpose |
|-------|---------|
| `audit-brief` | Audit an existing brief/scope (a file or a folder of docs) for completeness before building: missing info, missing screens, unclear flows, edge cases and their consequences, contradictions. Interviews the user to fill gaps, then writes an audit report plus a corrected copy. Analysis only — never scaffolds. Invoked with a path: `/audit-brief docs/`. |
| `setup-project` | Bootstrap a new project: interview, Memory Bank, Git, CLAUDE.md, prompt-reminder hook, MCP servers (Supabase, Context7, Spec Workflow, Netlify, ClickUp). Also adds a single MCP to an existing setup via shortcut argument. |
| `initial-prompt` | Scaffold the first working page(s) after `setup-project`. Detects stack (Vite + React, Next.js, or custom) from `techContext.md`, bootstraps the project structure if needed, implements the first logical page based on the project brief. |

### Skill structure

```
skills/setup-project/
├── SKILL.md              # Frontmatter + flow instructions (the main file)
├── templates/            # Memory Bank, CLAUDE.md, MCP JSON, message templates
├── scripts/              # Prompt-reminder hook scripts (sh, bat)
└── examples/             # Reference brief (anchor for "what good looks like")
```

`SKILL.md` references resources via `${CLAUDE_SKILL_DIR}/templates/...`.

### Argument shortcuts (`setup-project` only)

```
/setup-project              # Full interactive setup
/setup-project mcp          # Skip interview, configure all MCPs interactively
/setup-project supabase     # Add only Supabase MCP, then exit
/setup-project context7
/setup-project spec-workflow
/setup-project netlify
/setup-project clickup
```

---

## Agents

Specialized subagents in `agents/`. Each is invoked on demand by Claude during a task — you typically don't call them by name yourself.

| Agent | Trigger |
|-------|---------|
| `adr-generator` | Generates Architecture Decision Records when a major design choice is made |
| `code-reviewer` | Reviews staged changes against KISS/SOLID/DRY/YAGNI |
| `dep-analyzer` | Audits `package.json` dependencies for security, bundle size, maintenance, license |
| `memory-bank-sync` | Detects drift between code and `memory-bank/`; auto-updates safe files |
| `quick-lint` | Fast TypeScript + secrets scan (under 5s) before committing |
| `security-scanner` | Scans the project against P0 items from `SECURITY.md` before production deploy |
| `test-case-generator` | Drafts test cases (happy / edge / error / accessibility) from a feature or diff |

See `agents/README.md` for full details on each.

---

## Installation

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/niegusss/claude/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/niegusss/claude/main/install.ps1 | iex
```

Both installers clone the repo and copy `skills/`, `agents/`, `docs/`, `MANIFEST.md`, `SKILLS_AND_AGENTS.md`, and `SECURITY.md` into `~/.claude/` (macOS / Linux) or `%USERPROFILE%\.claude\` (Windows). Existing files in the target directory are left in place.

Requirements: `git` available in PATH.

After installing, **restart Claude Code** so it picks up the new skills.

---

## Typical project flow

```
audit-brief          →  (optional) check an existing brief before setup; emits a corrected copy
       ↓
setup-project        →  Memory Bank, Git, CLAUDE.md, MCPs, prompt-reminder hook
       ↓
initial-prompt       →  Bootstrap project + implement first page(s)
       ↓
(manual coding, with skills + agents helping along the way)
       ↓
(planned future skills: setup-tests, commit, manual-test, handoff)
```

The skill list grows over time — see `MANIFEST.md` for what's planned.

---

## Memory Bank

Every project bootstrapped by `setup-project` gets a `memory-bank/` directory at its root:

```
memory-bank/
├── handbook.md         # Rules for working with Memory Bank (read first)
├── projectbrief.md     # Requirements, user flows, features
├── techContext.md      # Stack, setup commands, dev guidelines
├── productContext.md   # Why, vision, success metrics
├── systemPatterns.md   # Architecture, code conventions
├── activeContext.md    # Current focus, immediate next steps
├── progress.md         # Done, in progress, known issues
└── integrations/       # One file per MCP server configured
```

Claude reads these at the start of every session. After significant work, Claude updates `activeContext.md` and `progress.md`. The Memory Bank is the project's persistent memory between sessions.

---

## Where to learn more

- **End users:** this file
- **Project security:** `SECURITY.md`
- **Skill authors:** `MANIFEST.md`
- **Spec Workflow MCP guide:** `docs/spec-workflow-guide.md`
- **Per-skill details:** `skills/<name>/SKILL.md`
- **Per-agent details:** `agents/<name>.md`
