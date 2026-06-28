---
name: initial-prompt
description: |
  When the user wants to scaffold the first working page(s) of a project after
  setup-project. Detects the chosen stack (Vite + React, Next.js, Astro, or custom)
  from techContext.md, bootstraps the project structure if needed, and implements
  the first logical page based on the project brief. Use when memory-bank/ exists
  but the project has no working pages yet.
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash(npm *), Bash(npx *), Bash(git *), Bash(ls *), Bash(mkdir *), Bash(mv *), Bash(chmod *), Bash(cat *), Bash(shopt *), Bash(setopt *)
---

# initial-prompt

Scaffold the first working page(s) after `setup-project`, using the project brief, chosen stack, and conventions from Memory Bank.

## When to use

- After `setup-project` completed and `memory-bank/projectbrief.md` is filled in
- The project has no `package.json` yet (full scaffolding) OR has it but no pages yet
- The user asks "create the first page", "scaffold the app", or similar

Do not use if:
- `memory-bank/` does not exist → run `setup-project` first
- The project is already partially built with features → ask the user to request a specific feature instead

## Prerequisites

- `memory-bank/` exists with `projectbrief.md` and `techContext.md` filled in
- Node.js 18+ (LTS) installed

## Interaction style

Use the `AskUserQuestion` tool for every user decision in this flow — not text prompts. This applies to confirming the starting point (Step 4) and the pre-implementation plan (Step 6). Plain text prompts are fine only for diagnostics ("here's what I built, run `npm run dev` to preview") that don't require a decision.

## Flow

### 1. Read Memory Bank

Parallel read (single message, 7 `Read` tool calls):

- `memory-bank/handbook.md`
- `memory-bank/projectbrief.md`
- `memory-bank/techContext.md`
- `memory-bank/productContext.md`
- `memory-bank/systemPatterns.md`
- `memory-bank/activeContext.md`
- `memory-bank/progress.md`

If `projectbrief.md` is mostly placeholders, stop and tell the user to fill it out first.

### 2. Detect project state

Single `ls -la`. Capture `PROJECT_STATE`:

- `empty` — no `package.json`, no source folders → full bootstrap needed
- `bootstrapped-vite` — `package.json` + `vite.config.ts` + `src/` → skip bootstrap
- `bootstrapped-next` — `package.json` + `next.config.*` + `app/` → skip bootstrap
- `bootstrapped-astro` — `package.json` + `astro.config.*` + `src/pages/` → skip bootstrap
- `partial` — `package.json` exists but doesn't match a known layout → ask the user before proceeding

### 3. Detect stack

Read `memory-bank/techContext.md`. Set `STACK`:

| Detected | `STACK` | Branch |
|----------|---------|--------|
| Vite + React | `vite` | Step 5a |
| Next.js (any version) | `next` | Step 5b |
| Astro | `astro` | Step 5c |
| Other (Vue, Svelte, Remix, etc.) | `other` | **Stop** with message |

Unsupported stack message:

```
Stack [X] detected in techContext.md.
Currently `initial-prompt` supports Vite+React, Next.js, and Astro.
For [X], bootstrap the project manually using the official starter, then ask
Claude to implement the first page based on memory-bank/projectbrief.md.
```

Also check `techContext.md` content for two toggles, treating a section as enabled only when it isn't conditional/stripped:
- `SHADCN_OPTED_IN` — presence of a live shadcn/ui section.
- `SUPABASE_OPTED_IN` — presence of a live Supabase section.

### 4. Determine starting point

If `$ARGUMENTS` is non-empty → use it directly as the starting instruction (e.g. `landing page`, `dashboard first`, `start with login`), skip the confirmation below.

Otherwise analyze `projectbrief.md`:

- Check `activeContext.md` for an explicit next step
- Look at user flows in `projectbrief.md` — usually start with the entry point of the primary user journey
- Default priority order: landing/home → auth (if required) → main dashboard → core feature

