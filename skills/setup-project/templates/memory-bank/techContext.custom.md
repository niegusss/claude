# Tech Context: [PROJECT_NAME]

## Stack

[Fill in based on the user's choices in the interview. At minimum, document:]

**Frontend framework:** [FRAMEWORK_AND_VERSION]
**Language:** [TYPESCRIPT / JAVASCRIPT / OTHER]
**UI component library:** [LIBRARY_OR_NONE]
**Styling:** [TAILWIND / CSS_MODULES / STYLED_COMPONENTS / OTHER]
**State management:** [APPROACH]
**Routing:** [LIBRARY_OR_NATIVE]

**Backend:** [FRAMEWORK / SERVICE / NONE]
**Database:** [TYPE_AND_PROVIDER]
**Authentication:** [METHOD_OR_PROVIDER]

**Deployment:** [FRONTEND_HOST], [BACKEND_HOST]

## Version stability

Use stable / latest stable releases. No beta/alpha/experimental dependencies unless the user explicitly opts in. Verify `npm run build` (or equivalent) succeeds before declaring work done.

## Development setup

### Prerequisites

- [RUNTIME_AND_VERSION]
- [PACKAGE_MANAGER]
- Git

### Bootstrap commands

[Document the commands that get this stack running from a fresh clone.]

```bash
[BOOTSTRAP_COMMAND]
```

### Daily commands

```bash
[DEV_COMMAND]
[BUILD_COMMAND]
[TEST_COMMAND]
[LINT_COMMAND]
```

### Error-checking sequence

[List the type-check / lint / build commands in order, fail-fast.]

```bash
[TYPECHECK_COMMAND]
[LINT_COMMAND]
[BUILD_COMMAND]
```

## Environment variables

Create `.env.local` or equivalent (gitignored):

```
[VAR_NAME]=[DESCRIPTION]
```

## Performance targets

[Fill in from interview Step 3.6.]

## Browser / runtime support

[Fill in from interview Step 3.6.]

## Code conventions

[Style guides, naming rules, folder structure — pulled from interview answers or filled in later.]

## Product principles

- Implement only the requested functionality.
- Keep it simple; don't introduce abstractions until they're reused.
- Document non-obvious decisions in `systemPatterns.md`.
