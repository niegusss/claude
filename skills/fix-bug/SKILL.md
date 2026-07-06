---
name: fix-bug
description: |
  When the user reports ONE specific bug and wants it diagnosed and fixed — a broken
  behavior, an error message, a failing flow, or a stack trace. Runs a targeted
  investigation: locate the suspect code, find the root cause (not just the symptom),
  reproduce it, propose the smallest fix, apply it after confirmation, then verify with
  tsc/eslint/build. The bug description is the primary input. Trigger phrases: "fix this
  bug", "this is broken", "why does X fail", "diagnose this error", "track down the root
  cause", "login throws 500", "/fix-bug <description>". NOT for open-ended "find all the
  bugs" scans (that's the code-reviewer agent) or security audits (security-scanner).
allowed-tools: Read, Edit, Grep, Glob, AskUserQuestion, Bash(npm *), Bash(npx *), Bash(git *)
---

# fix-bug

Diagnose and fix a single, specific bug: locate it, find the root cause, reproduce it, then apply the smallest fix after confirmation.

## When to use

- The user describes one concrete broken behavior: `/fix-bug "login throws 500 on empty email"`.
- "This is broken", "why does X fail", "diagnose this error", or a pasted stack trace.
- One bug at a time, with a clear symptom to investigate.

## Don't use when

- The user wants an open-ended "find all the bugs" scan → that's the `code-reviewer` agent.
- The user wants a security audit → that's the `security-scanner` agent.
- The user asks whether a brief/spec is complete → that's the `audit-brief` skill.

## Non-goals

- One bug at a time — not an open-ended scan.
- Not a security audit.
- Does not scaffold, add features, or refactor beyond the fix.

## Interaction style

Use `AskUserQuestion` for every decision — clarifying the symptom and confirming the fix. Reserve plain text only when the user must paste long content (a log, a stack trace, a full error).

## Flow

### 1. Read Memory Bank

Read `activeContext.md`, `progress.md`, and `systemPatterns.md` for known issues and code patterns. If `memory-bank/` doesn't exist, skip and continue.

### 2. Resolve symptom (`$ARGUMENTS`)

`$ARGUMENTS` is the bug description. If empty, ask with `AskUserQuestion`: when it happens, how to reproduce, expected vs. actual. If a stack trace or log is involved, ask the user to paste it (plain text).

### 3. Locate

Grep/Glob for the error message and the names mentioned in the description; narrow to the suspect files. Check recently changed code first (`git diff`, `git log`) — it's the most likely culprit.

### 4. Root cause

Explain *why* it breaks, not just *where*. If the cause is unclear, state a hypothesis and verify it against the code before declaring it. Don't fix the symptom while the cause stays.

### 5. Reproduce

Find the minimal way to confirm the bug — an existing test or a command. If it can't be reproduced, note that and continue on the strongest hypothesis.

### 6. Propose fix

Present the root cause and the smallest change that removes it. Confirm via `AskUserQuestion` **before editing**: apply it / show the diff first / try a different direction.

### 7. Apply

After confirmation, edit with `Edit`. Make the smallest change that fixes the cause — no opportunistic refactors.

### 8. Verify

Run only the checks the project actually has — skip any that don't apply, and never treat a missing tool or script as a failure:
1. `npx tsc --noEmit` — only if a `tsconfig.json` exists.
2. `npx eslint . --max-warnings 0` — only if an ESLint config exists (`.eslintrc*`, `eslint.config.*`, or an `eslintConfig` key in `package.json`).
3. `npm run build` — only if `package.json` defines a `build` script.

Run the applicable checks in sequence, each gating the next. On a genuine failure, fix or report. Don't run `npm run dev` — the user does.

### 9. Update Memory Bank

Update `activeContext.md` (what was fixed) and `progress.md` (move the item from known issues to done). Skip if `memory-bank/` doesn't exist.

## Output

- Modified source files (only after confirmation).
- Updated `activeContext.md` and `progress.md`.
- No standalone report or other artifacts.

## Examples

1. `/fix-bug "login throws 500 on empty email"` → locates the handler, finds the unguarded input, proposes a guard, applies it after confirmation, verifies with tsc/eslint/build.
2. `/fix-bug` (no arg) → asks for the symptom and reproduction steps, then proceeds.
3. `/fix-bug` with a pasted stack trace → traces the top frame to the source, confirms the root cause, fixes it.

## Next step

After this, the user typically runs the `code-reviewer` agent on the change, or commits it.
