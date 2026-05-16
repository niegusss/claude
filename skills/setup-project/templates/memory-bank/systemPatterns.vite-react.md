# System Patterns: [PROJECT_NAME]

## Architecture overview

- **Frontend:** SPA, React 18+
- **Backend:** Supabase (PostgreSQL + Auth + Realtime + Storage)
- **State:** React Context for global state; React Query (TanStack Query) for server state
- **Routing:** React Router v6+

## Folder structure

```
src/
  pages/         # Page components (HomePage.tsx, DashboardPage.tsx, ...)
  components/    # Reusable UI (Button.tsx, Card.tsx, ...)
  hooks/         # Custom hooks
  utils/         # Helper functions
  types/         # TypeScript type definitions
  assets/        # Images, fonts
  App.tsx        # Routing root
  main.tsx       # Entry point
  index.css      # Global styles
```

### Naming

- Pages: PascalCase + `Page` suffix (`HomePage.tsx`)
- Components: PascalCase, no suffix (`Button.tsx`)
- Hooks: camelCase + `use` prefix (`useEstimates.ts`)
- Files match the default export name.

## React + TypeScript patterns

- Functional components with hooks only.
- TypeScript interfaces for all component props.
- Explicit return types on exported components.
- Custom hooks for reusable logic.
- Context API for global state; avoid prop drilling past 2 levels.
- `React.memo` only when a profiler shows it's worth it.
- Error boundaries around route-level components.

## Design and animation

- Define design tokens (colors, spacing, radii, shadows) once; reuse.
- Framer Motion for transitions. Don't animate keyboard-triggered actions.
- Use `ease-out` for "appearing" motion; `ease-in` only for "disappearing".
- Buttons get `:active` `transform: scale(0.97)` for tactile feel.
- Specify exact properties in `transition` — never `transition: all`.
- Avoid text gradients on body copy and primary CTAs.
- Default theme is fully polished; never ship a half-done light/dark toggle.

## UI / UX standards

- Responsive everywhere (mobile-first or tablet-first depending on user base).
- Loading states with skeletons.
- Toasts for non-blocking feedback.
- Lucide React for icons.
- Recharts for charts.
- **shadcn/ui** components when the user opted in during setup. Otherwise, write components from scratch with Tailwind.

## Code quality

- Clean, readable, complete code. No `// TODO` placeholders left in.
- camelCase variables, PascalCase components.
- All imports at the top of the file.
- Strict TypeScript (`strict: true` in `tsconfig.json`).
- Don't wrap with `try/catch` unless you have a specific recovery path.
- Use `console.log` for debugging — stripped from production builds.

## Security

- Validate user input at the boundary (form submission, URL params).
- Sanitize anything that goes into `dangerouslySetInnerHTML`.
- Use environment variables for keys; never commit them.
- Supabase RLS on every table that holds user data.
- HTTPS everywhere; never load Supabase config over HTTP.

## Error handling

- Error boundaries at route level.
- Toasts for user-facing errors.
- Don't `try/catch` to silence errors — let them propagate when there's no recovery.

## Testing

- TDD by default: Red → Green → Refactor.
- Target: 80% coverage for logic-heavy modules.
- Unit tests for utilities and hooks.
- Integration tests for component interactions.
- E2E tests sparingly — testing pyramid, not testing inverted-pyramid.
