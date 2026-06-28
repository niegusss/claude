# Claude Code Skills

A curated set of Claude Code **skills**, **agents**, and a production-grade **security checklist** for modern web projects. Drop-in installable via one shell command, on both macOS/Linux and Windows.

---

## What's inside

- **Skills** (`skills/`) — auto-invoked Claude Code skills with structured directories (`SKILL.md` + optional `templates/`, `scripts/`, `examples/`).
  - `audit-brief` — audits an existing brief/scope (a file or a folder of docs) for completeness before building: missing info, missing screens, unclear flows, edge cases and their consequences, contradictions. Interviews you to fill gaps, then writes an audit report plus a corrected copy. Analysis only — never scaffolds. Invoked with a path: `/audit-brief docs/`.
  - `setup-project` — interview-driven project bootstrap: Memory Bank, Git, CLAUDE.md, prompt-reminder hook, MCP servers (Supabase, Context7, Spec Workflow, Netlify, ClickUp).
  - `initial-prompt` — scaffolds the first working page(s) after `setup-project`. Detects Vite + React or Next.js, bootstraps if needed, implements based on `projectbrief.md`.
  - `fix-bug` — diagnoses and fixes one specific bug: locates the suspect code, finds the root cause, reproduces it, proposes the smallest fix, applies it after confirmation, then verifies with tsc/eslint/build. Invoked with a description: `/fix-bug "login throws 500 on empty email"`.
- **Agents** (`agents/`) — 7 specialized subagents (`code-reviewer`, `quick-lint`, `dep-analyzer`, `test-case-generator`, `memory-bank-sync`, `adr-generator`, `security-scanner`).
- **Docs** (`docs/`) — long-form guides referenced from skills (e.g. Spec Workflow tutorial).
- **`SECURITY.md`** — 2189-line checklist (P0/P1/P2) for React + TypeScript + Supabase projects. 17 categories from secrets and RLS through CSP, CORS, rate limiting, file uploads, IDOR, and production debug hygiene.

---

## Install

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/niegusss/claude/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/niegusss/claude/main/install.ps1 | iex
```

Both installers clone this repo and copy `skills/`, `agents/`, `docs/`, `MANIFEST.md`, `SKILLS_AND_AGENTS.md`, and `SECURITY.md` into your Claude Code directory:

- macOS / Linux: `~/.claude/`
- Windows: `%USERPROFILE%\.claude\`

Existing files in the target are left in place — only the whitelist above is touched.

After installing, **restart Claude Code** so it picks up the new skills.

---

## Requirements

- `git` available in `PATH`
- Claude Code installed ([download](https://claude.ai/code))

---

## Quick start

After installing, in Claude Code. If you already have a brief or scope document, audit it first:

```
/audit-brief brief.md
```

Checks the brief for completeness, interviews you on the gaps, and writes a corrected copy — analysis only, it won't build anything. Then start the project:

```
/setup-project
```

Walks you through an interview, builds the Memory Bank, initializes Git, and configures MCP servers. Then:

```
/initial-prompt
```

Bootstraps the project (Vite + React or Next.js) and implements the first page from your project brief.

You can also let Claude auto-invoke a skill — say "set up a new project" and it will pick `setup-project` based on the skill description.

---

## Documentation

| File | For whom |
|------|----------|
| [`SKILLS_AND_AGENTS.md`](./SKILLS_AND_AGENTS.md) | End users — what's here, how it works, typical flow |
| [`MANIFEST.md`](./MANIFEST.md) | Skill authors — design spec, conventions, anti-patterns |
| [`SECURITY.md`](./SECURITY.md) | Every project — pre-deploy security checklist |
| [`agents/README.md`](./agents/README.md) | Agent details and invocation patterns |
| [`docs/spec-workflow-guide.md`](./docs/spec-workflow-guide.md) | Spec Workflow MCP usage guide |

---

## Project structure

```
.
├── README.md                   # this file
├── LICENSE                     # MIT
├── MANIFEST.md                 # design spec for skill authors
├── SKILLS_AND_AGENTS.md        # user-facing overview
├── SECURITY.md                 # production security checklist
├── install.sh                  # macOS / Linux installer
├── install.ps1                 # Windows installer
├── skills/                     # auto-invoked Claude Code skills
│   ├── audit-brief/
│   ├── setup-project/
│   ├── initial-prompt/
│   └── fix-bug/
├── agents/                     # specialized subagents
└── docs/                       # long-form guides
```

---

## License

MIT — see [`LICENSE`](./LICENSE). Free for commercial and personal use; keep the copyright notice when redistributing.
