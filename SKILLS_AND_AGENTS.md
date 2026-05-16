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
| `code-reviewer` | Reviews staged changes for quality, conventions, and obvious issues |
| `dep-analyzer` | Audits `package.json` dependencies for risk, freshness, and security |
| `memory-bank-sync` | Keeps `memory-bank/` files in sync with project state after large changes |
| `quick-lint` | Fast lint pass before committing |
| `test-case-generator` | Drafts test cases from a feature description or diff |
| `ui-design` | Proposes UI patterns and visual designs given a feature brief |

See `agents/README.md` for full details on each.

---

## Installation

One-liner for end users:

```bash
curl -fsSL https://raw.githubusercontent.com/niegusss/claude/main/install.sh | bash
```

This clones the repo and copies `skills/`, `agents/`, `docs/`, `MANIFEST.md`, and `SECURITY.md` into `~/.claude/`. Existing files in `~/.claude/` are left in place.

After installing, **restart Claude Code** so it picks up the new skills.

---

## Typical project flow

```
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
