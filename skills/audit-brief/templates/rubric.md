# Brief audit rubric

Evaluate the brief across these eight dimensions. For each, mark **present**,
**partial**, or **missing**, and record exactly what is absent or ambiguous.
Never invent values the brief does not state — record those as "unspecified".

1. **Goal & scope**
   - The problem being solved, in one sentence.
   - Who the users are (roles / personas).
   - What success looks like (the brief's own success criteria, if any).
   - What is explicitly out of scope.

2. **Features**
   - A concrete feature list, not just themes.
   - Priority / phasing (MVP vs. later) where it matters.
   - Each feature is actionable, not a slogan.

3. **Screens / views**
   - Every user flow maps to at least one screen.
   - Screens that are implied but never described (the most common gap).
   - Navigation between screens and entry points.

4. **User flows**
   - End-to-end paths for each primary action.
   - Authentication / authorization states (signed out, signed in, roles).
   - First-run / onboarding path.

5. **Data & state**
   - The core entities and their relationships.
   - Where data comes from (user input, API, seed) and whether it persists.
   - What is stored vs. derived vs. ephemeral.

6. **Edge cases & error states**
   - For each: name the case AND its required consequence (what the product does).
   - Cover: empty, loading, error/failure, permission/auth denied, offline,
     limits (length, count, rate), concurrency, and domain-specific cases.
   - Edge cases the brief omits are usually where scope quietly expands.

7. **Constraints (non-functional)**
   - Only what the brief actually states: platform, browsers, accessibility,
     performance, localization, compliance. Mark unstated ones "unspecified" —
     do not fabricate targets.

8. **Consistency**
   - Contradictions within the document or across multiple files.
   - Terms used inconsistently for the same concept.
   - Requirements that conflict (e.g. "no login" vs. "user profiles").
