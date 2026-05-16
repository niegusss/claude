# CLAUDE.md

## Memory Bank

This project uses a Memory Bank in `memory-bank/`. **Read `memory-bank/handbook.md` first** in every session, then load the other Memory Bank files as needed. Treat `projectbrief.md` as the requirements contract — all features must align with it.

After significant work, update `memory-bank/activeContext.md` and `memory-bank/progress.md`.

## Core principles

- Plan before implementing. Use plan mode when available.
- TDD by default (Red-Green-Refactor) for logic-heavy code.
- Keep it simple: KISS, SOLID, DRY, YAGNI. Don't over-engineer.
- Commit frequently with clear, descriptive messages.
- Roll back when errors repeat or loops form — don't bash through.
- Keep this file concise. Project-specific context lives in `memory-bank/`.
- Reuse components before creating new ones.
- After major modules, check file sizes; refactor when they balloon.
- Self-check own suggestions; challenge user assumptions when warranted.
- Memory Bank is the source of truth — keep it current.

## Project

- **Name:** [PROJECT_NAME]
- **Stack:** see `memory-bank/techContext.md`
- **Status:** see `memory-bank/activeContext.md`

## Development commands

<!-- Add or replace as the project evolves -->

```bash
npm run dev        # Start development server
npm run build      # Production build
npm run test       # Run tests
npm run lint       # Run linter
```

## Error-checking sequence

Before declaring work done, run in order (fail fast — fastest first):

```bash
npx tsc --noEmit
npx eslint . --max-warnings 0
npm run build
```
