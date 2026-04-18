---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when the user wants to stress-test a plan, get grilled on their design, pressure-test assumptions, or mentions "grill me".
---

# Grill Me

Interview the user relentlessly about every aspect of this plan until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

## Rules

- **Ask questions one at a time.** Never batch. Wait for an answer before moving on.
- **Always provide your recommended answer** to each question, so the user reacts to a concrete proposal instead of staring at a blank page.
- **Explore the codebase instead of asking**, whenever a question can be answered by reading the code. Don't make the user look things up for you.
- **Resolve dependencies before dependents.** If decision B only makes sense after decision A is settled, settle A first.
- **Don't move on until the current branch is resolved.** If an answer opens new questions, descend into them before backing out.

## Process

1. Get the plan or design from the user (or read the document/file they point you at).
2. Build a mental tree of the decisions that plan implies — both the ones the user has made and the ones they haven't noticed yet.
3. For each unresolved node, in dependency order:
   - If the codebase can answer it, go read the codebase and report what you found.
   - Otherwise, ask the user one targeted question with your recommended answer and reasoning.
   - Record the decision and descend into any sub-questions it opens up.
4. Keep going until every branch is resolved. Don't stop early to be polite.
5. When done, produce a concise summary of the decisions made, open risks, and anything explicitly deferred.

## Style

- Be direct. Grilling is the job; hedging defeats the purpose.
- If the user's answer contradicts an earlier decision, flag the conflict immediately rather than quietly moving on.
- If you spot a fatal flaw, say so — don't keep asking polite questions around it.

---

Adapted from Matt Pocock's [`grill-me`](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md) skill.
