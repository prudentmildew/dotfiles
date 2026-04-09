# Ubiquitous Language

Domain glossary for the skills system — a collection of Claude Code skills for opinionated software engineering workflows, centered on the Ralph autonomous PRD implementation loop.

## Skill system

| Term                       | Definition                                                                                                        | Aliases to avoid           |
|----------------------------|-------------------------------------------------------------------------------------------------------------------|----------------------------|
| **Skill**                  | A Claude Code slash command backed by a `SKILL.md` file that defines the agent's contract for a specific workflow | Plugin, tool, command      |
| **SKILL.md**               | The declarative file that defines a skill's inputs, sequence, constraints, and outcomes                           | Config, spec               |
| **Progressive disclosure** | A skill authoring pattern where the SKILL.md reveals instructions in stages as the agent progresses               | Phased instructions        |
| **Deep module**            | A module with a small interface hiding substantial functionality, inspired by *A Philosophy of Software Design*   | Fat module, service        |
| **Shallow module**         | A module whose interface is nearly as complex as its implementation — the opposite of a deep module               | Thin wrapper, pass-through |

## Planning pipeline

| Term                            | Definition                                                                                                         | Aliases to avoid              |
|---------------------------------|--------------------------------------------------------------------------------------------------------------------|-------------------------------|
| **Feature explore**             | An exhaustive interview that walks every branch of a feature's decision tree until shared understanding is reached | Discovery, brainstorm         |
| **PRD**                         | A parent GitHub issue containing the product requirements document for a feature, produced by `/feature-prd`       | Spec, epic, RFC               |
| **Vertical slice**              | A thin end-to-end path through all integration layers, used to decompose a PRD into implementable units            | Story, task, horizontal layer |
| **Tracer bullet**               | Synonym for vertical slice, emphasizing that the first slice proves the architecture works end-to-end              | Spike, prototype              |
| **HITL**                        | A vertical slice requiring human-in-the-loop interaction (architectural decision, design review)                   | Manual step                   |
| **AFK**                         | A vertical slice that can be implemented and merged without human interaction                                      | Automated step                |
| **Child issue**                 | A GitHub issue implementing one vertical slice of a PRD, linked via `## Parent PRD` body reference                 | Subtask, sub-issue, ticket    |
| **Acceptance criteria**         | The `- [ ]` checklist on a child issue body; ground truth for "done"                                               | Requirements, checklist items |
| **Blocker**                     | An issue referenced in another issue's `## Blocked by` section; the dependent waits until the blocker closes       | Dependency, prerequisite      |
| **User story**                  | A requirement expressed as "As a \<role\>, I want \<feature\>, so that \<benefit\>" in the PRD                     | Requirement, use case         |
| **Implementation Status block** | An `## Implementation Status` checklist Ralph maintains in the PRD body, one line per child issue                  | Status, progress, changelog   |

## The Ralph loop

| Term                   | Definition                                                                                                        | Aliases to avoid            |
|------------------------|-------------------------------------------------------------------------------------------------------------------|-----------------------------|
| **Ralph loop**         | The autonomous loop that drives a PRD to completion by executing one iteration at a time                          | The script, the runner      |
| **Loop controller**    | `ralph.sh` — the bash process that picks the next child issue, spawns the iteration, and enforces stop conditions | Driver, orchestrator        |
| **Iteration**          | One pass through the loop: pick eligible issue → spawn subprocess → observe outcome → log                         | Pass, cycle, round, step    |
| **Eligibility module** | The deep bash function that returns the ascending list of eligible open child issues for a PRD                    | Picker, selector            |
| **Eligible**           | An open child issue whose Parent PRD matches and whose every blocker is closed                                    | Ready, available, unblocked |
| **ralph-iterate**      | The skill (`SKILL.md`) executed inside one iteration; implements one child issue end-to-end                       | The agent, the worker       |
| **Subprocess**         | A fresh `claude -p` invocation; each iteration runs in its own subprocess to prevent context rot                  | Child claude, agent process |

## Iteration ceremony

