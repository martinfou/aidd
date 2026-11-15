# Companion: Roster & Skills Catalog

## 1. Global Instructions (`.github/copilot-instructions.md`)
- Must be ≤ 40 lines.
- Instructs Copilot to read `.ai-flow/PROJECT_CONVENTIONS.md` and `.ai-flow/INDEX.md`.
- Enforces the Two-Hat boundary (`Developer` cannot set `status: DONE`) and Evidence-First closure.

## 2. Core Custom Agents (`.github/agents/*.agent.md`)
Every `.agent.md` file clones the Golden Reference (`developer.agent.md`) schema:
- YAML frontmatter: `name`, `description`
- Sections: `## Role & Ownership`, `## Inputs`, `## Outputs`, `## Forbidden Actions`, `## Execution Checklist`

| Agent File | Ownership | Key Outputs | Hard Boundary |
| :--- | :--- | :--- | :--- |
| `analyst.agent.md` | Problem framing, stakeholder needs, discovery | `.ai-flow/work/briefs/*.md` | Cannot prescribe technical implementation |
| `pm.agent.md` | Scope, functional specs, edge cases, AC | `.ai-flow/work/specs/*.md`, Story AC | Cannot alter architectural boundaries |
| `architect.agent.md` | System boundaries, contracts, ADRs, constraints | `.ai-flow/work/architecture/*.md`, Story Constraints | Cannot write feature code during design |
| `ux-designer.agent.md` | User journeys, empty/loading/error states, a11y | UX sections in Specs & Story Packets | Must align to `PROJECT_CONVENTIONS.md` |
| `developer.agent.md` | Implementation, tests, terminal evidence capture | Code changes + `## Execution Evidence` | **Cannot** set story status to `DONE` |
| `qa-reviewer.agent.md` | Diff audit, test re-execution, AC verification | `## Review Verdict` + flip status to `DONE` | **Cannot** edit feature code |

## 3. Standalone Slash Prompts (`.github/prompts/*.prompt.md`)
Every `.prompt.md` file clones the Golden Reference (`gps-navigator.prompt.md`) schema:
- YAML frontmatter: `mode: agent`, `description`
- Sections: `## Purpose`, `## Inputs`, `## Deterministic Steps`, `## Output Format`

| Prompt File | Purpose |
| :--- | :--- |
| `gps-navigator.prompt.md` | Inspects `PROJECT_CONVENTIONS.md`, `PROJECT_STATE.md`, `INDEX.md`, `next_step:`, and `git status` to output 1 next action. Also mirrored at `.github/skills/gps-navigator/SKILL.md`. |
| `repo-bootstrap.prompt.md` | Scans manifests, CI, linters, and test runners to write `.ai-flow/PROJECT_CONVENTIONS.md` and initialize `INDEX.md` + `PROJECT_STATE.md`. |
| `quick-fix.prompt.md` | Fast-track lane for small fixes: creates `lane: quick-fix` story packet, applies fix, runs tests, logs `## Execution Evidence`. |
| `two-hat-review.prompt.md` | Runs `qa-reviewer` checklist comparing `git diff` + `## Execution Evidence` against Story AC before setting `DONE`. |
| `retrospective.prompt.md` | Post-milestone review extracting lessons and appending durable conventions to `PROJECT_CONVENTIONS.md`. |
| `roundtable-panel.prompt.md` | Multi-persona structured debate across relevant `.github/agents/*.agent.md` roles for hard trade-offs. |
