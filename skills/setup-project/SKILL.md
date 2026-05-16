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

## Interaction style

Use the `AskUserQuestion` tool for **every** user decision in this flow — not text prompts. This applies to:

- Yes/no choices (e.g. "do you have existing docs?")
- Picking from a fixed list (e.g. interview intensity, tech stack, visual style)
- Interview answers, where each question offers the same pattern of options:
  - `"I'll describe it"` — instructs the user to use the **Other** field below the options to type their detailed answer
  - `"I don't know yet"` — escape: saves the question to PM Questions, uses a sensible default, continues
  - (technical questions only) `"Consult with tech lead"` — saves to Tech Lead Consultation collection

Reserve plain text prompts only when the user must paste large content (e.g. a multi-page scope document) — `AskUserQuestion`'s Other field is fine for single-paragraph answers but not for novels.

## Flow

### 1. Detect state

`ls -la` once. Set `PROJECT_STATE`:

- `empty` — no `memory-bank/`, no `package.json`
- `has-memory-bank` — `memory-bank/` exists
- `has-package` — `package.json` exists but no `memory-bank/`

If `has-memory-bank` and no `$ARGUMENTS` → confirm with the user before overwriting. If they want to add an MCP, redirect them to use the shortcut.

### 2. Gather existing context (optional)

Use `AskUserQuestion`:

- **Question:** "Do you have existing project documentation to share — scope docs, pitch decks, meeting transcripts, briefs?"
- **Options:**
  - `"Yes — I'll paste them"` (desc: "Use the Other field below to paste content or give a file path")
  - `"No — let's start fresh"`

If the user pastes content (Other) or gives a path, read materials and extract: project name, problem statement, users, features, constraints. Use these to pre-fill interview answers in Step 3.

### 3. Project brief interview

#### 3.0 Interview intensity

`AskUserQuestion`:
- **Question:** "How thorough should I be with follow-up questions if your answers are too vague?"
- **Options:**
  - `"Standard — 3 follow-ups (Recommended)"`
  - `"Thorough — 5 follow-ups"`
  - `"Quick — no follow-ups, accept first answer"`

Store as `INTENSITY_LIMIT`.

#### 3.1 Project name & overview

`AskUserQuestion`:
- **Question:** "What is your project called and what does it do?"
- **Options:**
  - `"I'll describe it"` (desc: "Pick Other below and type project name + one-paragraph overview")
  - `"I don't know yet"` (desc: "Save to PM Questions")

#### 3.2 Problem statement

`AskUserQuestion`:
- **Question:** "What specific problem does this project solve, and what does the current workaround cost?"
- **Options:** same as 3.1 (`"I'll describe it"` / `"I don't know yet"`)

#### 3.3 Target users & flows

`AskUserQuestion`:
- **Question:** "Who will use this and what will they do — step by step?"
- **Options:** same as 3.1

#### 3.4 Detailed scope & features

`AskUserQuestion`:
- **Question:** "What features do you need? Group by subsystem: frontend, backend, DB, integrations."
- **Options:** same as 3.1

#### 3.5 Tech stack (TECHNICAL)

`AskUserQuestion`:
- **Question:** "What tech stack should we use?"
- **Options:**
  - `"Vite + React + TypeScript + Supabase (Recommended)"` → sets `STACK=vite`
  - `"Vite + React + Supabase + shadcn/ui"` → sets `STACK=vite`, `SHADCN_OPTED_IN=true`
  - `"Next.js 15+ (App Router) + Supabase"` → sets `STACK=next`
  - `"Consult with tech lead"` → save to Tech Lead Consultation, use Vite default
- (Other = user types custom stack → sets `STACK=custom`)

#### 3.6 Technical requirements (TECHNICAL)

`AskUserQuestion`:
- **Question:** "What technical requirements must the system meet — performance, security, compatibility, scale?"
- **Options:**
  - `"I'll describe them"` (Other)
  - `"Use sensible defaults"` (modern browsers, standard security, no special perf targets)
  - `"Consult with tech lead"`

#### 3.7 Restrictions & considerations (TECHNICAL)

`AskUserQuestion`:
- **Question:** "Any restrictions, deadlines, forbidden technologies, or must-have integrations?"
- **Options:**
  - `"I'll describe them"` (Other)
  - `"No specific constraints"`
  - `"Consult with tech lead"`

#### Follow-up handling

If the user's answer in **Other** is vague (under 2 sentences, no concrete examples or quantities), follow up with another `AskUserQuestion`:
- **Options:** `"I'll add more detail"` (Other) / `"That's all I have"`

Cap at `INTENSITY_LIMIT` follow-ups per topic.

### 4. Visual style proposal

Recommend one style based on project context (audience, tone, industry). Pick from:

| Style | Best for |
|---|---|
| Soft / Agency | Consumer apps, SaaS with emotional appeal |
| Minimalist | Editorial, productivity, content-heavy |
| Brutalist | Developer tools, creative/niche |
| Glassmorphism | Dashboards, fintech, AI, premium SaaS |
| Dark Mode / Midnight | Dev tools, B2B utilities, analytics, gaming |

Justify the recommendation in 2 sentences, then `AskUserQuestion`:
- **Question:** "Approve **[RECOMMENDED_STYLE]** as the visual direction?"
- **Options:**
  - `"Approve — [RECOMMENDED_STYLE]"`
  - `"Pick a different style"`
  - `"Skip — no visual style for now"`

If "Pick a different style", second `AskUserQuestion`:
- **Question:** "Which visual style?"
- **Options:** 4 of the 5 alternatives from the table above (not the one already declined)
- (Other = user types Brutalist if not in the four, or a custom direction)

If approved or picked, save to `memory-bank/productContext.md` under `## Visual Style`.

### 5. Git setup

Run `git status`. If not a repo, use `AskUserQuestion`:
- **Question:** "Do you have a remote repository URL for this project?"
- **Options:**
  - `"Yes — I'll provide the URL"` (desc: "Paste the URL in the Other field below")
  - `"No — initialize local-only for now"`

Then:
- **Yes** → `git init`, then `git remote add origin <URL_FROM_OTHER>`
- **No** → `git init` only. Inform the user they can connect a remote later with `git remote add origin <URL>` after their team lead / DevOps provisions the repo.

If already a repo, check `git remote -v`. If no remote, offer the same `AskUserQuestion`.

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

Skip if `$ARGUMENTS` already names a specific MCP server (jump straight to credentials + merge for that one).

Otherwise use `AskUserQuestion` with `multiSelect: true`:
- **Question:** "Which MCP servers would you like to configure?"
- **Options** (4 most common):
  - `"Supabase — database, auth, realtime"`
  - `"Context7 — live library docs"`
  - `"Netlify — deployment"`
  - `"ClickUp — task management"`
- (Other = user types `spec-workflow` or any other server name they want)

For each selected server:

1. Ask for credentials (URLs, tokens) with a plain text prompt — `AskUserQuestion` is not suitable for long, free-form tokens
2. Never write tokens to git-tracked files
3. Read the per-server template from `${CLAUDE_SKILL_DIR}/templates/mcp/<server>.json`
4. Adjust for `OS` (Windows wraps the command in `cmd /c`)
5. Merge into the project's `.mcp.json` (do not overwrite other servers)
6. Create `memory-bank/integrations/<server>.md` with status info

If the user selected Spec Workflow (or typed it via Other), after configuration use `AskUserQuestion`:
- **Question:** "Would you like a quick guide on how to use Spec Workflow?"
- **Options:** `"Yes — show me the guide"` / `"No — I'm familiar"`

If yes, point them at `docs/spec-workflow-guide.md` in this repo.

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
