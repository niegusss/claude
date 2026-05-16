# Tech Context: [PROJECT_NAME]

## Stack

**Frontend:**
- React 18+ with TypeScript
- Vite (HMR, ES modules, `import.meta.env`)
- React Router v6+

**UI & Styling:**
- Tailwind CSS v3.x (stable — avoid v4.x experimental)
- Framer Motion (animations)
- Lucide React (icons)
- Recharts (charts and data viz)
- shadcn/ui (Radix + Tailwind) — _only included if user opted in during setup_

**Backend:**
- Supabase (PostgreSQL + Auth + Realtime + Storage)

**Deployment:**
- Vercel (frontend)
- Supabase Cloud (backend)

## Design tokens

- Primary color: [COLOR_OR_DERIVE]
- Font: Inter (body), Poppins or similar (headings)
- Border radius: 0.5rem default
- Shadows: soft for cards and elevated elements

## Version stability

- Use stable LTS / latest stable for all dependencies. No beta/alpha/experimental.
- Tailwind: v3.x, not v4.
- React: stable LTS.
- Verify `npm run build` succeeds before considering a feature done.

## Development setup

### Prerequisites

- Node.js 18+ (LTS)
- npm or pnpm
- Git

### Bootstrap commands

```bash
npm create vite@latest . -- --template react-ts
npm install
npm install react-router-dom framer-motion lucide-react
npm install -D tailwindcss@3 postcss autoprefixer
npx tailwindcss init -p
# Only if SHADCN_OPTED_IN:
# npx shadcn@latest init
```

### Daily commands

```bash
npm run dev          # Dev server
npm run build        # Production build
npm run test         # Run tests
npm run test:watch   # TDD loop
npm run lint
npm run format
```

### Error-checking sequence

Before declaring work done:

```bash
npx tsc --noEmit
npx eslint . --max-warnings 0
npm run build
```

## Environment variables

Create `.env.local` (gitignored):

```
VITE_SUPABASE_URL=your-supabase-url
VITE_SUPABASE_ANON_KEY=your-supabase-anon-key
```

## Performance targets

[Fill in from interview Step 3.6 — do not use generic defaults.]

## Browser support

[Fill in from interview Step 3.6.]

## Supabase guidelines

- Use Row Level Security (RLS) on every table that holds user data.
- Implement proper auth flows; never expose service-role keys client-side.
- Use realtime subscriptions for live data; debounce write-heavy events.
- Connect to the database only when the feature genuinely needs it.

## React Router patterns

When adding a new page:

1. Create `src/pages/PageName.tsx` (PascalCase + `Page` suffix)
2. Add the route in `src/App.tsx`
3. Use React Router v6+ nested routes when needed

Reusable components live in `src/components/` (PascalCase without `Page` suffix).

## Product principles

- Implement only the requested functionality. No speculative features.
- Single-file components are fine when they're maintainable.
- Don't over-abstract; introduce helpers only when reused.
