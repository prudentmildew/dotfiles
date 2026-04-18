# Ideate — Prompts for Frame and Diverge

Load this file when Step 1 (Frame) or Step 2 (Diverge) calls for structured prompts to break fixation. Use the minimum needed; don't walk the user through every tool on the page.

For Step 5 (Verify) mechanics — assumption tables, pre-mortems, kill criteria — see [verify.md](verify.md) instead.

---

## "What would you do instead?" (Step 1 — Frame)

The highest-leverage framing question. Ask this before any heavier framework.

> *"If this idea didn't exist, what would you (or the user) do instead?"*

Follow-ups:

- What's the current workaround, even if it's a spreadsheet, a friend, a Post-it, or nothing?
- Why hasn't the workaround been good enough? What specifically fails about it?
- Have they tried a dedicated solution before and abandoned it? Why?

The answer is almost always more informative than the original idea, because it reveals what the user is *actually* doing in the problem space today, not what they imagine they'd do.

---

## 5 Whys (Step 1 — Frame)

Ask "why?" up to five times to drive from symptom to root cause. Stop when the answer becomes a value or constraint rather than a further cause.

Example:

1. I want to build a CLI for X. *Why?*
2. Because the web UI is slow. *Why is that a problem?*
3. Because I use it 50 times a day. *Why 50 times?*
4. Because I'm context-switching between tools. *Why?*
5. Because my workflow spans three systems that don't talk to each other. **← real problem may be integration, not CLI.**

Watch out: 5 Whys can railroad toward a single cause. If multiple causes are plausible, branch the tree instead.

---

## Jobs-to-be-Done (Step 1 — Frame)

From Christensen / Ulwick. Reframes "what feature does the user want?" as "what *job* is the user hiring this idea to do?"

> **"When ____, I want to ____, so I can ____."**

Follow-ups:

- What was the user doing *five minutes before* they needed this? What triggered the need?
- What are they doing *right now instead*? What would they **fire** that solution for doing?
- Are there *functional*, *emotional*, and *social* dimensions to the job? (A luxury watch's functional job is telling time; its social job is signaling status.)

> **Note for personal / single-user / dev-tool ideas:** JTBD can feel corporate-theater when the "user" is just the person sitting next to you. In those cases, "what would you do instead?" and 5 Whys often produce sharper framings faster. Reach for JTBD when the idea has a distinct user who isn't the builder.

---

## SCAMPER (Step 2 — Diverge)

Checklist from Bob Eberle (1971). Apply each verb to the current candidate to generate variations.

- **S — Substitute:** swap a component, material, person, or rule.
- **C — Combine:** merge with another product, workflow, or user segment.
- **A — Adapt:** borrow from a different domain (How does Spotify handle this? A library? A hospital?).
- **M — Modify / Magnify / Minify:** 10× bigger, smaller, faster, slower, more extreme.
- **P — Put to other use:** who else could use this, for a different purpose?
- **E — Eliminate:** what could be removed entirely? (Often the most productive prompt.)
- **R — Reverse / Rearrange:** flip the order; swap who does the work.

Don't do all seven every time. Pick the 2–3 most likely to produce a genuinely different shape.

---

## Analogy prompts (Step 2 — Diverge)

Useful when the user is stuck inside one mental model.

- **Domain transfer:** "How would a [bank / game studio / hospital / restaurant / newsroom / power grid / toddler] solve this?"
- **Scale transfer:** "How would this work if there were 10 users? 10 million? 1?"
- **Time transfer:** "How would someone have solved this in 1995? In 2050?"
- **Medium transfer:** "What's the physical-world / paper / board-game version of this?"
- **Forced metaphor:** "Finish the sentence: 'This idea is like ___, because ___.'" Then examine what the metaphor implies.

---

## Inversion prompts (Step 2 — Diverge, or Step 5 — Verify)

Solving the opposite problem is often easier and more revealing.

- **"What would make this problem *worse*?"** → invert each answer to get an intervention.
- **"How would I *guarantee* this idea fails?"** → avoid each path.
- **"If I wanted the opposite outcome, what would I build?"** → contrast clarifies what you actually want.
- **"What would the laziest / most expensive / most dishonest version look like?"** → reveals which constraints are load-bearing.

---

## When none of these help

If the user is stuck and no prompt is moving them, the problem is usually one of:

1. **The framing is wrong** — go back to Step 1.
2. **They don't actually want to do this** — ask directly. Sometimes the best outcome is "don't build this."
3. **They need information, not more thinking** — jump to Step 3 (Research) and come back.
