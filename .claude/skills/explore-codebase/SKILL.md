---
name: explore-codebase
description: Explore and document an unfamiliar codebase, producing a system overview with architecture diagrams, tech stack analysis, module map, and pattern guide. Use when user says "explain this system", "explain codebase", "explore codebase", or wants to understand an unfamiliar project.
---

# Explore Codebase

Produce four artifacts in `docs/codebase/` that give a developer complete orientation in an unfamiliar codebase.

## Artifacts

| File | Purpose |
|------|---------|
| `SYSTEM_OVERVIEW.md` | High-level architecture with Mermaid diagrams |
| `TECH_STACK.md` | Languages, frameworks, dependencies, tooling |
| `MODULES.md` | Module map with responsibilities and boundaries |
| `PATTERNS.md` | Architectural patterns, conventions, gotchas |

## Workflow

### Phase 1 — Scan (deterministic)

Run the bundled scripts to gather raw facts. These produce structured output the agent consumes.

```sh
REPO_ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$HOME/.claude/skills/explore-codebase/scripts"
bash "$SKILL_DIR/scan-structure.sh" "$REPO_ROOT"
bash "$SKILL_DIR/detect-stack.sh" "$REPO_ROOT"
bash "$SKILL_DIR/find-entrypoints.sh" "$REPO_ROOT"
```

Run all three scripts with the repo root as argument. Read their stdout — this is your raw data.

### Phase 2 — Analyze (agent-driven)

Using scan output as a map, read key files to build understanding:

- [ ] Read README, CONTRIBUTING, and any existing architecture docs
- [ ] Read entrypoints identified by the scan
- [ ] Trace the main request/data flow through the system
- [ ] Identify module boundaries (packages, services, layers)
- [ ] Note architectural patterns (MVC, hexagonal, event-driven, etc.)
- [ ] Spot conventions (naming, error handling, config management)
- [ ] Flag gotchas and non-obvious design decisions

Prioritize breadth over depth. Read widely before reading deeply.

### Phase 3 — Document

Create `docs/codebase/` and write the four artifacts.

**SYSTEM_OVERVIEW.md** must include:
- One-paragraph system description
- Mermaid diagram showing major components and their relationships
- Data flow diagram (Mermaid) showing how a request/event moves through the system
- External dependencies and integrations

**TECH_STACK.md** must include:
- Languages and versions
- Frameworks and libraries (with purpose)
- Build tools and CI/CD
- Infrastructure and deployment

**MODULES.md** must include:
- Table: module name, directory, responsibility, key interfaces
- Dependency diagram (Mermaid) showing module relationships
- For each module: 2-3 sentence description of what it owns

**PATTERNS.md** must include:
- Architectural patterns in use (with examples from the codebase)
- Coding conventions (naming, file organization, error handling)
- Testing patterns and test infrastructure
- "Things to know before changing code" — gotchas, implicit contracts, hidden coupling

### Phase 4 — Review

Present artifacts to the user. Ask:
- [ ] Does this match your understanding? Anything surprising?
- [ ] Any areas you want deeper coverage on?
- [ ] Should I trace a specific flow end-to-end?
