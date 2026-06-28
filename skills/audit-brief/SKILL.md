---
name: audit-brief
description: |
  When the user has an existing project brief, scope, or spec — a single file or a
  folder of documents — and wants to check it for completeness BEFORE building. Audits
  for missing information, missing screens/views, unclear user flows, known edge cases
  and their consequences, and contradictions across files. Interviews the user to fill
  gaps, then produces an audit report plus a corrected copy of the brief. Analysis and
  correction only — it never scaffolds or builds the project. Trigger phrases: "audit my
  brief", "check this scope", "is my spec complete", "review my project brief",
  "/audit-brief <file-or-folder>".
allowed-tools: Read, Write, Bash(ls *), Bash(find *)
---

# audit-brief

Audit an existing brief/scope (file or folder) for completeness, then produce a report and a corrected copy. Never builds the project.

## When to use

- The user already has a brief/scope/spec and wants it checked before any setup or coding.
- Invoked with a path: `/audit-brief docs/` or `/audit-brief brief.md`.
- The user asks "is my spec complete?", "what's missing from this brief?", "find edge cases I forgot".

Don't use when:
- The user wants to *build* from the brief → that's `setup-project` / `initial-prompt`.
- There is no document to audit yet → the user should write or dictate one first.

## Non-goals

- Does **not** scaffold, code, or run the project.
- Does **not** write to `memory-bank/` or overwrite the original file(s). Outputs are new files; confirm before overwriting if an output name already exists.

## Interaction style

Use the `AskUserQuestion` tool for every decision — selecting which file to audit, and every interview question. Each interview question offers the same pattern:

- `"I'll describe it"` — user types a detailed answer in the **Other** field.
- `"I don't know yet"` — escape: records the item as an open question in the report, continues.

Reserve plain text only when the user must paste long content.

## Flow

### 1. Resolve input (`$ARGUMENTS`)

`$ARGUMENTS` is a path to a file or folder, relative to the working directory.

- **File** → read it. It is the primary document.
- **Folder** → `find <folder> -maxdepth 2 -type f \( -name "*.md" -o -name "*.txt" \)`. Read all matches.
- **Empty** → `ls` the working directory for likely briefs (`*.md`, `*.txt`, `docs/`, names containing `brief`, `scope`, `spec`, `prd`). Present candidates with `AskUserQuestion`; if none found, stop and ask the user to provide a path.

Capture `PRIMARY` = the main document (the single file, or the largest/most-brief-like file in a folder). Outputs are named from its stem.

### 2. Read and synthesize

Read every selected document in one batch. Build a single mental model of: goal, users, features, screens, flows, data, constraints. When multiple files disagree, record the contradiction — do not silently pick one.

### 3. Audit against the rubric

Load `${CLAUDE_SKILL_DIR}/templates/rubric.md` and evaluate the brief across every dimension. For each: mark **present / partial / missing**, and note what's absent. Do **not** invent numeric targets or constraints the brief doesn't state (note them as "unspecified" instead).

Pay special attention to:
- **Screens/views**: every user flow must map to a screen. List screens implied but never described.
- **Edge cases**: for each, name the case *and* its consequence (what the product must do). Empty, loading, error, permission/auth, offline, limits, concurrency, and domain-specific cases.
- **Contradictions**: across files or within one.

### 4. Interview to fill gaps

Group the `missing` and `partial` items into themed batches. Ask with `AskUserQuestion` (max ~4 per call). Feed answers back into the model. Items answered `"I don't know yet"` become **Open questions** in the report — they are not blockers.

Keep it tight: ask only about gaps that materially change scope. Skip cosmetic gaps.

### 5. Produce outputs (non-destructive)

Derive `STEM` from `PRIMARY` (e.g. `brief.md` → `brief`). Write two files next to the input:

1. `<STEM>.audit.md` — the report, from `${CLAUDE_SKILL_DIR}/templates/audit-report.md`. Includes the per-dimension completeness table, missing screens, edge cases with consequences, contradictions, and open questions.
2. `<STEM>.reviewed.md` — the corrected brief: the original content, restructured and augmented with everything resolved during the interview. Mark inserted/changed sections with a short `> added during audit` note so the diff is visible.

If either filename already exists, confirm with `AskUserQuestion` before overwriting.

For the depth and tone of a good report — missing screens, edge cases with consequences, a surfaced contradiction, and resolved vs. open questions — anchor on `${CLAUDE_SKILL_DIR}/examples/quick-notes-audit.md`.

### 6. Summarize

Report: overall completeness (e.g. "6/8 dimensions complete"), the count of resolved vs. open questions, and the two output paths. Plain text — no decoration.

## Output

- `<STEM>.audit.md` — completeness report (rubric table, missing screens, edge cases + consequences, contradictions, open questions).
- `<STEM>.reviewed.md` — corrected and augmented copy of the brief.
- Originals and `memory-bank/` are untouched.

## Examples

1. `/audit-brief project-brief.md` → reads one file, interviews on 3 gaps, writes `project-brief.audit.md` + `project-brief.reviewed.md`.
2. `/audit-brief docs/` → reads all `.md`/`.txt` under `docs/`, flags a contradiction between two files, writes outputs named from the primary doc.
3. `/audit-brief` (no arg) → scans the working dir, asks which candidate to audit, then proceeds.

## Next step

After this, the user typically runs the `setup-project` skill, feeding it the `.reviewed.md` brief.
