# Ideate — Verify

Load this file in Step 5 of the skill, when stress-testing the chosen candidate.

For Step 1/2 prompts (framing, divergence), see [prompts.md](prompts.md) instead.

---

## Assumption / experiment table

Every idea is a stack of assumptions. List them, rank by risk, design the cheapest test for the riskiest.

| # | Assumption | Confidence | Impact if wrong | Cheapest test | Kill criterion |
|---|-----------|-----------|-----------------|---------------|----------------|
| 1 | "Users will pay $X/mo for Y" | 30% | Fatal | 10 customer-dev calls | <3/10 say yes |
| 2 | "We can hit <100ms latency" | 70% | Serious | 1-hour spike with representative data | p95 > 300ms |
| 3 | "No existing OSS does this" | 60% | Embarrassing but survivable | 30-min search of GitHub + Google | Close match in top 10 results |

**Order by `(1 - confidence) × impact`.** Test the top row first. Subsequent rows wait until row 1 survives — no point hardening latency numbers for an idea nobody wants.

**Preferred test escalator** (cheapest first):

1. Five-line calculation / back-of-envelope
2. One user conversation
3. One-hour spike
4. Sketch or storyboard
5. Throwaway prototype

Only escalate when a cheaper test can't answer the question.

---

## Kill criteria must be measurable

Not: *"if it doesn't feel useful"* / *"if performance is bad"* / *"if nobody likes it"*

Yes: *"if p95 latency > 300ms on 10k rows"* / *"if <3 of 10 interview subjects say yes"* / *"if typos account for ≥70% of exit≠0 commands in my atuin DB"*

**Rule:** if you can't write the result of the experiment as a number or a yes/no, the kill criterion isn't tight enough yet. Keep sharpening until it is.

The point of the kill criterion is to commit *before* you see the data — otherwise motivated reasoning will rescue the idea after the fact.

---

## Lens switches (parallel thinking)

Do these as **separate passes**, not averaged into one "on balance" analysis. Averaging hides both the risks and the upside — the whole point is to see each clearly.

### Black hat — Pre-mortem (imagined failure)

> *"It's six months from now. This idea shipped and failed. Write the post-mortem."*

- What went wrong **first**?
- Which assumption turned out to be wrong?
- What did the team ignore that was obvious in hindsight?
- Who got hurt? What's the worst reasonable version of the damage?
- What external change (market, platform, regulation) made this fail?

Feed the answers back into the assumption table — any pre-mortem bullet that isn't already a row should become one.

### Yellow hat — Pre-parade (imagined success)

> *"It's six months from now. This idea worked beyond expectations. Write the retrospective."*

- What made this obvious in retrospect?
- Which single decision mattered most?
- Who became a fan first, and why?
- What second-order opportunities did this unlock?

Use this to identify the load-bearing decision — the one thing that, if gotten right, makes the rest easy. Protect it in Step 5 planning.

### Red hat — Gut check (optional, fast)

> *"In one sentence, how do you **feel** about this idea right now, without justifying it?"*

Used sparingly. A strong negative gut from the person who has to build it is a real signal, even when the spreadsheet says go. Skip if the user is clearly enthusiastic or clearly skeptical and coherent about why — it only adds value when the analytical lenses are ambiguous.

### White hat — Facts only

> *"Setting opinions aside: what do we actually know, what do we assume, and what do we need to find out?"*

This is the pass that produces the assumption list itself. Usually done first, feeding the table above.
