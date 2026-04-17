# Ubiquitous Language

Domain dictionary for the dotfiles project. Covers environment management, the skills library, and the Ralph automation system.

---

## Environment management

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Dotfiles** | Configuration files managed by GNU Stow that mirror `~/` structure and are symlinked into place | config files, settings |
| **Stow** | GNU Stow — the tool that creates symlinks from `~/.dotfiles/` into `~/`. Always symlink, never copy | symlinker, installer |
| **Brewfile** | The single source of truth for Homebrew formulae and casks | package list, dependencies |
| **fnm** | The Node.js version manager used in this project | nvm (explicitly rejected) |
| **init script** | `scripts/init.sh` — first-time setup: installs Homebrew, runs `brew bundle`, installs Claude Code, Bun, and Ollama, then runs `stow .` | setup script, bootstrap |
| **update script** | `scripts/update.sh` — repeatable updates: runs `brew upgrade`, `brew bundle`, updates Claude Code, Bun, and Ollama, then runs `stow .` | refresh, sync |

## Skills library

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Skill** | A reusable Claude Code capability defined by a `SKILL.md` file in `.claude/skills/`, invocable via `/skill-name` | plugin, extension, command |
| **SKILL.md** | The defining file for a skill — contains frontmatter (name, description) and instructions that Claude follows when the skill is invoked | skill config, skill definition |
| **Workflow skill** | A skill that belongs to the sequential planning-to-delivery pipeline: ideate → PRD → kanban → TDD → QA | core skill, pipeline skill |
| **Standalone skill** | A skill invocable at any time outside the main workflow (e.g. `/explore-codebase`, `/fix-bug`, `/triage-bug`) | utility skill, helper |

## Workflow

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Ideation** | The first workflow step: define the problem, feature, or refactor via `/ideate` | brainstorming, discovery |
| **PRD** | A GitHub issue (labeled `feature-prd`) that describes a complete feature with user stories and implementation decisions, created via `/prd` | spec, requirements doc, epic |
| **Slice** | A thin vertical GitHub issue (labeled `feature-step`) that cuts end-to-end through all layers, derived from a PRD via `/kanban` | ticket, task, story, horizontal slice |
| **Task list** | The checklist in a PRD issue body that references slices (e.g. `- [ ] #42`) | sub-issues, child issues, linked issues |
| **TDD** | The red-green-refactor development workflow used for implementation via `/tdd` | test-first, testing |
| **QA** | Interactive session where bugs are reported conversationally and filed as GitHub issues via `/qa` | testing, bug bash |

## Ralph automation

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Ralph** | The autonomous shell script (`ralph.sh`) that loops through slices, delegating only implementation to Claude inside a sandbox | runner, agent loop, orchestrator |
| **Iteration** | One pass through the Ralph loop: discover slice, branch, invoke Claude, test, PR | cycle, run, round |
| **Sandbox** | An isolated Docker container created by `sbx` in which Claude runs | container, environment, VM |
| **Config sync** | The idempotent `rsync -au` step that copies Claude config into the project before sandbox launch | setup, bootstrap, install |
| **Test gate** | The post-implementation check where Ralph runs the project's test suite before opening a PR | validation, CI check, test step |
| **Eligible slice** | An open slice issue that does not already have an open PR and is therefore available for Ralph to pick up | available issue, next issue, unworked slice |

## Actors

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Developer** | The human who manages dotfiles, invokes skills, invokes Ralph, reviews PRs, and merges | user, operator, engineer |
| **Claude** | The AI that executes skills and implements slices inside the sandbox using TDD | agent, AI, LLM |

## Relationships

- **Dotfiles** are managed by **Stow** and updated via the **update script**
- The **Brewfile** governs all Homebrew dependencies; the **init script** and **update script** both run `brew bundle`
- The **skills library** lives inside the dotfiles repo and is synced into projects via **config sync**
- **Workflow skills** form a pipeline: ideation → **PRD** → **slices** (via kanban) → **TDD** → **QA**
- A **PRD** contains a **task list** of one or more **slices**
- **Ralph** runs up to N **iterations**, each targeting one **eligible slice**
- Each **iteration** produces at most one PR (only if the **test gate** passes)
- **Claude** operates inside a **sandbox** and only does implementation — all git, GitHub, and testing is handled by **Ralph**
- A **slice** becomes ineligible once a PR is opened for it
- A failed **test gate** leaves the **slice** eligible for retry on the next **iteration**

## Flagged ambiguities

- **"issue"** was used interchangeably to mean both **PRD** and **slice**. These are distinct: a **PRD** is the parent feature description, while a **slice** is one vertical piece of implementation. Both are GitHub issues, but they carry different labels (`feature-prd` vs `feature-step`) and serve different purposes.
- **"loop"** was used to describe both the Ralph script's outer iteration loop and the in-session Ralph Loop plugin (which uses a stop hook). These are unrelated mechanisms. The Ralph Loop plugin is out of scope; **Ralph** refers exclusively to the shell script with script-level iteration control.
- **"retry"** could imply active retry logic, but Ralph has no explicit retry mechanism. A failed slice is simply still **eligible** on the next **iteration** because no PR was opened — this is a natural consequence of the eligibility filter, not a retry feature.
- **"skill"** could refer to the SKILL.md file, the directory containing it, or the invocable command. In this glossary, **skill** means the invocable capability; **SKILL.md** means the defining file.
