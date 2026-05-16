# Tech Context: [PROJECT_NAME]

## Stack

**Frontend:**
- Next.js 15+ with App Router
- React 19+ with TypeScript

**UI & Styling:**
- Tailwind CSS v3.x (configured automatically by `create-next-app`)
- Framer Motion (animations)
- Lucide React (icons)
- Recharts (charts and data viz)
- shadcn/ui (Radix + Tailwind) — _only included if user opted in during setup_

**Backend:**
- Supabase (PostgreSQL + Auth + Realtime + Storage) — via `@supabase/ssr`
- Or Next.js API routes / Server Actions

**Deployment:**
- Vercel (recommended for Next.js)
- Supabase Cloud (backend)

## Design tokens

- Primary color: [COLOR_OR_DERIVE]
- Font: Inter (body), Poppins or similar (headings) — load via `next/font`
- Border radius: 0.5rem default
- Shadows: soft for cards and elevated elements

## Version stability

- Use stable LTS / latest stable for all dependencies.
- Tailwind: v3.x.
- Verify `npm run build` succeeds before considering a feature done.

## Development setup

### Prerequisites

- Node.js 20+ (LTS)
- npm or pnpm
- Git

### Bootstrap

```bash
npx create-next-app@latest . --typescript --tailwind --app --eslint --no-git --use-npm
npm install framer-motion lucide-react
# Only if SHADCN_OPTED_IN:
# npx shadcn@latest init
```

For Supabase:

```bash
npm install @supabase/supabase-js @supabase/ssr
```

### Daily commands

```bash
npm run dev          # Dev server (Turbopack)
npm run build        # Production build
npm run start        # Production server
npm run lint
```

### Error-checking sequence

```bash
npx tsc --noEmit
npx eslint . --max-warnings 0
npm run build
```

## Environment variables

Create `.env.local` (gitignored):

```
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=server-only-key  # Never expose client-side
```

## Performance targets

[Fill in from interview Step 3.6.]

## Browser support

[Fill in from interview Step 3.6.]

## Supabase + Next.js patterns

- Use `@supabase/ssr` for cookie-based auth in server components.
- Service-role key only in server contexts (Server Actions, route handlers).
- Realtime subscriptions only in client components (`'use client'`).

## App Router patterns

- **Server components by default.** Add `'use client'` only when needed (state, effects, browser APIs, event handlers).
- File-based routing: each folder under `app/` is a route. `page.tsx` is the entry, `layout.tsx` wraps children.
- Data fetching: `async` server components fetch directly; avoid `useEffect`-based fetching on the server.
- Metadata: export `metadata` from `page.tsx` / `layout.tsx` for SEO (no React Helmet).
- Don't install `react-router-dom`.

## File structure

```
app/
  layout.tsx        # Root layout
  page.tsx          # Home
  globals.css       # Tailwind directives
  (group)/          # Route groups
components/         # Reusable UI
lib/                # Helpers, server utilities
public/             # Static assets
```

## Product principles

- Implement only the requested functionality.
- Server-first: prefer Server Components, Server Actions, and server-side fetching.
- Don't over-abstract; helpers only when reused.
