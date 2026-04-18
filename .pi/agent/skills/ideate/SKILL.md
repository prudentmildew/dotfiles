---
name: ideate
description: Collaboratively develop an early-stage idea by discussing it, researching prior art and constraints, and verifying its assumptions and feasibility. Use when the user has a rough idea, wants to brainstorm, explore a concept, sanity-check a design, or mentions "ideate", "let's think about", or "I have an idea".
---

# Ideate

Turn a rough idea into something actionable. Five steps: **Frame → Diverge → Research → Converge → Verify**. Loop back whenever new info invalidates earlier work.

Two rules throughout:

- **Ask one question at a time**, always with your recommended answer so the user reacts instead of staring at a blank page.
- **Facilitate, don't co-brainstorm.** Let the user think first; offer prompts from [references/prompts.md](references/prompts.md) only when they're stuck, asked, or clearly missing an angle. Research shows individuals-then-pool beats group free-for-all.

## Step 1 — Frame

Users arrive with a **solution disguised as an idea**. Extract the problem.

1. Restate the idea in one or two sentences; get confirmation.
2. Ask "**If this didn't exist, what would you do instead?**" — usually the single most productive question. Then clarify problem ownership, success criteria, scope, and hard constraints (one at a time, recommended answer each time).
3. Produce a one-paragraph problem statement **independent of the proposed solution**. Get explicit sign-off.

If the user resists reframing, flag it and move on. More framing tools (5 Whys, Jobs-to-be-Done) in [references/prompts.md](references/prompts.md).

## Step 2 — Diverge

The original idea is now **one candidate among several**.

1. Ask the user for alternative approaches. Wait; don't fill silence.
2. If stuck or if alternatives are variations of the same shape, pull structured prompts from [references/prompts.md](references/prompts.md): SCAMPER, analogy, inversion.
3. Defer judgment. Capture 3–5 candidates including the original.

In this step, "recommended answer" means *a plausible option*, not *the best option* — offering flat alternatives, not ranked ones, prevents pre-convergence.

## Step 3 — Research

Ground candidates in reality. **Prefer concrete investigation over speculation.**

- Codebase touched → explore it rather than guessing.
- Web/fetch tools available → look up prior art, libraries, landmines. **Verify cited URLs resolve before asserting facts.**
- Neither available → say so plainly and list what external research is needed.

For each candidate, surface: **prior art**, **building blocks**, **landmines**. If prior art already solves the idea, say so directly — don't play along.

## Step 4 — Converge

Judgment is now required.

1. Propose 2–4 selection criteria fitting the user's constraints; let them add or adjust.
2. Score candidates against the criteria (rough table or "A beats B on X, loses on Y" — don't fake precision).
3. Pick one. **Name what was cut and why** — this is the half of the step that always earns its keep.

If Research already dominated the field to one survivor, skip the scoring and just name the cuts.

## Step 5 — Verify

Every idea is a stack of assumptions. Load [references/verify.md](references/verify.md) for the assumption table template, pre-mortem/pre-parade question banks, and kill-criteria rules.

Required outputs of this step:

- **Ranked assumption list** (risk × impact), with the cheapest experiment for the top 1–2.
- **Measurable kill criteria**, not vibes (e.g. `p95 > 300ms`, not "feels slow").
- **Pre-mortem and pre-parade** done as separate passes — never averaged into an "on balance" analysis.

## Synthesis

When the user signals done, produce this structure (bullets are fine, no filler):

**Problem · Chosen idea · Rejected candidates (one line each) · Why it might work · Key assumptions with confidence · Top risks · Cheapest next experiment with kill criteria · Next concrete action**

Offer to save it:

```bash
scripts/save-synthesis.sh < synthesis.md              # auto-title from first # H1
scripts/save-synthesis.sh --title "…" < synthesis.md  # explicit title
```

Writes `./ideas/YYYY-MM-DD-<slug>.md` (override with `IDEATE_DIR` env var or `--dir`). Never overwrites. Prints the absolute path — report it to the user.

## Style

- One question at a time. Always offer a recommended answer.
- Facilitate; let the user think first.
- Prefer investigation over speculation.
- If the idea has a fatal flaw, say so the moment Research reveals it — don't politely complete all five steps.
- Loop back freely. Research often invalidates framing; that's a feature.

## References

- [references/prompts.md](references/prompts.md) — Frame and Diverge prompts: "what would you do instead?", 5 Whys, Jobs-to-be-Done, SCAMPER, analogy, inversion, forced metaphor.
- [references/verify.md](references/verify.md) — Step 5 mechanics: assumption/experiment table, kill-criteria rules, pre-mortem, pre-parade, red/white hats.
- [scripts/save-synthesis.sh](scripts/save-synthesis.sh) — save synthesis to `ideas/<date>-<slug>.md`.
