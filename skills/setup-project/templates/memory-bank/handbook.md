# Memory Bank — Development Handbook

## What is the Memory Bank?

A set of files in `memory-bank/` that Claude reads at the start of every session to understand the project. Because Claude has no persistent memory between sessions, these files are the single source of truth for project context.

## Files

| File | Purpose |
|------|---------|
| `handbook.md` | This file — how to work with the Memory Bank |
| `projectbrief.md` | Full project requirements, user flows, feature specs |
| `productContext.md` | Why this project exists, goals, product vision |
| `techContext.md` | Technology stack, setup commands, dev guidelines |
| `systemPatterns.md` | Architecture, component structure, code conventions |
| `activeContext.md` | Current work focus and immediate next steps |
| `progress.md` | What's done, what's left, known issues |
| `integrations/` | One file per configured MCP server |

## Rules for Claude

1. Read all Memory Bank files at the start of every session, before taking any action.
2. Update `activeContext.md` and `progress.md` after completing significant work.
3. Never contradict Memory Bank content without flagging the conflict to the user.
4. Treat `projectbrief.md` as the requirements contract — all features must align with it.
5. When in doubt, re-read. The Memory Bank has the answer.

## Rules for the user

1. Run the `setup-project` skill once at the start of a new project.
2. Tell Claude to update Memory Bank when you make decisions outside Claude sessions.
3. Keep files current — stale Memory Bank means confused Claude.
4. Don't delete files. Even "empty" files provide structure Claude relies on.

## When to update which file

| Situation | Update |
|-----------|--------|
| New feature added to scope | `projectbrief.md`, `progress.md` |
| Architecture decision made | `systemPatterns.md`, `activeContext.md` |
| Feature completed | `progress.md`, `activeContext.md` |
| Tech stack changed | `techContext.md` |
| Sprint or milestone starts | `activeContext.md` |
| Bug discovered | `progress.md` (known issues) |
| MCP server added | `integrations/<server>.md`, `techContext.md` |
