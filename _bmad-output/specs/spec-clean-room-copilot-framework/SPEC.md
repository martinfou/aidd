---
id: SPEC-clean-room-copilot-framework
companions:
  - roster-and-skills.md
  - state-and-contracts.md
  - quality-gates.md
sources:
  - ../../brainstorming/brainstorm-clean-room-agentic-framework-2026-11-14/brainstorm-intent.md
  - ../../brainstorming/brainstorm-clean-room-agentic-framework-2026-11-14/CLEAN_ROOM_BLUEPRINT.md
  - ../../brainstorming/brainstorm-clean-room-agentic-framework-2026-11-14/TASK_PACK_FOR_3_8.md
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# Clean-Room Copilot Agentic Delivery Framework (`.github/` + `.ai-flow/`)

## Why

Enterprise engineering teams restricted from installing external AI orchestration frameworks, background servers, or CLI runtimes need a clean-room, zero-install agentic delivery system for GitHub Copilot. Dropping `.github/` and `.ai-flow/` into any corporate repository provides deterministic workflow routing, role separation, brownfield onboarding, and verifiable quality gates using only native Copilot Markdown conventions and cross-platform shell pre-commit guards.

## Capabilities

- **CAP-1 — Portable Copilot-Native Installation**
  - **intent:** Developers can drop `.github/` and `.ai-flow/` into any repository to enable the full framework without installing servers, CLIs, or language runtimes.
  - **success:** `ls` and `grep` checks confirm all required `.github/` and `.ai-flow/` files exist with zero references to external runtimes or external framework names.

- **CAP-2 — GPS/Navigator Workflow Routing**
  - **intent:** Developers can invoke a single Navigator prompt/skill that inspects repository state and recommends the exact next persona or prompt to run.
  - **success:** Running the Navigator logic against sample states (missing conventions, `IN_REVIEW`, `IN_PROGRESS`, `READY`, or active `next_step`) deterministically outputs one unambiguous next action.

- **CAP-3 — Hybrid 6-Persona Agents & 6 Standalone Prompts**
  - **intent:** Copilot users can invoke 6 role-bounded custom agents (`.github/agents/*.agent.md`) and 6 cross-cutting slash prompts (`.github/prompts/*.prompt.md`) cloned from canonical Task 0 Golden References.
  - **success:** All 6 `.agent.md` files and 6 `.prompt.md` files (plus `.github/skills/gps-navigator/SKILL.md`) match the Golden Reference YAML frontmatter and section structure.

- **CAP-4 — Brownfield Repo Bootstrap**
  - **intent:** Developers can run Repo Bootstrap on an existing codebase to detect stack, CI, lint, and test commands into `.ai-flow/PROJECT_CONVENTIONS.md`.
  - **success:** `PROJECT_CONVENTIONS.md` is populated with the standardized `- **Test Command:** \`<cmd or NONE>\`` contract and initializes `INDEX.md` and `PROJECT_STATE.md`.

- **CAP-5 — Streamlined SDLC & Quick-Fix Fast-Track**
  - **intent:** Teams can execute the `Brief → Spec → Architecture → Story Packets → Implementation → Two-Hat Review` pipeline for features, or the `Quick-Fix` lane for small, low-risk tickets.
  - **success:** Templates for `brief`, `spec`, `architecture`, and self-contained `story-packet` (with `next_step:` frontmatter, AC, execution evidence, and review verdict) exist and support both standard and `lane: quick-fix` workflows.

- **CAP-6 — 3-Layer Cross-Platform Quality Gate**
  - **intent:** The framework prevents unverified or self-approved code changes from being marked `DONE` or committed on both Windows and macOS/Linux.
  - **success:** `developer.agent.md` forbids setting `DONE`; `qa-reviewer.agent.md` forbids editing feature code; and both `pre-commit.sh` and `pre-commit.ps1` pass a 3-case smoke test (pass, fail-missing-evidence, fail-missing-verdict).

- **CAP-7 — Retrospective & Roundtable Panel**
  - **intent:** Teams can run structured post-milestone retrospectives (updating `PROJECT_CONVENTIONS.md`) and multi-persona roundtable debates for hard trade-offs inside Copilot.
  - **success:** `retrospective.prompt.md` and `roundtable-panel.prompt.md` define deterministic inputs, role participation rules, and outputs.

## Constraints

- **Clean-room IP:** Zero external framework names, headers, terminology, or copyrights; 100% original corporate-friendly naming.
- **GitHub Copilot primary target:** All agents, prompts, skills, and global instructions must conform to `.github/copilot-instructions.md`, `.github/agents/*.agent.md`, `.github/prompts/*.prompt.md`, and `.github/skills/*/SKILL.md`.
- **Zero-runtime pure Markdown:** No servers, daemons, Python, Node, or custom CLI binaries; only pure Markdown plus optional POSIX `bash` and Windows `PowerShell` scripts for deterministic pre-commit guards.
- **Native-readable state:** State files (`INDEX.md`, `PROJECT_STATE.md`, `PROJECT_CONVENTIONS.md`) must use plain Markdown tables or simple key-value lines so both LLMs and `bash`/`PowerShell` parse them without YAML/TOML parser dependencies.
- **Golden Reference cloning:** Task 0 Golden References must lock file schemas before cloning remaining agents and prompts so lightweight models implement them without drift.

## Non-goals

- No background server, daemon, or persistent orchestrator loop.
- No Python, Node.js, or custom CLI binary dependencies.
- No complex YAML/TOML state-parsing libraries.
- No collapsed 4-persona model (the 6-persona roster is mandatory).

## Success signal

- A developer on Windows or macOS/Linux copies `.github/` and `.ai-flow/` into a corporate repo, runs Repo Bootstrap, executes a story through Developer and QA Reviewer, and verifies that `pre-commit.sh` / `pre-commit.ps1` blocks any `DONE` story commit lacking both `## Execution Evidence` and `## Review Verdict: APPROVED`.
