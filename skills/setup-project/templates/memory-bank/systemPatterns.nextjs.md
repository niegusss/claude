# System Patterns: [PROJECT_NAME]

## Architecture overview

- **Frontend:** Next.js 15+ App Router
- **Backend:** Next.js Server Actions / route handlers; Supabase via `@supabase/ssr` — _Supabase only if opted in during setup_
- **State:** Server components by default; React Context only when state must cross client boundaries
- **Routing:** File-based via `app/` directory

## Folder structure

```
app/
  layout.tsx         # Root layout (server component)
  page.tsx           # Home page
  globals.css        # Tailwind directives
  (auth)/            # Route group: auth-related routes
    login/page.tsx
  dashboard/
    layout.tsx       # Nested layout
    page.tsx
components/          # Reusable UI (PascalCase)
lib/
  supabase/          # Supabase clients (server, browser, middleware) — only if Supabase opted in
  utils.ts           # Shared helpers
public/              # Static assets
```

### Naming

- Routes: lowercase folder + `page.tsx` (`app/dashboard/page.tsx`)
- Components: PascalCase in `components/` (`Button.tsx`, `Navbar.tsx`)
- Server actions: `actions.ts` co-located with the route
- Hooks: camelCase + `use` prefix in `lib/` or co-located

## App Router patterns

- **Server components by default.** Add `'use client'` only when you need state, effects, browser APIs, or event handlers.
- **Data fetching:** `async` server components, `cache()` for deduplication, `fetch` with appropriate `revalidate`.
- **Mutations:** Server Actions (`'use server'`) — call directly from forms or client components.
- **Layouts:** cascade. `app/layout.tsx` wraps everything; nested `layout.tsx` wraps its subtree.
- **Metadata:** export `metadata` (static) or `generateMetadata` (dynamic) from `page.tsx` / `layout.tsx`.
- **Loading & error states:** `loading.tsx` and `error.tsx` co-located.
- **Streaming:** `<Suspense>` boundaries for slow data.

## React + TypeScript patterns

- Functional components only.
- Props typed with `interface` (preferred) or `type`.
- Server components can return JSX directly; client components mark with `'use client'` at file top.
- Custom hooks only in client components.
- Strict TypeScript (`strict: true`).

## Design and animation

- Design tokens defined once (colors, spacing, radii, shadows).
- Framer Motion for transitions — wrap usage in a client component.
- `ease-out` for appearing; `ease-in` for disappearing.
- Specify exact properties in `transition`; avoid `transition: all`.
- No text gradients on body copy.
- Default theme polished; don't ship half-done light/dark toggle.

## UI / UX standards

- Responsive across all breakpoints.
- `loading.tsx` for route-level loading; skeleton components for in-page.
- Toasts for non-blocking feedback (server actions return data shape, client renders toast).
- Lucide React for icons.
- Recharts for charts (client component only — charts need browser APIs).
- **shadcn/ui** components when the user opted in during setup. Otherwise, hand-built Tailwind components.

## Code quality

- Clean, complete code. No `// TODO` placeholders.
- camelCase variables, PascalCase components.
- Strict TypeScript.
- Don't `try/catch` unless you have a specific recovery path.
- `console.log` for debugging — Next.js strips them by default in production with appropriate config.

## Security

- Validate input in Server Actions / route handlers (use Zod or similar).
- HTTPS only.
- _Supabase only (if opted in during setup):_ service-role keys are server-only — never expose them in client components or env vars prefixed with `NEXT_PUBLIC_`; enable RLS on every user-data table.

## Error handling

- `error.tsx` per route segment for graceful recovery.
- Server Actions return `{ error?: string, data?: T }` rather than throwing.
- Don't silence errors with `try/catch` for unrelated paths.

## Testing

- TDD by default for logic-heavy code.
- Vitest or Jest for unit tests; Playwright for E2E (Next.js plays well with both).
- Test server components by rendering them in isolation; test Server Actions as plain async functions.
