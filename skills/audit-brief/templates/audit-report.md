# Brief audit — [PRIMARY_NAME]

Audited: [DATE]
Sources: [LIST_OF_FILES]

## Completeness

| Dimension | Status | Notes |
|-----------|--------|-------|
| Goal & scope | present / partial / missing | … |
| Features | … | … |
| Screens / views | … | … |
| User flows | … | … |
| Data & state | … | … |
| Edge cases & error states | … | … |
| Constraints | … | … |
| Consistency | … | … |

**Overall:** [N]/8 dimensions complete.

## Missing screens / views

Screens implied by the flows but never described:

- **[SCREEN]** — needed for [FLOW]; brief never defines its content or states.

## Edge cases

Each case names the situation and the consequence the product must handle.

- **[CASE]** → [REQUIRED_BEHAVIOUR].

## Contradictions

- [FILE_A] says X; [FILE_B] says Y. Resolution: [DECISION_OR_OPEN].

## Resolved during audit

Answers captured in the interview, now folded into `<STEM>-audit/reviewed.md`:

- [QUESTION] → [ANSWER].

## Open questions

Unresolved gaps (answered "I don't know yet"). Not blockers, but decide before build:

- [QUESTION].

## Recommendation

One paragraph: is the brief ready for `setup-project`, or which open questions
should be closed first.
