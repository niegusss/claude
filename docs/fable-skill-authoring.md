# Fable-quality skill & agent authoring

`MANIFEST.md` and `agents/README.md` define the **required structure** of skills and agents in this repo. This document defines the **quality bar** — how to think while writing them so the result works when executed by a model weaker than the author. Where this document and `MANIFEST.md` disagree, `MANIFEST.md` wins and this document has a bug.

Companion document: `docs/fable-mindset.md` (the general working method this bar rests on).

---

## 0. Read first

Before writing a new skill or agent, read these — the exemplars end-to-end, not skimmed:

| File | What it teaches |
|------|-----------------|
| `MANIFEST.md` | Structure law: SKILL.md template, frontmatter table, conventions, anti-patterns |
| `agents/README.md` | Agent format, frontmatter, invocation |
| `skills/fix-bug/SKILL.md` | The best short skill: tight trigger, 9 deterministic steps, explicit non-goals |
| `skills/setup-project/SKILL.md` | The interview pattern: AskUserQuestion for every decision, defaults, escape hatches |
| `agents/code-reviewer.md` | Agent shape: checklist, exact output contract, edge-case handling |

## 1. Design the trigger before the flow

The `description` is an information-retrieval problem, not a summary. Claude matches a user's sentence against it; a skill whose description nobody's request matches is dead code, and one that matches too broadly steals requests from its neighbors.

Work in this order:

1. Write 5–8 real user sentences that **should** invoke the skill ("this is broken", "login throws 500").
2. Write 2–3 sentences that **should not** — requests belonging to a neighboring skill or agent.
3. Only then write the description: situation first ("When the user reports ONE specific bug…"), literal trigger phrases in quotes, the `/skill <arg>` form, and explicit **NOT for…** exclusions that name the correct alternative.

`fix-bug`'s description is the model: it claims one-bug requests, hands "find all the bugs" to `code-reviewer`, and hands security audits to `security-scanner`. Every new skill must state its borders against the *existing* set — when you add a skill, reread the neighbors' descriptions and sharpen both sides.

## 2. Write flows for a weaker executor

Assume the model executing the skill is less capable than you. A strong model fills gaps with judgment; a weaker one fills them with plausible-sounding wrong actions. The flow must survive the *dumbest reasonable* interpretation of every step.

- **Deterministic numbered steps.** Each step is one action with an observable result. "Grep for the error message; narrow to the suspect files" is executable. "Investigate the issue" is not a step, it's a wish.
- **Capture state once, pass it forward.** Detect facts in one early step, name them as variables (`PROJECT_STATE`, `STACK`, `SUPABASE_OPTED_IN`), and have later steps branch on the variable — never re-detect (MANIFEST anti-pattern: duplicate state checks).
- **Every branch has an explicit condition.** "If `memory-bank/` doesn't exist, skip and continue" — condition, action, continuation. Never "if needed, handle X": the weak executor cannot compute "needed".
- **Handle the absent case for every dependency.** Missing config, missing script, missing directory: say what happens. `fix-bug` Step 8 runs each check *only if its config exists* and "never treat[s] a missing tool or script as a failure" — that sentence exists because an executor once did.
- **One confirmation at the decision point, then execute.** `fix-bug` confirms once before editing (Step 6), then runs Steps 7–9 without further permission. Step-by-step confirmations are a MANIFEST anti-pattern.
- **Checkable success criteria.** End the flow with commands whose exit status decides ("`npx tsc --noEmit` passes"), not judgments ("code is clean").

The test for each step: could a competent junior with no context beyond the SKILL.md perform it and *know* whether they succeeded? If knowing requires taste, rewrite the step until it requires a check.

## 3. Interview design

For skills that gather requirements (`setup-project`, `audit-brief`), the interview is the product. Rules proven by those skills:

- `AskUserQuestion` for **every** decision — never a plain-text prompt, except when the user must paste content longer than a paragraph.
- Every question ships with the standard option pair: `"I'll describe it"` (routes to the Other field) and `"I don't know yet"` (escape hatch — record as an open question, apply a sensible default, continue). An interview must never dead-end on ignorance.
- Fixed-choice questions put the recommended option first, labeled `(Recommended)`, and map each option to an explicit state variable (`STACK=vite`).
- Split bundled decisions into independent dimensions — the stack question is three questions (framework / UI layer / backend) precisely so "Next.js" doesn't silently imply a backend.
- Bound the follow-ups: a vague answer earns at most `INTENSITY_LIMIT` follow-ups per topic, then you take what you have.
- Stop when done: if no remaining answer would change the output, the interview is over. Questions past that point are theater.

## 4. Agent design

Agents are single-report specialists, not workflows. The quality bar per part:

