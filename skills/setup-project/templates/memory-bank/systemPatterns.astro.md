# System Patterns: [PROJECT_NAME]

## Architecture overview

- **Frontend:** Astro 5+, islands architecture (zero JS by default)
- **Interactivity:** React islands via `@astrojs/react`, hydrated with `client:*` directives
- **Backend:** Supabase (PostgreSQL + Auth + Realtime + Storage) — _only included if Supabase opted in during setup; otherwise static / frontend-only_
- **Routing:** File-based via `src/pages/`

## Folder structure

```
src/
  pages/            # File-based routes (index.astro, blog/[slug].astro, ...)
  layouts/          # Shared page shells (Layout.astro)
  components/       # .astro components (static) + .tsx islands (interactive)
  content/          # Content collections (Markdown/MDX)
  content.config.ts # Collection schemas (zod)
  lib/              # Helpers; supabase clients — only included if Supabase opted in during setup
  styles/
    global.css      # Tailwind directives
public/             # Static assets
astro.config.mjs    # Integrations
```

### Naming

- Pages: lowercase route files (`index.astro`, `about.astro`); dynamic routes use `[param].astro`.
- Components: PascalCase (`Hero.astro`, `Counter.tsx`).
- Islands (interactive): PascalCase `.tsx`, hydrated explicitly in the page.
- Files match the default export / component name.

## Astro + island patterns

- **Static-first.** Author UI in `.astro`; reach for a `.tsx` island only when a piece genuinely needs state, effects, or event handlers.
- **Hydration directives:** pick the cheapest that works — `client:visible` for below-the-fold, `client:idle` for non-urgent, `client:load` only when immediate.
- **Pass data down as props** from `.astro` to islands; islands are leaves, not layout owners.
- **Content collections** for any structured Markdown/MDX; query with `getCollection()`, never `fs`.
- Don't introduce client-side routing — routing is file-based.

## React island patterns

_Only applies to interactive `.tsx` islands._

- Functional components with hooks only.
- TypeScript interfaces for all props.
- Keep islands small and self-contained; lift shared state out to the `.astro` parent as props.

## Design and animation

- Define design tokens (colors, spacing, radii, shadows) once; reuse.
- Prefer CSS transitions / View Transitions API for page-level motion; reserve JS animation for islands.
- Use `ease-out` for "appearing" motion; `ease-in` only for "disappearing".
- Buttons get `:active` `transform: scale(0.97)` for tactile feel.
- Specify exact properties in `transition` — never `transition: all`.
- Avoid text gradients on body copy and primary CTAs.
- Default theme is fully polished; never ship a half-done light/dark toggle.

## UI / UX standards

- Responsive everywhere (mobile-first or tablet-first depending on user base).
- Loading states with skeletons inside islands that fetch.
- Lucide for icons.
- **shadcn/ui** components (as React islands) — _only included if user opted in during setup; otherwise write components from scratch with Tailwind_

## Code quality

- Clean, readable, complete code. No `// TODO` placeholders left in.
- camelCase variables, PascalCase components.
- All imports at the top of the file.
- Strict TypeScript (`strict: true` in `tsconfig.json`).
- Don't wrap with `try/catch` unless you have a specific recovery path.

## Security

- Validate user input at the boundary (form submission, URL params, SSR endpoints).
- Sanitize anything injected as raw HTML (`set:html`).
- Use environment variables for keys; never commit them. Only `PUBLIC_`-prefixed vars reach the client.
- HTTPS everywhere; never load backend config over HTTP.
- _Supabase security, only included if Supabase opted in during setup:_ keep the service-role key server-side; enable RLS on every table that holds user data.

## Error handling

- Astro `404.astro` / `500.astro` for route-level fallbacks.
- Surface user-facing errors inside the relevant island; don't swallow them.
- Don't `try/catch` to silence errors — let them propagate when there's no recovery.

## Testing

- TDD by default: Red → Green → Refactor.
- Vitest for unit tests (utilities, island logic); Playwright for E2E.
- `astro check` in the error-checking sequence catches type and content-schema drift.
- E2E tests sparingly — testing pyramid, not inverted-pyramid.
