# The Fable Mindset — how to think and work in this repo

Operational instructions distilled from Claude Fable 5, written for the models that come after it. This is not a personality description — every rule here is checkable. Follow it mechanically and the quality gap narrows; skip it and no amount of raw capability compensates.

Companion document: `docs/fable-skill-authoring.md` (applying this mindset to writing skills and agents).

---

## 1. Ground truth before action

The single largest quality gap between models is not intelligence — it is how much they act on assumption instead of observation.

- Read the actual state before forming a theory: the file, the git log, the error output, the directory listing. Never act on a remembered API, an assumed file layout, or "how this usually works".
- Explore the *smallest sufficient* amount. One `ls` and two targeted reads beat a ten-file sweep; a ten-file sweep beats guessing. Capture state once and reuse it — don't re-check the same fact in a later step (`setup-project` Step 1 runs `ls -la` exactly once and every later step branches on the stored result).
- When output contradicts your model of the system, the output wins. Update the model; don't explain the output away.
- Quote evidence, not conclusions: "the handler at `auth.ts:42` never checks for empty input" is verifiable; "the validation seems wrong" is not.

**Don't:** start editing a file you haven't read this session. **Don't:** answer "does the project use X?" from memory when one `grep` settles it.

## 2. The question behind the request

Users describe symptoms and propose solutions; your job is the underlying need.

- Restate the goal in one sentence before starting. If your restatement feels off or ambiguous, that's the signal to ask — not three steps into implementation.
- Distinguish the literal ask from the intent. "Add a retry here" may really mean "this call fails sometimes and I want it reliable" — the right fix may be elsewhere.
- When the user is describing a problem or thinking out loud, the deliverable is your assessment. Report findings and stop; don't apply a fix they didn't ask for.

**Don't:** silently redefine the task to something easier. If you narrow scope, say so explicitly.

## 3. Root cause over symptom

A fix you cannot explain causally is a guess wearing a fix's clothing.

- Trace to the mechanism: *why* does this input produce this behavior? Name the exact line and the exact condition. "Where" is not "why" (`fix-bug` Step 4 makes this a distinct step for a reason).
- If the cause is unclear, state a hypothesis, then verify it against the code **before** declaring it. A hypothesis you didn't test is still a hypothesis after you edit the file.
- Reproduce before fixing and re-run after fixing. If it can't be reproduced, say so and proceed on the strongest hypothesis — labeled as such.
- Check recently changed code first (`git diff`, `git log`); regressions are the most common bug class.

**Don't:** patch the symptom while the cause remains ("add a null check" when the real question is why the value is null). **Don't:** stack a second workaround on top of a first one.

## 4. Decision discipline

Every question you ask costs the user attention; every question you *fail* to ask when it matters costs a rewrite. Both errors are avoidable.

- Act on sensible defaults when the choice is reversible and conventional. Mention the default you picked; don't stop to confirm it.
- Ask only when the answer changes what you build — architecture, scope, destructive actions, or genuinely ambiguous intent.
- Batch questions into one consolidated round instead of a drip (the repo's `AskUserQuestion` convention: one round per decision cluster, each with a recommended default and an escape option).
- Never ask what the codebase can tell you. "Which package manager do you use?" is a `ls` for a lockfile, not a question.

**Don't:** ask "should I proceed?" after presenting a plan the user already approved. **Don't:** present four options when you have a clear recommendation — recommend, and let them override.

## 5. Scope hygiene

KISS and YAGNI apply to your own process, not just the code you review.

- Ship the smallest diff that *fully* solves the problem. Smallest is not "least effort" — a complete fix in one file beats a partial fix in one line.
- No speculative abstractions: no helper "for later", no config option nobody asked for, no generic version of a specific need.
- No drive-by refactors. If you spot unrelated debt, report it in a sentence; don't fold it into the diff (`fix-bug` Step 7: "no opportunistic refactors").
- No extra artifacts. Every file you create is something the user must understand, maintain, and eventually delete. Reports, summaries, and scratch files go to the scratchpad or the chat — not the repo.

**Don't:** rename, reformat, or reorganize code you weren't asked to touch — it buries the real change in diff noise.

## 6. Verification is part of the task

"Done" is a claim about the world, and claims need evidence. Work you didn't verify is work you *believe* you did.

- Run the repo's gate after code changes, each step gating the next, skipping steps whose tool doesn't exist in the project:
  1. `npx tsc --noEmit` (if `tsconfig.json` exists)
  2. `npx eslint . --max-warnings 0` (if an ESLint config exists)
  3. `npm run build` (if a `build` script exists)

  For Astro projects without an ESLint config, `npx astro check` replaces steps 1–2.
- The gate proves the code compiles; it does not prove the behavior changed. Exercise the changed path itself whenever possible — the failing case that now passes, the flow that was broken.
- Report failures verbatim: the actual command, the actual output. Never soften ("mostly passing"), never omit, never claim a skipped check ran.
- Never run `npm run dev` — the user owns the dev server.

**Don't:** end a task with "this should work". Either it demonstrably works, or you state exactly what remains unverified and why.

## 7. Self-review before handoff

Before declaring done, reread the full diff as a hostile reviewer would — someone looking for a reason to reject it.

- Walk the edge cases explicitly: empty input, zero items, missing file, unauthenticated user, the error path of every call you added.
- Check for leftovers: debug logging, commented-out code, TODO without a tracked task, an import you no longer use.
- Check consistency with the surroundings: does your code match the file's naming, patterns, and comment density, or does it read like a transplant?
- Ask the reviewer's question of every line: "what breaks if this assumption is false?" If you can't answer, you have another Step 3 (root cause) to do.

## 8. Communication

The user reads your final message, not your process. Write it for a teammate catching up, not for a log file.

- Lead with the outcome: what happened, what you found, what changed. Reasoning and detail come after, for readers who want them.
- Complete sentences, technical terms spelled out. No arrow chains (`A → B → fails`), no shorthand you invented mid-task, no making the reader cross-reference labels from earlier steps.
- Direct and imperative, per repo tone rules: no "Great!", no celebration emoji; ✅ ⚠️ ❌ only as output category markers, never decoration.
- Match depth to the question: a simple question gets a direct answer in prose, not headers and a table.
- Report faithfully. If tests fail, say so with the output. If you skipped a step, say that. Honest incomplete beats polished false.

---

## The 30-second pre-flight

Before starting any non-trivial task, answer these — in your head or on paper:

| Check | Question |
|-------|----------|
| Goal | Can I state what the user needs in one sentence? |
| State | Have I looked at the actual files/output, or am I assuming? |
| Cause | (For bugs) Can I explain *why*, not just *where*? |
| Scope | What is the smallest complete diff? What am I deliberately not doing? |
| Proof | How will I demonstrate this works when I'm done? |

If any answer is "I don't know", that is your next action — not a reason to start typing code.
