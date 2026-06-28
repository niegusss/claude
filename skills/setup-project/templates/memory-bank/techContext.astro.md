# Tech Context: [PROJECT_NAME]

## Stack

**Frontend:**
- Astro 5+ with TypeScript (strict)
- Islands architecture — ships zero JS by default; interactivity is opt-in per component
- `@astrojs/react` for interactive islands (React 18+)

**UI & Styling:**
- Tailwind CSS v3.x (stable — avoid v4.x experimental), via `@astrojs/tailwind`
- Lucide (icons)
- shadcn/ui (Radix + Tailwind), rendered as React islands — _only included if user opted in during setup_

**Backend:**
- Supabase (PostgreSQL + Auth + Realtime + Storage) — _only included if Supabase opted in during setup_

**Deployment:**
- Vercel or Netlify (static or SSR via the matching Astro adapter)
- Supabase Cloud (backend) — _only included if Supabase opted in during setup_

## Design tokens

- Primary color: [COLOR_OR_DERIVE]
- Font: Inter (body), Poppins or similar (headings)
- Border radius: 0.5rem default
- Shadows: soft for cards and elevated elements

## Version stability

- Use stable LTS / latest stable for all dependencies. No beta/alpha/experimental.
- Tailwind: v3.x, not v4.
- Verify `npm run build` succeeds before considering a feature done.

## Development setup

### Prerequisites

- Node.js 20+ (LTS)
- npm or pnpm
- Git

### Bootstrap commands

```bash
npm create astro@latest . -- --template minimal --typescript strict --no-git --skip-houston
npx astro add react --yes
npx astro add tailwind --yes
npm install lucide-react
# Only if SHADCN_OPTED_IN:
# npx shadcn@latest init
```

For Supabase (_only included if Supabase opted in during setup_):

```bash
npm install @supabase/supabase-js
```

### Daily commands

```bash
npm run dev          # Dev server
npm run build        # Production build (also type-checks via astro check)
npm run preview      # Preview the production build
```

### Error-checking sequence

Before declaring work done:

```bash
npx astro check       # Type + content-collection checks
npm run build
```

## Environment variables

Create `.env` (gitignored). Astro exposes only `PUBLIC_`-prefixed vars to the client via `import.meta.env`. _Supabase entries only included if Supabase opted in during setup:_

```
PUBLIC_SUPABASE_URL=your-supabase-url
PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

## Performance targets

[Fill in from interview Step 3.6 — do not use generic defaults.]

## Browser support

[Fill in from interview Step 3.6.]

## Supabase + Astro patterns

_Only included if Supabase opted in during setup._

- Browser client for client-side islands; a server client for SSR endpoints / actions.
- Never expose the service-role key — only `PUBLIC_` anon keys reach the client.
- Use Row Level Security (RLS) on every table that holds user data.
- Realtime subscriptions only inside hydrated islands (`client:*`).

## Astro patterns

- **Islands by default off.** Add a `client:*` directive (`client:load`, `client:visible`, `client:idle`) only on components that need interactivity.
- **File-based routing:** every file in `src/pages/` becomes a route. `.astro` files for static/server-rendered pages; framework components (`.tsx`) only inside islands.
- **Content collections:** structured Markdown/MDX lives in `src/content/`, typed via `src/content.config.ts`.
- **Layouts:** shared shells live in `src/layouts/` and wrap pages via `<Layout>` slots.
- Keep React confined to islands — don't reach for `react-router`; routing is file-based.

## File structure

```
src/
  pages/            # File-based routes (index.astro, about.astro, ...)
  layouts/          # Shared page shells (Layout.astro)
  components/       # .astro components + .tsx islands
  content/          # Content collections (Markdown/MDX)
  content.config.ts # Collection schemas
  styles/           # global.css (Tailwind directives)
public/             # Static assets served as-is
astro.config.mjs    # Integrations (react, tailwind)
```

## Product principles

- Implement only the requested functionality. No speculative features.
- Ship as little client JS as possible — reach for an island only when interactivity demands it.
- Don't over-abstract; introduce helpers only when reused.