Pick the recommended starting point, then `AskUserQuestion`:
- **Question:** "Start with **[RECOMMENDED]**? (Reason: [ONE_SENTENCE_REASON])"
- **Options:**
  - `"Approve — start there"`
  - `"Pick a different starting point"` (desc: "Use the Other field to specify, e.g. 'auth flow first' or 'settings page'")

### 5a. Bootstrap (Vite + React)

Skip if `PROJECT_STATE` is `bootstrapped-vite`.

If the directory is empty:

```bash
npm create vite@latest . -- --template react-ts
```

If the directory has content (e.g. memory-bank/ exists):

```bash
npm create vite@latest temp-app -- --template react-ts
shopt -s dotglob 2>/dev/null || setopt dotglob 2>/dev/null
mv temp-app/* . 2>/dev/null || true
rmdir temp-app
```

Then:

```bash
npm install
npm install react-router-dom framer-motion lucide-react
npm install -D tailwindcss@3 postcss autoprefixer
npx tailwindcss init -p
```

Configure Tailwind by updating `tailwind.config.js` `content` to `["./index.html", "./src/**/*.{js,ts,jsx,tsx}"]` and replacing `src/index.css` with the three `@tailwind` directives.

If `SHADCN_OPTED_IN`:

```bash
npx shadcn@latest init
```

Create folder structure: `src/pages/`, `src/components/`, `src/hooks/`, `src/utils/`, `src/types/`.

**File path rules:**
- Pages: `src/pages/PageName.tsx` (PascalCase + `Page` suffix)
- Components: `src/components/ComponentName.tsx`
- No leading slashes, no `./` prefix in paths.

Jump to **Step 6**.

### 5b. Bootstrap (Next.js)

Skip if `PROJECT_STATE` is `bootstrapped-next`.

If the directory is empty:

```bash
npx create-next-app@latest . --typescript --tailwind --app --eslint --no-git --use-npm
```

If the directory has content:

```bash
npx create-next-app@latest temp-app --typescript --tailwind --app --eslint --no-git --use-npm
shopt -s dotglob 2>/dev/null || setopt dotglob 2>/dev/null
mv temp-app/* . 2>/dev/null || true
rmdir temp-app
```

Then:

```bash
npm install framer-motion lucide-react
```

If `SHADCN_OPTED_IN`:

```bash
npx shadcn@latest init
```

**File path rules (Next.js App Router):**
- Routes: `app/<route>/page.tsx` (lowercase folder)
- Layouts: `app/layout.tsx` (root), nested `layout.tsx` per route
- Components: `components/ComponentName.tsx` (PascalCase)
- Server components by default; add `'use client'` only when needed (state, effects, browser APIs)

### 5c. Bootstrap (Astro)

Skip if `PROJECT_STATE` is `bootstrapped-astro`.

If the directory is empty:

```bash
npm create astro@latest . -- --template minimal --typescript strict --no-git --skip-houston
```

If the directory has content (e.g. memory-bank/ exists):

```bash
npm create astro@latest temp-app -- --template minimal --typescript strict --no-git --skip-houston
shopt -s dotglob 2>/dev/null || setopt dotglob 2>/dev/null
mv temp-app/* . 2>/dev/null || true
rmdir temp-app
```

Then add integrations and icons:

```bash
npx astro add tailwind --yes
npx astro add react --yes
npm install lucide-react
```

If `SHADCN_OPTED_IN` (shadcn renders as React islands, so the `react` integration above is required):

```bash
npx shadcn@latest init
```

If `SUPABASE_OPTED_IN`:

```bash
npm install @supabase/supabase-js
```

Create folder structure: `src/pages/`, `src/layouts/`, `src/components/`, `src/styles/`.

**File path rules (Astro):**
- Routes: `src/pages/<route>.astro` (lowercase; `index.astro` is home, `[param].astro` for dynamic)
- Layouts: `src/layouts/Layout.astro` (PascalCase)
- Static components: `src/components/Name.astro`; interactive islands: `src/components/Name.tsx`
- Hydrate islands explicitly with `client:*` directives — static by default; no leading slashes or `./` in paths.

