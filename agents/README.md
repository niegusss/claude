# Development Agents

These agents can be invoked via the Task tool to perform specialized development tasks automatically.

---

## Available Agents

| Agent | Purpose | When to use |
|-------|---------|-------------|
| [code-reviewer](./code-reviewer.md) | KISS/SOLID/DRY/YAGNI compliance | After significant code changes |
| [test-case-generator](./test-case-generator.md) | Generate test checklists | After feature implementation |
| [memory-bank-sync](./memory-bank-sync.md) | Detect drift between code and memory-bank | After commits, after major changes |
| [quick-lint](./quick-lint.md) | TypeScript + secrets scan (<5s) | During development, before commit |
| [dep-analyzer](./dep-analyzer.md) | npm audit + bundle size + maintenance + license | After `npm install`, periodically |
| [adr-generator](./adr-generator.md) | Architecture Decision Records | After major design decisions |
| [security-scanner](./security-scanner.md) | P0 security checklist scan (from SECURITY.md) | Before deploying to production |

---

## Agent Format

All agents use YAML frontmatter format:

```yaml
---
name: agent-name
description: Description with examples showing when to invoke the agent.\n\nExamples:\n\n<example>\nContext: [situation]\nuser: "[user message]"\nassistant: "[assistant response]"\n<Task tool call to agent-name>\n</example>
model: inherit
---

[Agent prompt/instructions body]
```

### Key Fields

| Field | Purpose |
|-------|---------|
| `name` | Agent identifier (used in Task tool calls) |
| `description` | When/why to use, with XML examples |
| `model` | Model to use (inherit, sonnet, opus, haiku) |
| Body | Full agent instructions and persona |

---

## How to Invoke Agents

Use the Task tool with the agent's subagent_type:

```
Task tool call:
  subagent_type: "code-reviewer"
  prompt: "Review my recent code changes"
  description: "Review code changes"
```

---

## Quick Reference

### Code Quality
```
# Code Review - Check KISS, SOLID, DRY, YAGNI compliance
subagent_type: "code-reviewer"
prompt: "Review the code changes I just made"

# Quick Lint - Fast TypeScript + secrets check
subagent_type: "quick-lint"
prompt: "Quick check my changes"
```

### Testing
```
# Generate Test Cases
subagent_type: "test-case-generator"
prompt: "Generate test cases for the login feature"
```

### Dependencies
```
# Analyze Dependencies
subagent_type: "dep-analyzer"
prompt: "Analyze lodash for security and bundle size"
```

### Documentation
```
# Sync Memory Bank
subagent_type: "memory-bank-sync"
prompt: "Check if memory-bank is up to date"

# Generate ADR
subagent_type: "adr-generator"
prompt: "Generate an ADR for choosing Supabase as backend"
```

---

## Typical development flow

Agents fit into a project's lifecycle alongside the skills (`setup-project`, `initial-prompt`, and future ones). A common pattern:

1. **Adding a dependency** → `dep-analyzer` (audit before commit)
2. **Mid-development sanity check** → `quick-lint` (fast TypeScript + secrets scan)
3. **Before committing** → `code-reviewer` (KISS/SOLID/DRY/YAGNI compliance)
4. **After committing a feature** → `test-case-generator` (manual + automated test checklist)
5. **After a feature is done** → `memory-bank-sync` (detect drift, update `activeContext.md` / `progress.md`)
6. **On major architecture decisions** → `adr-generator` (capture context and alternatives in `docs/adr/`)
7. **Before deploying to production** → `security-scanner` (P0 violations from `SECURITY.md`)

Skills handle workflows end-to-end (interview → scaffold → implement); agents handle focused, single-purpose tasks within those workflows.

---

## Adding new agents

1. Create a new `.md` file in this directory
2. Use the YAML frontmatter format shown above
3. Include:
   - Clear `name` identifier (matches the file name without `.md`)
   - `description` with `<example>` blocks showing usage
   - `model: inherit` (or specify `sonnet` / `opus` / `haiku`)
   - Agent prompt body with identity, responsibilities, and output format
4. Update this README with the new agent
