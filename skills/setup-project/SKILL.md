---
name: setup-project
description: |
  When the user starts a new project, asks to create a Memory Bank, or wants to set up
  a Claude Code workspace from scratch. Also handles adding an MCP server (Supabase,
  Context7, Spec Workflow, Netlify, ClickUp) to an existing setup via a single-argument
  shortcut. Conducts a structured interview, scaffolds memory-bank/, initializes Git,
  configures MCP, and sets up a prompt-reminder hook.
allowed-tools: Read, Write, Edit, Bash(npm *), Bash(npx *), Bash(git *), Bash(mkdir *), Bash(uname *), Bash(ls *), Bash(cat *), Bash(chmod *), Bash(cp *)
---

# setup-project

Bootstrap a new project with Memory Bank, Git, CLAUDE.md, prompt-reminder hook, and optional MCP servers.

## When to use

- A new project directory has no `memory-bank/` yet
- The user wants to add an MCP server to an existing setup (use argument shortcut)
- The user explicitly asks "set up Claude Code in this project"

Do not use if `memory-bank/` already exists AND no argument was given — ask whether to redo (destructive) or add a specific MCP server instead.

## Argument shortcuts (`$ARGUMENTS`)

| Argument | Behavior |
|----------|----------|
| _(empty)_ | Full interactive setup |
| `mcp` | Skip interview; configure all MCP servers interactively |
| `supabase` | Add only Supabase MCP, then exit |
| `context7` | Add only Context7 MCP, then exit |
| `spec-workflow` | Add only Spec Workflow MCP, then exit |
| `netlify` | Add only Netlify MCP, then exit |
| `clickup` | Add only ClickUp MCP, then exit |

When `$ARGUMENTS` matches a single MCP name, jump straight to **Step 9** for that server, merge into existing `.mcp.json`, and stop.

## Flow

### 1. Detect state

`ls -la` once. Set `PROJECT_STATE`:

- `empty` — no `memory-bank/`, no `package.json`
- `has-memory-bank` — `memory-bank/` exists
- `has-package` — `package.json` exists but no `memory-bank/`

If `has-memory-bank` and no `$ARGUMENTS` → confirm with the user before overwriting. If they want to add an MCP, redirect them to use the shortcut.

### 2. Gather existing context (optional)

Ask: "Do you have any existing project documentation — scope docs, pitch decks, meeting transcripts, briefs? Paste them or point to a path."

If yes, read materials and extract: project name, problem statement, users, features, constraints. Use these to pre-fill interview answers in Step 3.

### 3. Project brief interview

Ask for interview intensity first: **Standard (3 follow-ups)** / **Thorough (5)** / **Quick (1)**.

For every question include two escape options:
- `I don't know` → save to PM Questions collection, use sensible default, continue
- (technical questions only) `Consult with tech lead` → save to Tech Lead Consultation collection

Topics:
- 3.1 Project name & overview
- 3.2 Problem statement (push for concrete cost of inaction)
- 3.3 Target users & flows (demographics + step-by-step journeys)
- 3.4 Detailed scope & features (organized by subsystem: frontend, backend, DB, integrations)
- 3.5 Tech stack — three options:
  - **Vite + React + TypeScript + Supabase (recommended)** — sets `STACK=vite`
  - **Vite + React + Supabase + shadcn/ui** — sets `STACK=vite`, `SHADCN_OPTED_IN=true`
  - **Next.js 15+ (App Router) + Supabase** — sets `STACK=next`
  - **Custom** — user specifies; sets `STACK=custom`
- 3.6 Technical requirements (performance, security, compatibility, scale)
- 3.7 Restrictions & considerations (deadlines, forbidden tech, must-have integrations)

If response is vague (under 2 sentences, no specifics), ask up to the configured follow-up limit. An answer is too vague when it misses concrete examples, quantities, or "why".

### 4. Visual style proposal

Recommend one based on project context. Present a single choice, justified in 2 sentences, then accept / pick another / skip.

| Style | Best for |
|---|---|
| Soft / Agency | Consumer apps, SaaS with emotional appeal |
| Minimalist | Editorial, productivity, content-heavy |
| Brutalist | Developer tools, creative/niche |
| Glassmorphism | Dashboards, fintech, AI, premium SaaS |
| Dark Mode / Midnight | Dev tools, B2B utilities, analytics, gaming |