Jump to **Step 6**.

### 6. Pre-implementation plan

Derive visual style from `memory-bank/productContext.md` under `## Visual Style`. Translate the style name to concrete tokens:

- **Soft / Agency** → warm palette, `rounded-2xl`, soft shadows, generous padding
- **Minimalist** → neutral grays, `rounded-md`, no shadows, tight spacing, type-driven
- **Brutalist** → black/white + one accent, `rounded-none`, bold borders, monospace
- **Glassmorphism** → vivid gradient bg, `backdrop-blur` cards, `white/10` borders, layered depth
- **Dark Mode / Midnight** → `slate-900` bg, neon accent (emerald/violet/cyan), glow shadows

If no style defined, derive from project type (consumer SaaS → soft; dev tool → brutalist or dark; content app → minimalist).

State the plan concisely:

```
Plan:
- Page(s): [list]
- Visual: [style] → [colors, fonts, radii in 1 line]
- Components: [list]
- Animations: [if any — Framer Motion targets for vite/next; CSS / View Transitions for astro]
```

Then `AskUserQuestion`:
- **Question:** "Proceed with this plan?"
- **Options:**
  - `"Yes — implement"`
  - `"Adjust the plan"` (desc: "Use the Other field to specify what to change")

### 7. Implement

Follow the conventions already documented in `memory-bank/systemPatterns.md` and `memory-bank/techContext.md` — don't restate them inline. Key reminders:

- Implement only the specific feature(s) chosen in Step 4. No speculative scope.
- Write complete, runnable code. No `// TODO` placeholders.
- TypeScript strict; explicit prop interfaces.
- Tailwind utility classes; design tokens defined once and reused.
- Animate sparingly — `ease-out` for appearing, target specific properties (never `transition: all`). Use Framer Motion for vite/next; for astro prefer CSS / View Transitions and reserve JS animation for hydrated islands.
- Buttons get `:active` `scale(0.97)` for tactile feel.
- Loading and error states for every async boundary.
- Lucide React for icons. shadcn/ui components only if `SHADCN_OPTED_IN`.
- Accessibility: semantic HTML, ARIA labels on interactive non-button elements, keyboard reachable.

### 8. Verify build

Run in order, gate each step on the previous. Use the sequence for the detected `STACK`:

**`vite` / `next`:**

```bash
# 1. Type check (fastest)
npx tsc --noEmit

# 2. Linter
npx eslint . --max-warnings 0

# 3. Final build
npm run build
```

**`astro`** (the minimal starter ships no ESLint config; `astro check` covers types + content schemas):

```bash
# 1. Type + content check
npx astro check

# 2. Final build
npm run build
```

Fix errors before moving to the next step. **Do not** run `npm run dev` — the user does that.

### 9. Update Memory Bank

Update `memory-bank/activeContext.md`:

- Current focus → "First implementation complete: [page names]"
- Immediate next steps → "[Logical follow-up — e.g., 'Add auth flow' or 'Implement [F2]']"

Update `memory-bank/progress.md`:

- Move implemented features from Backlog to Done
- Note "In progress" if anything is partial

### 10. Summary

Print a concise summary:

```
Created:
- [file paths]

Features implemented:
- [bulleted list from Step 4]

Build: passed ([tsc + eslint + build] for vite/next, or [astro check + build] for astro)

Next step: once available, run `setup-tests` to add Vitest infrastructure and start TDD.
The user can also run `npm run dev` to preview.
```

## Output

- Project scaffolded (if needed): `package.json`, Vite/Next.js/Astro config, source folders
- First page(s) implemented per the project brief
- `memory-bank/activeContext.md` and `memory-bank/progress.md` updated

## Next step

After this, the user typically adds testing infrastructure — via the `setup-tests` skill once it's available, or manually (Vitest) in the meantime.
