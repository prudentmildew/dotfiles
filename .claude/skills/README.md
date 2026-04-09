# Erland's skills

A collection of custom [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills for opinionated software engineering workflows.

## Skills

| Skill                    | Command                          | What it does                                                                   |
|--------------------------|----------------------------------|--------------------------------------------------------------------------------|
| **Feature Explore**      | `/feature-explore`               | Interview you about a feature until every decision branch is resolved          |
| **Feature PRD**          | `/feature-prd`                   | Create a PRD through interview + codebase exploration, filed as a GitHub issue |
| **Feature Plan**         | `/feature-plan`                  | Break a PRD into vertical-slice GitHub issues (tracer bullets)                 |
| **TDD**                  | `/tdd`                           | Red-green-refactor loop with behavior-driven tests                             |
| **Triage Issue**         | `/triage-issue`                  | Investigate a bug, find root cause, file a GitHub issue with a TDD fix plan    |
| **QA**                   | `/qa`                            | Conversational QA session — report bugs, get GitHub issues                     |
| **Refactor Plan**        | `/request-refactor-plan`         | Plan a refactor as tiny safe commits, filed as a GitHub issue                  |
| **Improve Architecture** | `/improve-codebase-architecture` | Find shallow modules and propose deeper, more testable designs                 |
| **Ubiquitous Language**  | `/ubiquitous-language`           | Extract a DDD glossary from conversation into `UBIQUITOUS_LANGUAGE.md`         |
| **Ralph Iterate**        | `/ralph-iterate <prd> <issue>`   | Implement a single child issue of a PRD end-to-end (TDD, commit, close)        |
| **Write a Skill**        | `/write-a-skill`                 | Scaffold a new skill with proper structure                                     |

## Design Principles

These skills share a few opinions:

- **Deep modules** — small interfaces hiding big implementations, inspired by *A Philosophy of Software Design*
- **Vertical slices** — tracer bullets that cut through all layers end-to-end
- **Behaviour-driven tests** — test what the code does through public interfaces, not how it's wired
- **Mock only at boundaries** — external APIs, databases, time; never your own code
- **Tiny commits** — each refactor step is independently safe and reviewable

## Setup

1. Clone this repo
2. Skills are automatically available as slash commands in Claude Code when run from this directory