| Term                   | Definition                                                                                                                             | Aliases to avoid                  |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| **Ceremony**           | The fixed step sequence ralph-iterate executes: read → /tdd → commit → tick → comment → close → update PRD                             | Workflow, recipe                  |
| **Red-green-refactor** | The TDD cycle: write a failing test (red), make it pass (green), improve the code (refactor)                                           | Test-first, TDD loop              |
| **Tick**               | Flipping a `- [ ]` acceptance-criterion box to `- [x]` because the behavior is actually satisfied                                      | Check, mark                       |
| **Summary comment**    | A comment ralph-iterate posts on a child issue describing what was done and what remains                                               | Status comment, changelog comment |
| **Closure comment**    | The one-line comment ralph-iterate posts on the PRD when a child issue is closed                                                       | PRD comment                       |
| **Hard denylist**      | The non-negotiable prompt-level prohibitions (no push, no force, no editing `.github/` or `ralph-iterate/`, no closing the parent PRD) | Guardrails, safety rules          |

## Iteration outcomes

| Term                     | Definition                                                                                                                                 | Aliases to avoid           |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|----------------------------|
| **Closed**               | All acceptance criteria ticked, child issue closed, PRD body and comments updated                                                          | Done, finished             |
| **Partial progress**     | A commit landed and some criteria ticked, but not all; child issue stays open with a partial-progress comment                              | Half-done, WIP, incomplete |
| **Rollback**             | The iteration's edits are reverted with `git checkout --` because the working tree was in a broken-syntax state; no GitHub mutation occurs | Failed, abort, revert      |
| **Zero-close iteration** | An iteration whose open-children count did not decrease (covers both partial progress and rollback)                                        | Stalled iteration          |

## Stop conditions

| Term                   | Definition                                                                                      | Aliases to avoid               |
|------------------------|-------------------------------------------------------------------------------------------------|--------------------------------|
| **Dirty tree refusal** | The loop controller exits immediately if `git status --porcelain` is non-empty at start         | Clean check                    |
| **Stuck detector**     | Exit when two consecutive zero-close iterations occur; a single zero-close iteration is allowed | Stall guard, no-progress check |
| **Blocked exit**       | Exit when open children remain but none are eligible (cycle or external blocker)                | Deadlock, dead-end             |
| **PRD complete**       | Exit 0 when all children are closed                                                             | Done state                     |

## Execution environment

| Term                 | Definition                                                                                                | Aliases to avoid                          |
|----------------------|-----------------------------------------------------------------------------------------------------------|-------------------------------------------|
| **Docker mode**      | Opt-in execution of Claude inside a Docker container via `--docker` flag and `docker sandbox run claude`  | Sandbox mode, containerized mode          |
| **Bind mount**       | A host directory or file made available inside the Docker container (repo RW, credentials RO)             | Volume, mount point                       |
| **RALPH_CLAUDE_CMD** | Environment variable that overrides the default Claude invocation command in both Docker and local modes  | —                                         |
| **Base branch**      | The git branch ralph.sh was invoked on, used as the branch point for all issue branches and the PR target | Main branch, target branch, parent branch |
| **Issue branch**     | A git branch named `ralph/<issue-number>` where implementation of a single child issue accumulates        | Feature branch, work branch, PR branch    |
| **Worktree**         | An isolated git working tree created by `--worktree`, providing git isolation orthogonal to Docker mode   | Workspace                                 |
| **Dry-run**          | `--dry-run` mode: run discovery and eligibility, print what would happen, never spawn `claude -p`         | Plan mode, preview                        |

## Terminal output

| Term              | Definition                                                                                                | Aliases to avoid           |
|-------------------|-----------------------------------------------------------------------------------------------------------|----------------------------|
| **Banner**        | A formatted status block printed before each iteration showing iteration count, issue, branch, and counts | Header, status line        |
| **Outcome line**  | A one-line result printed after each iteration showing the outcome and duration                           | Result line, status update |
| **Summary table** | A formatted table printed at loop exit showing all iterations, their issues, and outcomes                 | Report, results table      |

## Logs

| Term              | Definition                                                                                                | Aliases to avoid    |
|-------------------|-----------------------------------------------------------------------------------------------------------|---------------------|
| **Iteration log** | Per-iteration `tee`'d transcript at `.ralph/logs/<prd>/iter-<NNN>-issue-<MM>.log`                         | Run log, transcript |
| **Summary log**   | One-line-per-iteration ledger at `.ralph/logs/<prd>/summary.log` recording iter, issue, outcome, duration | History, ledger     |

## Relationships

