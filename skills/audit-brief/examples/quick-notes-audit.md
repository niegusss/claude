# Example: auditing an incomplete brief

> **Illustrative reference, not a template.** It shows the *shape* of a good audit:
> an intentionally thin input brief, then the report `audit-brief` should produce from
> it. The point is how gaps, edge cases (with consequences), and a contradiction are
> surfaced — not the specific domain.

---

## Input — `quick-notes.md` (as the user wrote it)

> # Quick Notes
>
> A web app for jotting down quick notes. Open it, type, and your notes are saved
> instantly. Notes sync across all your devices so they're always up to date. No
> accounts, no friction — just start typing.
>
> Features:
> - Create a note
> - Edit a note
> - Delete a note
> - Search notes
> - Settings

This brief reads fine at a glance. The audit is where the holes show.

---

## Output — `quick-notes-audit/report.md`

# Brief audit — quick-notes.md

Audited: 2026-06-28
Sources: quick-notes.md

## Completeness

| Dimension | Status | Notes |
|-----------|--------|-------|
| Goal & scope | partial | Clear product idea; no success criteria, no out-of-scope. |
| Features | partial | Five features named, none specified. "Settings" lists no settings. |
| Screens / views | missing | Only an editor is implied. List, search results, and settings screens are never described. |
| User flows | partial | Happy path implied; no first-run, no empty state. |
| Data & state | missing | "Saved instantly" and "sync across devices" with "no accounts" — unspecified storage and identity. |
| Edge cases & error states | missing | None covered. |
| Constraints | missing | No platform, browser, or offline target stated. |
| Consistency | partial | One hard contradiction (see below). |

**Overall:** 0/8 complete, 4/8 partial.

## Missing screens / views

- **Notes list** — "Search notes" and multiple notes imply a list/home screen; never described (layout, sort order, what an item shows).
- **Search results** — search is a feature but has no screen, no empty-results state.
- **Settings** — listed as a feature; its contents and screen are undefined.

## Edge cases

- **No notes yet (first run)** → the list/editor needs an empty state with a clear call to start typing.
- **Empty search** → define no-results copy and behaviour.
- **Save fails (offline / storage full)** → "saved instantly" implies a guarantee; define what the user sees when a save can't complete.
- **Same note edited on two devices** → "sync across devices" requires a conflict rule (last-write-wins, merge, or prompt).
- **Very long note / very many notes** → define limits or confirm none.

## Contradictions

- "Notes sync across all your devices" vs. "No accounts." Cross-device sync needs a
  device identity. Resolution: **open** — pick (a) local-only, no sync, or (b) an
  anonymous device-pairing/identity mechanism.

## Resolved during audit

- Success metric → "user can capture a note in under 3 seconds from open."
- Settings contents → theme (light/dark) only, for the MVP.

## Open questions

- Sync vs. no-accounts contradiction (above) — decides the whole data model.
- Persistence: local storage only, or a backend?

## Recommendation

Not yet ready for `setup-project`. The sync-vs-accounts contradiction must be closed
first — it determines whether this is a local-only app or a synced one, which changes
the data model, the screens, and half the edge cases. Once decided, the corrected
`quick-notes-audit/reviewed.md` is buildable.

---

## What the reviewed copy adds

`quick-notes-audit/reviewed.md` keeps the original text and folds in the resolved items,
each flagged so the diff is visible — e.g.:

> ## Screens
> - **Notes list (home)** — `> added during audit`
> - **Editor**
> - **Search results** — `> added during audit`
> - **Settings** — theme only `> added during audit`
>
> ## Edge cases — `> added during audit`
> - Empty state, failed save, cross-device conflict, empty search …

Open questions are carried into the reviewed copy as a clearly marked **Decisions
needed** section, not silently resolved.
