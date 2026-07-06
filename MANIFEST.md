# Skills v2 — Manifest

A clean set of the most important Claude Code helpers as **proper Claude Code Skills** (auto-invoked, structured directories), designed for public distribution via `install.sh`. This replaces an earlier slash-commands–only setup that was retired.

---

## Why skills (not slash commands)

Claude Code supports two patterns: slash commands (`.claude/commands/<name>.md`) and skills (`.claude/skills/<name>/SKILL.md`). Skills are strictly more powerful and we use them exclusively here:

| | Slash command | Skill |
|---|---|---|
| Shape | Single markdown file | Directory with `SKILL.md` + optional resources |
| Invocation | Explicit only: user types `/<name>` | Auto-invoked when context matches `description`; explicit also works |
| Frontmatter | None | YAML (`description` is the trigger) |
| Resources | Inline only | `templates/`, `examples/`, `scripts/` referenced via `${CLAUDE_SKILL_DIR}` |
| Tool restrictions | No | `allowed-tools` field for fine-grained control |

If a use case truly needs explicit-only invocation, the skill can set `disable-model-invocation: true`.

---

## Purpose

The previous slash-commands setup grew organically: files were 600–1700 lines, mixed languages, duplicated context, contradicted each other across helpers, and never used Claude Code's native skill features. This setup restarts from minimal versions, packaged as actual skills, with a shared set of conventions.

This manifest is the source of truth. Every new skill must conform to it. If a rule needs to bend, the manifest is updated first.

This manifest defines the required structure; the quality bar and reasoning method behind it live in `docs/fable-skill-authoring.md` and `docs/fable-mindset.md`.

---

## Current skills

1. **`audit-brief`** — audit an existing brief/scope (file or folder) for completeness; report + corrected copy, analysis only
2. **`setup-project`** — interview-driven project bootstrap, Memory Bank creation, MCP setup
3. **`initial-prompt`** — first implementation after setup
4. **`fix-bug`** — targeted single-bug debugging: locate → root cause → reproduce → propose-and-confirm fix → verify → Memory Bank update

## Planned (in likely order)

1. `setup-tests` — test infrastructure (Vitest)
2. `commit` — code review + commit + memory-bank update
3. `manual-test` — QA verification flow
4. `handoff` — project handover docs

Helper skills from the legacy setup (`teacher`, `standup`, `pm`, `hack`, `workshop`, etc.) are out of scope unless concrete need emerges.

---

## Foundation — Memory Bank

The 7-file Memory Bank stays **unchanged**:

```
memory-bank/
├── handbook.md         # Development standards
├── projectbrief.md     # Requirements, user flows, features
├── techContext.md      # Stack, setup commands, conventions
├── productContext.md   # Why, user vision, success metrics
├── systemPatterns.md   # Architecture, code patterns
├── activeContext.md    # Current work focus
└── progress.md         # Done, in progress, known issues
```

Every skill that works inside a bootstrapped project reads Memory Bank at session start and updates `activeContext.md` / `progress.md` after significant work. Skills that run before `setup-project` (e.g. `audit-brief`) read `memory-bank/` only if it exists and never write to it. No other exceptions, no alternatives.

---

## Directory layout

```
skills/
├── setup-project/
│   ├── SKILL.md              # Required: frontmatter + instructions
│   ├── templates/            # Optional: memory-bank file templates
│   │   ├── handbook.md
│   │   ├── projectbrief.md
│   │   └── ...
│   └── examples/             # Optional: reference project briefs
│       └── restaurant-mvp.md
└── initial-prompt/
    └── SKILL.md
```

Each skill is a directory. Resources referenced from `SKILL.md` via `${CLAUDE_SKILL_DIR}`.

---

## SKILL.md structure (template)

Every skill follows this shape. Target: **`SKILL.md` under 200 lines**; resources unlimited but loaded on demand. Exception: interview/bootstrap skills whose flows must stay inline and deterministic (`setup-project`, `initial-prompt`) may exceed the target — never pad other skills toward it.

```markdown
---
name: skill-name
description: When to use this skill — first 100-200 chars matter most for auto-invocation. Keep total under 1500 chars. Include trigger phrases and example user requests.
when_to_use: |
  Optional. Concatenated with description for matching.
  Use bullet points or short paragraphs.
allowed-tools: Read, Write, Edit, Bash(npm *), Bash(npx *), Bash(git *)
---

# Skill Name

One-sentence purpose statement.

## When to use

3–4 bullet points covering trigger conditions.

## Don't use when

Bullets pointing at the correct alternative: "... → that's `<other-skill>`". Skip section if none.

## Prerequisites

Hard requirements only. Skip section if none.

## Interaction style

Use `AskUserQuestion` for every user decision. Interview questions offer the standard
option pair: `"I'll describe it"` (answer via the Other field) and `"I don't know yet"`
(record as an open question, apply a sensible default, continue). Plain text prompts
only when the user must paste long content.

## Flow

Numbered steps, each ≤ 5 lines. Branches as sub-bullets, not new sections.
Reference templates via `${CLAUDE_SKILL_DIR}/templates/<file>.md`.
Mention which Memory Bank files to read and update.

## Output

What the skill produces (files created, messages shown, state changed).

## Examples

1–3 short usage examples with expected outcome.

## Next step

Single line: "After this, the user typically runs the `<next-skill>` skill."
```