- A **PRD** has zero or more **child issues**, discovered by parsing `## Parent PRD` body references.
- A **child issue** has zero or more **blockers**, parsed from its `## Blocked by` section.
- A **child issue** is either **HITL** or **AFK**, determined during planning.
- The **eligibility module** returns child issues that are open AND match the PRD AND have all blockers closed.
- One **iteration** of the **Ralph loop** picks exactly one **eligible** child issue and spawns one `claude -p` **subprocess** running **ralph-iterate**.
- One **iteration** produces exactly one **outcome**: **closed**, **partial progress**, or **rollback**.
- A **closed** outcome triggers creation of one PR from the **issue branch** to the **base branch** (handled by the **loop controller**, not by **ralph-iterate**).
- The **stuck detector** trips on two consecutive **zero-close iterations**, so partial progress followed by closed is a normal happy path.
- The **loop controller** never modifies the PRD body or issues; only **ralph-iterate** does (and only within the active PRD's child set).
- The **loop controller** owns all remote git operations (push, PR creation); **ralph-iterate** is forbidden from pushing via the **hard denylist**.
- **Docker mode** and **worktree** compose orthogonally — Docker provides process isolation, worktree provides git isolation.

## Example dialogue

> **Dev:** "I started the **Ralph loop** on **PRD** #1 with `--docker` and the first **iteration** committed code but didn't close the **child issue**. Did it crash?"

> **Domain expert:** "No — that's **partial progress**. The **ralph-iterate** **ceremony** only **ticks** the **acceptance criteria** that are actually satisfied. If any remain unchecked, the child issue stays open with a **summary comment** describing what's left."

> **Dev:** "So the commits are on an **issue branch**?"

> **Domain expert:** "Right. The **loop controller** created `ralph/17` from the **base branch** before spawning the **subprocess**. The partial commits accumulate there. Next iteration, the **loop controller** checks out the same **issue branch** and continues."

> **Dev:** "And since I used `--docker`, Claude ran inside a container with my credentials **bind-mounted** read-only?"

> **Domain expert:** "Exactly. **Docker mode** is just process isolation — the **loop controller** still handles pushing and PR creation. When the issue eventually reaches **closed**, the **loop controller** pushes `ralph/17` and creates a PR targeting the **base branch**."

> **Dev:** "What if `/tdd` produces broken bash inside the container?"

> **Domain expert:** "Then **ralph-iterate** does a **rollback** — `git checkout --` on every modified file, and crucially no GitHub mutation. No **tick**, no **summary comment**, no close. The next **iteration** starts from a clean slate. If two **consecutive** iterations produce **zero-close**, the **stuck detector** trips and the loop exits."

## Flagged ambiguities

- **"issue"** is overloaded — depending on context, it can mean the **PRD** itself or a **child issue**. Prefer the specific term; reserve bare "issue" for cases where both are in scope.

- **"the agent"** has been used loosely for both the parent Claude session running the **loop controller** and the **subprocess** running **ralph-iterate**. Prefer **loop controller** for `ralph.sh` and **ralph-iterate** (or **subprocess**) for what runs inside `claude -p`.

- **"blocked"** appears in two distinct senses: (a) an issue's `## Blocked by` body section (a per-issue dependency), and (b) the **blocked exit** condition of the loop (no eligible work remains). The former is structural, the latter is a runtime stop condition.

- **"sandbox"** was used to mean both Docker container isolation and git worktree isolation. These are distinct: **Docker mode** provides process isolation (Claude runs in a container), while a **worktree** provides git isolation (separate working tree). They compose orthogonally. Use the specific term, not "sandbox."

- **"step"** appeared in early discussion to mean both an implementation step (what we call an **iteration**) and a feature step (what we call a **child issue** or **vertical slice**). Use **iteration** for a single Claude invocation and **child issue** for the unit of work.

- **"branch"** appeared without qualification to mean both the branch ralph.sh was started on (**base branch**) and the per-issue working branch (**issue branch**). Always qualify which branch is meant.

- **"slice"** vs **"child issue"** — these are nearly synonymous but emphasise different facets: **slice** is the *kind of work* (a thin vertical cut), **child issue** is the *artefact* on GitHub. Pick one based on whether you're talking about scoping or about a specific GitHub object.

- **"failed"** appeared informally for the **rollback** outcome. Prefer **rollback** — it's more precise (the working tree was restored to HEAD, not that something crashed). A Claude crash with no commit is also technically a rollback from the loop's perspective.