- **Single responsibility.** If the description needs "and" to explain the job, split it. `quick-lint` and `code-reviewer` coexist because speed and depth are different jobs.
- **Frontmatter `<example>` blocks are the trigger.** Write realistic ones: the actual sentence a user would type, the actual assistant sentence before the Task call. A generic example ("user: help me") matches nothing.
- **Tools follow the job.** Read-heavy agents get `Read, Grep, Glob` and glob-restricted Bash (`Bash(git diff*)`), never `Write`/`Edit`. If an agent doesn't modify code, make that impossible, not just unlikely.
- **The output format is a contract, not a suggestion.** Specify the exact template: bold labels, blocking vs. suggestions separated, every finding cited as `path/to/file.ts:42 — issue`. The caller consumes this report; an agent that improvises its format breaks the caller.
- **Edge cases get their own section.** What if there are no changes to review? What if the diff is 500+ lines? What if the agent is unsure? `code-reviewer` answers all three ("note it as a question rather than an issue") — every agent must answer its equivalents.

## 5. Skill or agent?

| Signal | Skill | Agent |
|--------|-------|-------|
| Shape | Multi-step workflow the user walks through | Focused task returning one report |
| Interaction | Interviews, confirmations, decisions | None — runs to completion in isolation |
| Output | Files created/modified, project state changed | A single structured message |
| Invoked by | User request matching the description (or `/name`) | Claude, mid-task, via the Task tool |

Rule of thumb: if it needs `AskUserQuestion`, it's a skill. If it could run unattended and hand back findings, it's an agent. `fix-bug` (confirm-before-edit) is a skill; `code-reviewer` (read, judge, report) is an agent. When a workflow contains a focused analysis, the skill *calls* the agent rather than inlining it.

## 6. Test before shipping

A skill you haven't executed is a hypothesis. Before committing a new or changed skill/agent, run this checklist in a scratch project:

1. **Trigger test.** Phrase the request 3 ways it *should* match — the skill fires each time. Phrase 2 neighbor-owned requests — it stays silent.
2. **Path test.** Every `${CLAUDE_SKILL_DIR}/...` reference resolves to a file that exists. Every skill/agent named in the body exists in the repo.
3. **Absence test.** Run in a project missing the optional pieces (no `memory-bank/`, no `tsconfig.json`, empty `$ARGUMENTS`) — the flow degrades exactly as its branches say, no crash, no invented behavior.
4. **Memory Bank test.** The flow reads the right files at the start and updates `activeContext.md` / `progress.md` after significant work (or explicitly skips when absent).
5. **Weak-executor pass.** Reread each step asking "what is the dumbest reasonable reading of this?" — if that reading does the wrong thing, the step is underspecified, not the executor's fault.
6. **Spec conformance.** Frontmatter fields, section order, tone, and length against `MANIFEST.md`; agent format against `agents/README.md`. Update `SKILLS_AND_AGENTS.md` and the relevant README table.

## 7. Reasoning-level anti-patterns

`MANIFEST.md` lists structural anti-patterns. These are the reasoning-level ones — a skill can pass the structure check and still fail every one of these:

| Anti-pattern | Why it fails | Instead |
|--------------|--------------|---------|
| Hedged steps ("consider doing X", "you may want to…") | A weak executor either always does it or never does — both wrong half the time | State the condition: "If X, do Y. Otherwise skip." |
| Unverifiable criteria ("ensure quality", "make sure it's robust") | Nothing to check → the executor declares success by fiat | A command, a file-exists check, or an exact output to compare |
| Knowledge-assuming steps ("apply the appropriate fix") | Only works if the executor already knows the answer — then why have a skill? | Encode the *procedure* for finding the answer, not the answer's name |
| Description describes the skill, not the user's situation ("A powerful tool for project setup") | Matching runs against user sentences, and users describe situations | "When the user starts a new project…" + trigger phrases |
| Persona fluff without an output contract ("You are a world-class expert…") | Identity doesn't constrain output; the caller gets a different format every run | Cut the adjectives, specify the exact report template |
| Silent-failure branches (a step that can fail with no instruction for the failure) | The executor improvises — usually by pretending it worked | Every fallible step names its failure action: retry, report, or degrade |
| Success-path-only examples | The executor never sees what "handled gracefully" looks like | Include one example with a missing arg or absent dependency (`fix-bug` Example 2) |

---

## The authoring pre-flight

Before opening a PR with a new or changed skill/agent:

| Check | Question |
|-------|----------|
| Trigger | Did I write the should-match and shouldn't-match sentences first? |
| Borders | Does the description name what it's NOT for, pointing at the right neighbor? |
| Executor | Does every step survive the dumbest reasonable reading? |
| Absence | Does the flow say what happens when each dependency is missing? |
| Contract | Is success per step checkable — command, file, or exact output? |
| Tested | Did I actually run the checklist in section 6, or do I just believe it works? |