No closing signatures, no SDLC phase diagrams, no ASCII boxes.

---

## Frontmatter conventions

| Field | Use it for |
|-------|-----------|
| `name` | Match directory name (kebab-case). Optional but always set for clarity. |
| `description` | **Critical.** First sentence = the trigger. Write so Claude can match a user request: "When the user wants to start a new project from scratch...". Keep total under 1500 chars. |
| `when_to_use` | Extra trigger phrases / examples. Use when `description` is getting long. |
| `allowed-tools` | List only what the skill genuinely needs. Restrict `Bash` to globs (`Bash(npm *)`, `Bash(git *)`). |
| `disable-model-invocation` | `true` only if the skill is dangerous and must be user-triggered. |

Skip everything else (`model`, `effort`, `context: fork`, `paths`, `arguments`) unless there's a concrete reason.

---

## Conventions

### Language
- **English only**, throughout — frontmatter, instructions, templates, user-facing messages.
- No localization branches. If a user needs Polish output, they ask Claude at runtime.

### Stack assumptions
- Stack is chosen as three independent dimensions during the interview: framework, UI layer, backend.
- Frameworks (first-class, scaffolded by `initial-prompt`): **Vite + React + TypeScript** (default), **Next.js 15+ (App Router)**, **Astro**.
- Other frameworks → `STACK=custom`; `initial-prompt` stops with "manual bootstrap required" message.
- Tailwind CSS v3 is the baseline for every framework.
- **shadcn/ui**: opt-in UI toggle (`SHADCN_OPTED_IN`), never default. For Astro it renders via React islands.
- **Supabase**: opt-in backend toggle (`SUPABASE_OPTED_IN`); when off, templates strip the Supabase sections (frontend-only).

### Tone
- Direct. Imperative voice ("Read the file", not "You should read the file").
- No "Great!", "Awesome!", celebration emojis.
- Sparse emoji: only for output categories (✅ success, ⚠️ warning, ❌ error) — never decorative.

### Help / usage info
- Auto-invoked skills don't need a `--help` flag — the `description` covers it.
- If the user wants details, they ask. Don't pre-bake an ASCII help screen.

### Memory Bank updates
- Update inline (the skill writes the files itself) — no delegation to a separate agent.
- Update `activeContext.md` and `progress.md` after every significant action.
- Other files (`techContext.md`, `systemPatterns.md`) update only when the underlying fact changes.

### Error checking sequence (when a skill modifies code)
1. `npx tsc --noEmit`
2. `npx eslint . --max-warnings 0`
3. `npm run build`

Each step gates the next, and runs only if its tool is configured in the project (`tsconfig.json`, an ESLint config, a `build` script) — a missing tool is a skip, not a failure. Astro projects without ESLint: `npx astro check` replaces steps 1–2. Don't run `npm run dev` — the user does.

### Resource references
- Templates / examples in `${CLAUDE_SKILL_DIR}/templates/`, `${CLAUDE_SKILL_DIR}/examples/`.
- Reference from `SKILL.md` with the env var, not relative paths.
- Resources are loaded lazily — the skill only reads them when needed.

---

## Anti-patterns (learned from the legacy setup)

| Avoid | Why |
|-------|-----|
| ASCII frames in help / output | Visual noise, breaks in narrow terminals, hard to maintain |
| Mixed-language content | Duplicates every user-facing message, decays fast |
| Long inline examples (200+ lines in `SKILL.md`) | Bloats the file. Move to `examples/`, reference on demand. |
| Internal signatures / easter eggs | Not for public distribution |
| Hardcoded internal names or company references | Leak into public skills |
| Tutorial sections inside `SKILL.md` | Extract to `templates/` or `examples/`, reference via `${CLAUDE_SKILL_DIR}` |
| Restating CLAUDE.md rules in every skill | Trust that CLAUDE.md is loaded; reference don't repeat |
| `npm run dev` in skill | User's responsibility, not Claude's |
| Hardcoded generic defaults (e.g. "Performance: < 2s on 4G") | Numbers that don't reflect the actual project |
| Duplicate state checks (e.g. two `ls` calls in separate steps) | Capture state once, pass forward |
| Step-by-step confirmations every other line | Confirm once at the decision point, then execute |
| Vague `description` ("Helps with projects") | Auto-invocation needs specific trigger phrases |

---

## Installation

`install.sh` clones the repo and copies a whitelist into the user's `~/.claude/` directory:

- `skills/` — the skill directories
- `agents/` — the subagent definitions
- `docs/` — long-form guides referenced from skills
- `MANIFEST.md`, `SKILLS_AND_AGENTS.md`, `SECURITY.md` — top-level docs

Nothing else from the repo is shipped to users.
