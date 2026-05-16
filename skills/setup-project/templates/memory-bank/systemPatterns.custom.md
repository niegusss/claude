# System Patterns: [PROJECT_NAME]

## Architecture overview

[Describe at a high level:
- Frontend type (SPA, MPA, SSR, mobile, native, etc.)
- Backend role (API server, BFF, serverless functions, edge, none)
- State management approach
- Routing mechanism]

## Folder structure

```
[Document the project's folder layout. Common patterns:]

src/
  [DOMAIN_FOLDERS]
  [COMPONENT_FOLDERS]
  [UTILITY_FOLDERS]
```

### Naming conventions

- [PATTERN] — e.g., "Files match the default export name"
- [PATTERN] — e.g., "Hooks/composables: camelCase + verb prefix"
- [PATTERN]

## Language and framework patterns

[Pull from the stack chosen in `techContext.md`. Document:
- Component model (functional / class / SFC / etc.)
- Type system usage (TypeScript strict mode, Flow, etc.)
- State patterns (local, lifted, context, store, signal)
- Async patterns (async/await, promises, observables)]

## Design and animation

- Define design tokens once; reuse.
- Pick an animation library and stick with it.
- Avoid animating high-frequency interactions (keyboard shortcuts, list navigation).
- Use `ease-out` for appearing; `ease-in` for disappearing.
- Specify exact properties in transitions; avoid `all`.
- Default theme polished before adding alternates.

## UI / UX standards

- Responsive across target devices (defined in `techContext.md`).
- Loading and error states for every async boundary.
- Non-blocking feedback for user actions.
- Iconography from a single source (consistent style).
- Charts from a single library.

## Code quality

- Complete, runnable code in every commit. No `// TODO` placeholders.
- Strict typing where the language supports it.
- Consistent naming (chosen above).
- Don't `try/catch` unless there's a specific recovery path.
- Log strategically; don't ship `console.log` to production without a strip step.

## Security

- Validate input at every external boundary (forms, APIs, URL params).
- Sanitize anything that becomes HTML.
- Secrets in environment variables; never in source.
- HTTPS in every environment except local dev.

## Error handling

- Boundary-level handlers (route, page, feature).
- User-facing errors are non-blocking and recoverable when possible.
- Log errors with enough context to debug from logs alone.

## Testing

- TDD by default for logic-heavy code.
- Pick a test runner that fits the stack; document it in `techContext.md`.
- Unit tests for pure logic; integration tests for module boundaries; E2E sparingly.
- Coverage target: 80% for logic-heavy modules.