If chosen, save to `memory-bank/productContext.md` under `## Visual Style`.

### 5. Git setup

`git status`. If not a repo: ask whether the user has a remote URL.

- **Yes** → `git init`, then `git remote add origin <URL>`.
- **No** → `git init` only. Tell them to contact whoever provisions repos in their organization and connect with `git remote add origin <URL>` later.

If already a repo, check `git remote -v` and offer the same flow if no remote.

### 6. Detect OS

```bash
uname -s 2>/dev/null || echo "Windows"
```

Set `OS=mac-linux` or `OS=windows`. Used in Steps 7 and 9.

### 7. Create Memory Bank

`mkdir -p memory-bank memory-bank/integrations`. For each Memory Bank file, copy from `${CLAUDE_SKILL_DIR}/templates/memory-bank/<name>.md` and substitute interview answers into placeholders (`[PROJECT_NAME]`, `[PROBLEM]`, etc.).

Stack-aware templates:
- `STACK=vite` → use `techContext.vite-react.md`, `systemPatterns.vite-react.md`
- `STACK=next` → use `techContext.nextjs.md`, `systemPatterns.nextjs.md`
- `STACK=custom` → use `techContext.custom.md`, `systemPatterns.custom.md`

If `SHADCN_OPTED_IN=false`, strip the shadcn/ui section from the chosen `systemPatterns` and `techContext`.

### 8. Create CLAUDE.md and prompt-reminder hook

Copy `${CLAUDE_SKILL_DIR}/templates/CLAUDE.md` to project root. Substitute `[PROJECT_NAME]`.

Copy the prompt-reminder script based on `OS`:
- `OS=mac-linux` → `${CLAUDE_SKILL_DIR}/scripts/prompt-reminder.sh` → `scripts/prompt-reminder.sh`, then `chmod +x`
- `OS=windows` → `${CLAUDE_SKILL_DIR}/scripts/prompt-reminder.bat` → `scripts/prompt-reminder.bat`

Tell the user how to register it:
- mac-linux: `/hooks → UserPromptSubmit → New → bash scripts/prompt-reminder.sh → Project`
- windows: `/hooks → UserPromptSubmit → New → cmd /c scripts\prompt-reminder.bat → Project`

### 9. MCP configuration (interactive or shortcut)

Ask which MCP servers to add (skip if `$ARGUMENTS` already names one). For each selected server:

1. Ask for credentials (URLs, tokens) — never write tokens to git-tracked files
2. Read the per-server template from `${CLAUDE_SKILL_DIR}/templates/mcp/<server>.json`
3. Adjust for `OS` (Windows wraps the command in `cmd /c`)
4. Merge into the project's `.mcp.json` (do not overwrite other servers)
5. Create `memory-bank/integrations/<server>.md` with status info

Servers available: `supabase`, `context7`, `spec-workflow`, `netlify`, `clickup`.

For Spec Workflow, after configuration ask if they want a quick guide — if yes, point them at `docs/spec-workflow-guide.md` in this repo.

### 10. Verification

Walk through this checklist and report status:

- [ ] `memory-bank/` exists with 7 core files
- [ ] `projectbrief.md` has substantive content (over 100 lines or sections filled)
- [ ] `CLAUDE.md` exists
- [ ] `scripts/prompt-reminder.{sh,bat}` exists
- [ ] `.mcp.json` exists (if any MCP selected)
- [ ] `memory-bank/integrations/<name>.md` for each selected MCP
- [ ] Git initialized
- [ ] Tech Lead Consultation message generated (if any "Consult with tech lead" responses)
- [ ] PM Questions list displayed (if any "I don't know" responses)

### 11. Outputs

If any "Consult with tech lead" responses → render `${CLAUDE_SKILL_DIR}/templates/tech-lead-consultation.md` with collected questions.

If any "I don't know" responses → render `${CLAUDE_SKILL_DIR}/templates/pm-questions.md` with collected questions sorted by Critical / Important / Clarification.

## Output (summary)

- `memory-bank/` with 7 core files + `integrations/` folder
- `CLAUDE.md` at project root
- `scripts/prompt-reminder.{sh,bat}` plus hook instructions
- `.mcp.json` (if any MCP selected)
- Git initialized
- Optional: Tech Lead Consultation message, PM Questions list

## Next step

After this, the user typically runs the `initial-prompt` skill to scaffold the first working page based on the project brief.
