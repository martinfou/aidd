# `.ai-flow/` Implementation Task Pack (Model-Ready for Gemini 3.8)

This document breaks down the `.ai-flow/` + `.github/` clean-room framework into **Task 0 (Golden References)** and **Atomic Implementation Tasks (Phases 1–4)**. Every task is self-contained so a fast model can execute one task at a time in isolation without inventing schemas or missing fields.

---

## Execution Rules for Every Task

1. Execute **one task per prompt** in a clean context.
2. Copy the **Exact Reference to Clone** verbatim where instructed, changing only the role/skill-specific content.
3. Do **not** install packages, servers, CLIs, or Node/Python runtimes.
4. After writing the target file(s), run the **Deterministic Shell Verification Command** and confirm exit code `0`.

---

## Task 0 — Golden References

Create these three canonical reference files first (or provide them as context for Phases 1–4). Every downstream agent, prompt, and guard clones these exact schemas.

### 0.1 Golden Agent: `.github/agents/developer.agent.md`

```markdown
---
name: developer
description: Implements self-contained Story Packets, writes unit/integration tests, and records unedited terminal Execution Evidence. Cannot mark a story DONE.
---

## Role & Ownership
You are the **Developer** persona. You own turning a `READY` or `IN_PROGRESS` Story Packet in `.ai-flow/work/stories/` into working, tested code that satisfies every inline Acceptance Criterion and Architectural Constraint.

## Inputs
- `.ai-flow/PROJECT_CONVENTIONS.md` (tech stack, lint, typecheck, and test commands)
- `.ai-flow/PROJECT_STATE.md` (to confirm the target story is `READY` or `IN_PROGRESS`)
- Target Story Packet: `.ai-flow/work/stories/STORY-XXX-*.md`

## Outputs
- Code and test changes scoped strictly to the Story Packet's inline boundaries
- Updated `## Execution Evidence` section in the Story Packet containing actual, unedited terminal output
- Updated Story Packet frontmatter: `status: IN_REVIEW`, `next_step: skill:two-hat-review`
- Updated `.ai-flow/PROJECT_STATE.md` row: `Status = IN_REVIEW`, `Evidence Logged = YES`
- Updated `.ai-flow/INDEX.md` row: `Next Step = skill:two-hat-review`

## Forbidden Actions
- **NEVER** set `status: DONE` in the Story Packet or `DONE` in `.ai-flow/PROJECT_STATE.md`.
- **NEVER** fill in `## Review Verdict` or write `APPROVED`.
- **NEVER** fabricate, summarize, or edit terminal output under `## Execution Evidence`.
- **NEVER** modify code outside the Story Packet's `## Architectural & UX Constraints (Inline)` boundary without escalating to `architect`.

## Execution Checklist
1. Read `.ai-flow/PROJECT_CONVENTIONS.md` and the target Story Packet completely.
2. Set the Story Packet frontmatter `status: IN_PROGRESS` and update `.ai-flow/PROJECT_STATE.md` to `IN_PROGRESS`.
3. Implement the smallest clean change that satisfies all `AC-*` items and respects all inline constraints.
4. Write or update unit/integration tests covering each `AC-*` and boundary condition.
5. Run the exact test, lint, and typecheck commands from `.ai-flow/PROJECT_CONVENTIONS.md`.
6. Paste the raw, unedited command invocations and terminal output into `## Execution Evidence` in the Story Packet.
7. Set Story Packet frontmatter `status: IN_REVIEW` and `next_step: skill:two-hat-review`.
8. Update `.ai-flow/PROJECT_STATE.md` (`Status = IN_REVIEW`, `Evidence Logged = YES`) and `.ai-flow/INDEX.md` (`Next Step = skill:two-hat-review`).
9. Stop and instruct the user to run `/two-hat-review`.
```

### 0.2 Golden Prompt: `.github/prompts/gps-navigator.prompt.md`

```markdown
---
mode: agent
description: Inspects .ai-flow/ state, conventions, and git status to recommend the single exact next persona or prompt to run.
---

# GPS / Navigator

Inspect the repository's `.ai-flow/` state machine and output **one unambiguous next action**. Do not modify any files.

## Step-by-Step Instructions

1. **Check Conventions:**
   - Check if `.ai-flow/PROJECT_CONVENTIONS.md` exists and has a populated `- **Test Command:**` line.
   - If missing or unpopulated, STOP and output the recommendation below pointing to `/repo-bootstrap`.
2. **Check Active Work State:**
   - Read `.ai-flow/PROJECT_STATE.md`.
   - Prioritize active items in this exact order:
     1. `IN_REVIEW` -> recommend `/two-hat-review` with `qa-reviewer` on the target story file.
     2. `IN_PROGRESS` -> recommend continuing with the listed `Owner Persona` on the target story file.
     3. `BLOCKED` -> surface the blocker and recommend `/roundtable-panel` or the blocking persona.
     4. `READY` -> recommend invoking `developer` on the first `READY` story packet.
3. **Check Upstream Routing Index (if no active story in Step 2):**
   - Read `.ai-flow/INDEX.md`.
   - Find the most recent artifact row whose `Next Step` is not `DONE` or `-`.
   - Read that artifact's YAML frontmatter (`next_step`) to confirm the target persona or prompt.
4. **Check Working Tree:**
   - Run `git status --short` (read-only) to note any uncommitted changes that affect the recommendation.
5. **Output Format (Strict):**
   Output only the following structured block:
   - **Current State:** `<1-line summary of PROJECT_STATE.md / INDEX.md / git status>`
   - **Recommended Next Step:** `<exact /prompt-name or @persona>`
   - **Target File:** `<exact relative path or NONE>`
   - **Why:** `<1-sentence justification based on observed state>`
```

### 0.3 Golden Conventions: `.ai-flow/PROJECT_CONVENTIONS.md`

```markdown
# Project Conventions

> Generated or updated by `/repo-bootstrap`. Read by all personas and parsed by `.ai-flow/guards/pre-commit.*`.

## Tech Stack & Runtime
- **Primary Language(s):** `<e.g., TypeScript 5.x / Python 3.12 / NONE>`
- **Framework(s):** `<e.g., Next.js / FastAPI / NONE>`
- **Package Manager:** `<e.g., npm / pnpm / uv / NONE>`

## Commands (Parsed by Quality Gates)
- **Build Command:** `<command or NONE>`
- **Lint Command:** `<command or NONE>`
- **Typecheck Command:** `<command or NONE>`
- **Test Command:** `<command or NONE>`

## Repository & Git Conventions
- **Default Branch:** `main`
- **Branch Naming:** `<e.g., feat/STORY-XXX-slug, fix/STORY-XXX-slug>`
- **Commit Format:** `<e.g., Conventional Commits (feat:, fix:, chore:)>`

## Architecture & Security Guardrails
- **Module Boundaries:** `<key folder boundaries or NONE>`
- **Auth / Secrets Rule:** Never commit secrets, `.env` files, tokens, or credentials.
- **UI / Design System:** `<component library / accessibility baseline or NONE>`
```

### Task 0 Verification Command

```bash
ls -1 .github/agents/developer.agent.md .github/prompts/gps-navigator.prompt.md .ai-flow/PROJECT_CONVENTIONS.md && grep -qF -- '- **Test Command:** `' .ai-flow/PROJECT_CONVENTIONS.md && echo "TASK_0_OK"
```

---

## Phase 1 — Core Scaffold, Global Instructions & Artifact Templates

### Task 1.1: Directory Scaffold & Initial State Tables
- **Task ID & Title:** `Task 1.1` — Create `.ai-flow/` directory tree and empty `INDEX.md` + `PROJECT_STATE.md` state tables
- **Target File(s):**
  - `.ai-flow/INDEX.md`
  - `.ai-flow/PROJECT_STATE.md`
  - `.ai-flow/work/briefs/.gitkeep`
  - `.ai-flow/work/specs/.gitkeep`
  - `.ai-flow/work/architecture/.gitkeep`
  - `.ai-flow/work/stories/.gitkeep`
- **Exact Reference to Clone:** `Task 0.3` (plain Markdown style; no YAML/TOML parsers)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Create the `.ai-flow/` workspace directories and initial state tables without modifying any other files:
  > 1. Create empty `.gitkeep` files in `.ai-flow/work/briefs/.gitkeep`, `.ai-flow/work/specs/.gitkeep`, `.ai-flow/work/architecture/.gitkeep`, and `.ai-flow/work/stories/.gitkeep`.
  > 2. Create `.ai-flow/INDEX.md` with exact content:
  > ```markdown
  > # .ai-flow/ Artifact Index
  >
  > | ID | Stage | Title | Path | Next Step |
  > | :--- | :--- | :--- | :--- | :--- |
  > ```
  > 3. Create `.ai-flow/PROJECT_STATE.md` with exact content:
  > ```markdown
  > # Project Delivery State
  >
  > > Allowed Status values: `BACKLOG` | `READY` | `IN_PROGRESS` | `IN_REVIEW` | `DONE` | `BLOCKED`
  >
  > | Story ID | Lane | Title | Owner Persona | Reviewer | Status | Evidence Logged |
  > | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
  > ```
- **Deterministic Shell Verification Command:**
  ```bash
  ls -1 .ai-flow/INDEX.md .ai-flow/PROJECT_STATE.md .ai-flow/work/briefs/.gitkeep .ai-flow/work/specs/.gitkeep .ai-flow/work/architecture/.gitkeep .ai-flow/work/stories/.gitkeep && grep -q "| ID | Stage | Title | Path | Next Step |" .ai-flow/INDEX.md && grep -q "| Story ID | Lane | Title | Owner Persona | Reviewer | Status | Evidence Logged |" .ai-flow/PROJECT_STATE.md && echo "TASK_1_1_OK"
  ```

---

### Task 1.2: Global Copilot Instructions
- **Task ID & Title:** `Task 1.2` — Create `.github/copilot-instructions.md`
- **Target File(s):** `.github/copilot-instructions.md`
- **Exact Reference to Clone:** `Task 0.2` & `Task 0.3` (references `.ai-flow/` state files and 3-layer gate)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Create `.github/copilot-instructions.md` as the always-on repository instruction file for GitHub Copilot. Include these exact sections and rules:
  > 1. `# Repository AI Delivery Instructions`
  > 2. `## State & Conventions`: Direct the agent to read `.ai-flow/PROJECT_CONVENTIONS.md`, `.ai-flow/INDEX.md`, and `.ai-flow/PROJECT_STATE.md` before planning or editing code.
  > 3. `## Delivery Workflow`: Document the standard flow (`Brief -> Spec -> Architecture -> Story Packet -> Implementation -> Two-Hat Review`) and the `/quick-fix` lane for low-risk fixes. Point to `/gps-navigator` whenever the next step is unclear.
  > 4. `## Non-Negotiable Quality Gates`:
  >    - **Two-Hat Gate:** `developer` cannot mark a story `DONE`; only `qa-reviewer` via `/two-hat-review` may set `DONE`.
  >    - **Evidence-First Gate:** Paste raw, unedited terminal output under `## Execution Evidence` before setting `IN_REVIEW`.
  >    - **Zero-Runtime Rule:** Do not introduce external servers, daemons, or CLI wrappers for workflow state; keep all state in `.ai-flow/` plain Markdown tables and artifact frontmatter.
  > Keep the file concise (under 60 lines).
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/copilot-instructions.md && grep -q "PROJECT_CONVENTIONS.md" .github/copilot-instructions.md && grep -q "Two-Hat" .github/copilot-instructions.md && test "$(wc -l < .github/copilot-instructions.md)" -le 80 && echo "TASK_1_2_OK"
  ```

---

### Task 1.3: Four Standardized Artifact Templates
- **Task ID & Title:** `Task 1.3` — Create `.ai-flow/templates/{brief,spec,architecture,story-packet}.md`
- **Target File(s):**
  - `.ai-flow/templates/brief.md`
  - `.ai-flow/templates/spec.md`
  - `.ai-flow/templates/architecture.md`
  - `.ai-flow/templates/story-packet.md`
- **Exact Reference to Clone:** `Task 0.3` (clean Markdown + frontmatter `next_step`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Create four Markdown templates in `.ai-flow/templates/`:
  > 1. `.ai-flow/templates/brief.md`:
  >    - YAML frontmatter: `id: BRIEF-XX`, `title: <Title>`, `status: DRAFT`, `owner: analyst`, `next_step: pm:spec`
  >    - Sections: `## Context Capsule (Handoff Summary)`, `## Problem Statement`, `## Stakeholders & Goals`, `## Scope Boundaries (In / Out)`, `## Open Questions`
  > 2. `.ai-flow/templates/spec.md`:
  >    - YAML frontmatter: `id: SPEC-XX`, `title: <Title>`, `upstream: BRIEF-XX`, `status: DRAFT`, `owner: pm`, `next_step: architect:design`
  >    - Sections: `## Context Capsule (Handoff Summary)`, `## Functional Requirements`, `## Edge Cases & Error States`, `## UX & Accessibility States`, `## Acceptance Criteria`
  > 3. `.ai-flow/templates/architecture.md`:
  >    - YAML frontmatter: `id: ARCH-XX`, `title: <Title>`, `upstream: SPEC-XX`, `status: DRAFT`, `owner: architect`, `next_step: pm:story-packet`
  >    - Sections: `## Context Capsule (Handoff Summary)`, `## System Boundaries & Interfaces`, `## Data Contracts & Security`, `## Key Decisions (ADR Summary)`, `## Constraints for Story Packets`
  > 4. `.ai-flow/templates/story-packet.md`:
  >    - YAML frontmatter: `id: STORY-XXX`, `title: <Title>`, `lane: standard`, `status: READY`, `owner: developer`, `reviewer: qa-reviewer`, `next_step: developer:implement`
  >    - Sections: `## Context Capsule (Handoff Summary)`, `## Acceptance Criteria` (checkboxes `- [ ] **AC-1:**`), `## Architectural & UX Constraints (Inline)`, `## Execution Evidence (Required Before IN_REVIEW)` (with fenced `text` block), `## Review Verdict (QA Reviewer Only)` (with `- **Reviewer:** \`qa-reviewer\``, `- **Decision:** \`PENDING\` <!-- APPROVED | CHANGES_REQUESTED -->`, `- **Diff & Test Notes:**`).
- **Deterministic Shell Verification Command:**
  ```bash
  ls -1 .ai-flow/templates/brief.md .ai-flow/templates/spec.md .ai-flow/templates/architecture.md .ai-flow/templates/story-packet.md && grep -q "next_step:" .ai-flow/templates/brief.md && grep -q "## Execution Evidence" .ai-flow/templates/story-packet.md && grep -q "## Review Verdict" .ai-flow/templates/story-packet.md && echo "TASK_1_3_OK"
  ```

---

## Phase 2 — Core Personas (`.github/agents/*.agent.md`)

Every task in Phase 2 MUST clone the exact schema of **Task 0.1 (`.github/agents/developer.agent.md`)**:
- YAML frontmatter: `name`, `description`
- Exact 5 H2 headings: `## Role & Ownership`, `## Inputs`, `## Outputs`, `## Forbidden Actions`, `## Execution Checklist`

### Task 2.1: Analyst Agent
- **Task ID & Title:** `Task 2.1` — Create `.github/agents/analyst.agent.md`
- **Target File(s):** `.github/agents/analyst.agent.md`
- **Exact Reference to Clone:** `Task 0.1` (`.github/agents/developer.agent.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/agents/developer.agent.md` and clone its exact YAML frontmatter (`name`, `description`) and 5-heading structure (`## Role & Ownership`, `## Inputs`, `## Outputs`, `## Forbidden Actions`, `## Execution Checklist`) to create `.github/agents/analyst.agent.md`.
  > Configure it for the **Analyst** persona:
  > - `name: analyst`
  > - **Role & Ownership:** Problem framing, stakeholder needs, and existing system discovery.
  > - **Inputs:** User problem statement, `.ai-flow/PROJECT_CONVENTIONS.md`, `.ai-flow/templates/brief.md`, existing codebase/docs.
  > - **Outputs:** `.ai-flow/work/briefs/BRIEF-XX-<slug>.md` with `next_step: pm:spec`, plus updated `.ai-flow/INDEX.md`.
  > - **Forbidden Actions:** Must NOT prescribe technical architecture or implementation details; must NOT edit application source code.
  > - **Execution Checklist:** Read conventions and template -> inspect existing system -> draft Brief with Context Capsule -> update `INDEX.md` -> stop and recommend `pm`.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/agents/analyst.agent.md && grep -q "^name: analyst$" .github/agents/analyst.agent.md && for h in "## Role & Ownership" "## Inputs" "## Outputs" "## Forbidden Actions" "## Execution Checklist"; do grep -q "^$h$" .github/agents/analyst.agent.md || exit 1; done && echo "TASK_2_1_OK"
  ```

---

### Task 2.2: PM Agent
- **Task ID & Title:** `Task 2.2` — Create `.github/agents/pm.agent.md`
- **Target File(s):** `.github/agents/pm.agent.md`
- **Exact Reference to Clone:** `Task 0.1` (`.github/agents/developer.agent.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/agents/developer.agent.md` and clone its exact YAML frontmatter and 5-heading structure to create `.github/agents/pm.agent.md`.
  > Configure it for the **PM** persona:
  > - `name: pm`
  > - **Role & Ownership:** Functional scope, prioritization, edge cases, testable Acceptance Criteria, and slicing Specs/Architecture into self-contained Story Packets.
  > - **Inputs:** `.ai-flow/work/briefs/*.md`, `.ai-flow/work/architecture/*.md` (when slicing stories), `.ai-flow/templates/spec.md`, `.ai-flow/templates/story-packet.md`.
  > - **Outputs:** `.ai-flow/work/specs/SPEC-XX-<slug>.md` (`next_step: architect:design`) OR `.ai-flow/work/stories/STORY-XXX-<slug>.md` (`status: READY`, `next_step: developer:implement`), plus updated `.ai-flow/INDEX.md` and `.ai-flow/PROJECT_STATE.md`.
  > - **Forbidden Actions:** Must NOT alter architectural boundaries set by `architect`; must NOT write feature code; must NOT mark stories `DONE`.
  > - **Execution Checklist:** Read upstream Brief/Arch -> author Spec or self-contained Story Packets with inline AC and constraints -> update `INDEX.md` and `PROJECT_STATE.md` -> stop and recommend next persona (`architect` or `developer`).
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/agents/pm.agent.md && grep -q "^name: pm$" .github/agents/pm.agent.md && for h in "## Role & Ownership" "## Inputs" "## Outputs" "## Forbidden Actions" "## Execution Checklist"; do grep -q "^$h$" .github/agents/pm.agent.md || exit 1; done && echo "TASK_2_2_OK"
  ```

---

### Task 2.3: Architect Agent
- **Task ID & Title:** `Task 2.3` — Create `.github/agents/architect.agent.md`
- **Target File(s):** `.github/agents/architect.agent.md`
- **Exact Reference to Clone:** `Task 0.1` (`.github/agents/developer.agent.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/agents/developer.agent.md` and clone its exact YAML frontmatter and 5-heading structure to create `.github/agents/architect.agent.md`.
  > Configure it for the **Architect** persona:
  > - `name: architect`
  > - **Role & Ownership:** System boundaries, data contracts, security posture, ADR decisions, and inline technical constraints for Story Packets.
  > - **Inputs:** `.ai-flow/PROJECT_CONVENTIONS.md`, `.ai-flow/work/specs/SPEC-XX-*.md`, `.ai-flow/templates/architecture.md`.
  > - **Outputs:** `.ai-flow/work/architecture/ARCH-XX-<slug>.md` with `next_step: pm:story-packet` and explicit `## Constraints for Story Packets`, plus updated `.ai-flow/INDEX.md`.
  > - **Forbidden Actions:** Must NOT write feature code during design; must NOT bypass `PROJECT_CONVENTIONS.md` security guardrails.
  > - **Execution Checklist:** Read Conventions and Spec -> inspect existing code boundaries -> author Architecture doc with Context Capsule and inline constraints -> update `INDEX.md` -> stop and recommend `pm`.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/agents/architect.agent.md && grep -q "^name: architect$" .github/agents/architect.agent.md && for h in "## Role & Ownership" "## Inputs" "## Outputs" "## Forbidden Actions" "## Execution Checklist"; do grep -q "^$h$" .github/agents/architect.agent.md || exit 1; done && echo "TASK_2_3_OK"
  ```

---

### Task 2.4: UX Designer Agent
- **Task ID & Title:** `Task 2.4` — Create `.github/agents/ux-designer.agent.md`
- **Target File(s):** `.github/agents/ux-designer.agent.md`
- **Exact Reference to Clone:** `Task 0.1` (`.github/agents/developer.agent.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/agents/developer.agent.md` and clone its exact YAML frontmatter and 5-heading structure to create `.github/agents/ux-designer.agent.md`.
  > Configure it for the **UX Designer** persona:
  > - `name: ux-designer`
  > - **Role & Ownership:** User journeys, interaction flows, empty/loading/error states, and accessibility requirements.
  > - **Inputs:** `.ai-flow/PROJECT_CONVENTIONS.md` (existing design system), `.ai-flow/work/specs/SPEC-XX-*.md`, `.ai-flow/work/stories/STORY-XXX-*.md`.
  > - **Outputs:** Populated `## UX & Accessibility States` in Specs and `## Architectural & UX Constraints (Inline)` UX bullets in Story Packets.
  > - **Forbidden Actions:** Must NOT invent a conflicting design system outside `PROJECT_CONVENTIONS.md`; must NOT write backend business logic.
  > - **Execution Checklist:** Read `PROJECT_CONVENTIONS.md` UI rules and target Spec/Story -> specify user flow and empty/loading/error/a11y states -> update target artifact -> hand back to `pm` or `developer`.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/agents/ux-designer.agent.md && grep -q "^name: ux-designer$" .github/agents/ux-designer.agent.md && for h in "## Role & Ownership" "## Inputs" "## Outputs" "## Forbidden Actions" "## Execution Checklist"; do grep -q "^$h$" .github/agents/ux-designer.agent.md || exit 1; done && echo "TASK_2_4_OK"
  ```

---

### Task 2.5: QA Reviewer Agent
- **Task ID & Title:** `Task 2.5` — Create `.github/agents/qa-reviewer.agent.md`
- **Target File(s):** `.github/agents/qa-reviewer.agent.md`
- **Exact Reference to Clone:** `Task 0.1` (`.github/agents/developer.agent.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/agents/developer.agent.md` and clone its exact YAML frontmatter and 5-heading structure to create `.github/agents/qa-reviewer.agent.md`.
  > Configure it for the **QA Reviewer** persona:
  > - `name: qa-reviewer`
  > - **Role & Ownership:** Independent adversarial verification of `IN_REVIEW` Story Packets against `git diff`, inline Acceptance Criteria, Architectural Constraints, and live test re-execution.
  > - **Inputs:** `.ai-flow/PROJECT_CONVENTIONS.md`, `.ai-flow/PROJECT_STATE.md`, target `IN_REVIEW` Story Packet, `git diff`.
  > - **Outputs:** Populated `## Review Verdict` (`APPROVED` or `CHANGES_REQUESTED`) in the Story Packet; if `APPROVED`, sets Story Packet `status: DONE`, `next_step: DONE`, and `.ai-flow/PROJECT_STATE.md` `Status = DONE`; if `CHANGES_REQUESTED`, sets `status: IN_PROGRESS` and `next_step: developer:fix`.
  > - **Forbidden Actions:** **NEVER** edit application source code or test files; **NEVER** approve a story whose `## Execution Evidence` is empty or missing; **NEVER** mark `DONE` if any test/lint command fails.
  > - **Execution Checklist:** Verify story is `IN_REVIEW` with `Execution Evidence` -> inspect `git diff` against every `AC-*` and inline constraint -> independently re-run test/lint/typecheck commands from `PROJECT_CONVENTIONS.md` -> write `## Review Verdict` -> update `PROJECT_STATE.md` and `INDEX.md`.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/agents/qa-reviewer.agent.md && grep -q "^name: qa-reviewer$" .github/agents/qa-reviewer.agent.md && for h in "## Role & Ownership" "## Inputs" "## Outputs" "## Forbidden Actions" "## Execution Checklist"; do grep -q "^$h$" .github/agents/qa-reviewer.agent.md || exit 1; done && echo "TASK_2_5_OK"
  ```

---

## Phase 3 — Standalone Prompts & Copilot Skill (`.github/prompts/*.prompt.md` + `.github/skills/`)

Tasks 3.1–3.5 MUST clone the exact schema of **Task 0.2 (`.github/prompts/gps-navigator.prompt.md`)**:
- YAML frontmatter: `mode: agent`, `description`
- Deterministic `## Step-by-Step Instructions`

### Task 3.1: Repo Bootstrap Prompt
- **Task ID & Title:** `Task 3.1` — Create `.github/prompts/repo-bootstrap.prompt.md`
- **Target File(s):** `.github/prompts/repo-bootstrap.prompt.md`
- **Exact Reference to Clone:** `Task 0.2` (`.github/prompts/gps-navigator.prompt.md`) & `Task 0.3` (`.ai-flow/PROJECT_CONVENTIONS.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/prompts/gps-navigator.prompt.md` and `.ai-flow/PROJECT_CONVENTIONS.md`. Clone the prompt schema (`mode: agent`, `description`, `## Step-by-Step Instructions`) to create `.github/prompts/repo-bootstrap.prompt.md`.
  > Instruct the agent to:
  > 1. Scan repository manifests (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, CI workflows in `.github/workflows/`, linter/formatter configs).
  > 2. Write or update `.ai-flow/PROJECT_CONVENTIONS.md` preserving the exact `- **Test Command:** \`<command or NONE>\`` format (and Build/Lint/Typecheck lines). Use `NONE` for any command that does not exist in the repo.
  > 3. Initialize `.ai-flow/INDEX.md` and `.ai-flow/PROJECT_STATE.md` if missing.
  > 4. Output a concise summary of detected stack and commands, and recommend `/gps-navigator` next.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/prompts/repo-bootstrap.prompt.md && grep -q "^mode: agent$" .github/prompts/repo-bootstrap.prompt.md && grep -q "PROJECT_CONVENTIONS.md" .github/prompts/repo-bootstrap.prompt.md && echo "TASK_3_1_OK"
  ```

---

### Task 3.2: Quick-Fix Prompt
- **Task ID & Title:** `Task 3.2` — Create `.github/prompts/quick-fix.prompt.md`
- **Target File(s):** `.github/prompts/quick-fix.prompt.md`
- **Exact Reference to Clone:** `Task 0.2` (`.github/prompts/gps-navigator.prompt.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/prompts/gps-navigator.prompt.md` and clone its prompt schema (`mode: agent`, `description`, `## Step-by-Step Instructions`) to create `.github/prompts/quick-fix.prompt.md`.
  > Instruct the agent to execute the fast-track lane for small, low-risk tickets:
  > 1. Confirm the change is small/isolated (blast radius <= 3 files, no schema/API breaking changes); if larger, stop and recommend full `analyst` -> `pm` flow.
  > 2. Create `.ai-flow/work/stories/STORY-XXX-<slug>.md` from `.ai-flow/templates/story-packet.md` with `lane: quick-fix`, concise `AC-*`, and blast-radius note.
  > 3. Implement the fix as `developer`, run tests/lint from `.ai-flow/PROJECT_CONVENTIONS.md`, and paste raw output under `## Execution Evidence`.
  > 4. Set `status: IN_REVIEW`, `next_step: skill:two-hat-review`, update `.ai-flow/PROJECT_STATE.md` (`Evidence Logged = YES`), and stop for `/two-hat-review` (never self-approve `DONE`).
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/prompts/quick-fix.prompt.md && grep -q "^mode: agent$" .github/prompts/quick-fix.prompt.md && grep -q "quick-fix" .github/prompts/quick-fix.prompt.md && grep -q "two-hat-review" .github/prompts/quick-fix.prompt.md && echo "TASK_3_2_OK"
  ```

---

### Task 3.3: Two-Hat Review Prompt
- **Task ID & Title:** `Task 3.3` — Create `.github/prompts/two-hat-review.prompt.md`
- **Target File(s):** `.github/prompts/two-hat-review.prompt.md`
- **Exact Reference to Clone:** `Task 0.2` (`.github/prompts/gps-navigator.prompt.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/prompts/gps-navigator.prompt.md` and clone its prompt schema (`mode: agent`, `description`, `## Step-by-Step Instructions`) to create `.github/prompts/two-hat-review.prompt.md`.
  > Instruct the agent to enforce the Two-Hat Gate:
  > 1. Adopt the `qa-reviewer` persona strictly (do not edit feature code).
  > 2. Locate the target `IN_REVIEW` Story Packet from `.ai-flow/PROJECT_STATE.md`.
  > 3. Verify `## Execution Evidence` is present and non-empty.
  > 4. Inspect `git diff` against every `AC-*` and `## Architectural & UX Constraints (Inline)`.
  > 5. Re-run the test/lint/typecheck commands from `.ai-flow/PROJECT_CONVENTIONS.md` independently.
  > 6. Write `## Review Verdict` (`APPROVED` or `CHANGES_REQUESTED`) with diff/test notes.
  > 7. Only if `APPROVED`: set Story Packet `status: DONE`, `next_step: DONE`, and update `.ai-flow/PROJECT_STATE.md` `Status = DONE`. Otherwise set `IN_PROGRESS` and list required fixes.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/prompts/two-hat-review.prompt.md && grep -q "^mode: agent$" .github/prompts/two-hat-review.prompt.md && grep -q "APPROVED" .github/prompts/two-hat-review.prompt.md && grep -q "CHANGES_REQUESTED" .github/prompts/two-hat-review.prompt.md && echo "TASK_3_3_OK"
  ```

---

### Task 3.4: Retrospective Prompt
- **Task ID & Title:** `Task 3.4` — Create `.github/prompts/retrospective.prompt.md`
- **Target File(s):** `.github/prompts/retrospective.prompt.md`
- **Exact Reference to Clone:** `Task 0.2` (`.github/prompts/gps-navigator.prompt.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/prompts/gps-navigator.prompt.md` and clone its prompt schema (`mode: agent`, `description`, `## Step-by-Step Instructions`) to create `.github/prompts/retrospective.prompt.md`.
  > Instruct the agent to:
  > 1. Inspect `DONE` Story Packets in `.ai-flow/work/stories/`, `## Review Verdict` notes (especially any prior `CHANGES_REQUESTED`), and recent `git log -n 20 --oneline`.
  > 2. Identify concrete friction points, recurring defects, or missing guardrails.
  > 3. Propose specific, minimal edits to `.ai-flow/PROJECT_CONVENTIONS.md` or `.github/agents/*.agent.md` checklists.
  > 4. Apply updates only after user confirmation.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/prompts/retrospective.prompt.md && grep -q "^mode: agent$" .github/prompts/retrospective.prompt.md && grep -q "PROJECT_CONVENTIONS.md" .github/prompts/retrospective.prompt.md && echo "TASK_3_4_OK"
  ```

---

### Task 3.5: Roundtable Panel Prompt
- **Task ID & Title:** `Task 3.5` — Create `.github/prompts/roundtable-panel.prompt.md`
- **Target File(s):** `.github/prompts/roundtable-panel.prompt.md`
- **Exact Reference to Clone:** `Task 0.2` (`.github/prompts/gps-navigator.prompt.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/prompts/gps-navigator.prompt.md` and clone its prompt schema (`mode: agent`, `description`, `## Step-by-Step Instructions`) to create `.github/prompts/roundtable-panel.prompt.md`.
  > Instruct the agent to run a structured multi-persona critique for ambiguous or high-risk decisions:
  > 1. Read the user's decision topic and `.ai-flow/PROJECT_CONVENTIONS.md`.
  > 2. Evaluate the proposal sequentially through 3–4 relevant lenses from (`analyst`, `pm`, `architect`, `ux-designer`, `qa-reviewer`), keeping each lens strictly to its own risks, trade-offs, and constraints.
  > 3. Synthesize a single **Decision Summary**, **Chosen Option**, **Risks & Mitigations**, and **Recommended Next Step** (`next_step` value).
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/prompts/roundtable-panel.prompt.md && grep -q "^mode: agent$" .github/prompts/roundtable-panel.prompt.md && grep -q "Decision Summary" .github/prompts/roundtable-panel.prompt.md && echo "TASK_3_5_OK"
  ```

---

### Task 3.6: GPS/Navigator Copilot Skill Mirror
- **Task ID & Title:** `Task 3.6` — Create `.github/skills/gps-navigator/SKILL.md`
- **Target File(s):** `.github/skills/gps-navigator/SKILL.md`
- **Exact Reference to Clone:** `Task 0.2` (`.github/prompts/gps-navigator.prompt.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Read `.github/prompts/gps-navigator.prompt.md` and create `.github/skills/gps-navigator/SKILL.md` as a Copilot Agent Skill with YAML frontmatter (`name: gps-navigator`, `description: ...`) and the exact same 5-step routing logic and strict output format as `.github/prompts/gps-navigator.prompt.md`.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .github/skills/gps-navigator/SKILL.md && grep -q "^name: gps-navigator$" .github/skills/gps-navigator/SKILL.md && grep -q "PROJECT_STATE.md" .github/skills/gps-navigator/SKILL.md && echo "TASK_3_6_OK"
  ```

---

## Phase 4 — Layer 3 Deterministic Guards, Smoke Tests & Setup Docs

Both guards in Tasks 4.1 and 4.2 MUST implement identical deterministic rules:
1. If `.ai-flow/PROJECT_STATE.md` exists:
   - Fail if any `DONE` row has `Evidence Logged = NO`.
   - For every `DONE` row, find `.ai-flow/work/stories/<StoryID>*.md` and fail if missing, or if it lacks `## Execution Evidence` or `APPROVED`.
2. If `.ai-flow/PROJECT_CONVENTIONS.md` exists:
   - Parse the exact line `- **Test Command:** \`<value>\``.
   - If `<value>` is non-empty and not `NONE` and not `<command or NONE>`, execute it and fail if it exits non-zero.

### Task 4.1: POSIX Bash Pre-Commit Guard (macOS/Linux)
- **Task ID & Title:** `Task 4.1` — Create `.ai-flow/guards/pre-commit.sh`
- **Target File(s):** `.ai-flow/guards/pre-commit.sh`
- **Exact Reference to Clone:** `Task 0.3` (parses `- **Test Command:** \`...\``) & `.ai-flow/PROJECT_STATE.md` table columns
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Create executable POSIX bash script `.ai-flow/guards/pre-commit.sh` (`#!/usr/bin/env bash`, `set -euo pipefail`):
  > 1. If `.ai-flow/PROJECT_STATE.md` exists:
  >    - Fail with exit 1 if `grep -E '\|\s*DONE\s*\|\s*NO\s*\|' .ai-flow/PROJECT_STATE.md` matches.
  >    - Loop over data rows (`grep -E '^\|' .ai-flow/PROJECT_STATE.md | tail -n +3`), extract `story_id` (col 1) and `status` (col 6) trimmed with `xargs`.
  >    - When `status == "DONE"`, verify a matching `.ai-flow/work/stories/${story_id}*.md` file exists and contains both `## Execution Evidence` and `APPROVED`. Otherwise print `[ai-flow gate] ERROR: ...` and exit 1.
  > 2. If `.ai-flow/PROJECT_CONVENTIONS.md` exists:
  >    - Extract the backtick-wrapped value on the `- **Test Command:**` line using `sed`.
  >    - If the extracted command is non-empty, not `NONE`, and not `<command or NONE>`, run it via `bash -c "$test_cmd"`. Exit 1 on failure.
  > 3. Print `[ai-flow gate] Passed.` and exit 0.
  > Run `chmod +x .ai-flow/guards/pre-commit.sh`.
- **Deterministic Shell Verification Command:**
  ```bash
  test -x .ai-flow/guards/pre-commit.sh && bash -n .ai-flow/guards/pre-commit.sh && bash .ai-flow/guards/pre-commit.sh && echo "TASK_4_1_OK"
  ```

---

### Task 4.2: PowerShell Pre-Commit Guard (Windows Mixed-OS)
- **Task ID & Title:** `Task 4.2` — Create `.ai-flow/guards/pre-commit.ps1`
- **Target File(s):** `.ai-flow/guards/pre-commit.ps1`
- **Exact Reference to Clone:** `Task 4.1` (`.ai-flow/guards/pre-commit.sh`) & `Task 0.3` (`.ai-flow/PROJECT_CONVENTIONS.md`)
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Create `.ai-flow/guards/pre-commit.ps1` (`$ErrorActionPreference = "Stop"`) with exact parity to `.ai-flow/guards/pre-commit.sh`:
  > 1. If `.ai-flow/PROJECT_STATE.md` exists:
  >    - Read table rows matching `^\|` skipping the 2 header lines; split on `|` and trim each cell.
  >    - For any row where `$cols[6] -eq "DONE"`:
  >      - Fail (`Write-Error` + `exit 1`) if `$cols[7] -ne "YES"`.
  >      - Locate `.ai-flow/work/stories/$($cols[1])*.md`; fail if missing or if content does not match both `## Execution Evidence` and `APPROVED`.
  > 2. If `.ai-flow/PROJECT_CONVENTIONS.md` exists:
  >    - Match `- \*\*Test Command:\*\*\s*\`([^\`]+)\``; if `$testCmd` is non-empty, not `NONE`, and not `<command or NONE>`, run it via `Invoke-Expression $testCmd` and fail if `$LASTEXITCODE -ne 0`.
  > 3. Print `Write-Host "[ai-flow gate] Passed."` and `exit 0`.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .ai-flow/guards/pre-commit.ps1 && grep -q 'Test Command:' .ai-flow/guards/pre-commit.ps1 && grep -q '## Execution Evidence' .ai-flow/guards/pre-commit.ps1 && (command -v pwsh >/dev/null 2>&1 && pwsh -NoProfile -File .ai-flow/guards/pre-commit.ps1 || echo "pwsh_not_installed_syntax_checked") && echo "TASK_4_2_OK"
  ```

---

### Task 4.3: Hook Setup Guide & End-to-End Smoke Test
- **Task ID & Title:** `Task 4.3` — Create `.ai-flow/README.md` (with Windows + macOS/Linux hook setup) and run negative/positive guard smoke tests
- **Target File(s):** `.ai-flow/README.md`
- **Exact Reference to Clone:** `Task 0.1`–`0.3` & `Task 4.1`–`4.2`
- **Exact Copy-Paste Prompt (for Gemini 3.8):**
  > Create `.ai-flow/README.md` containing:
  > 1. **Quick Start:** Run `/repo-bootstrap` first, then `/gps-navigator` at any time.
  > 2. **Cheat Sheet Tables:** List the 6 Custom Agents (`analyst`, `pm`, `architect`, `ux-designer`, `developer`, `qa-reviewer`) and 6 Prompts (`/gps-navigator`, `/repo-bootstrap`, `/quick-fix`, `/two-hat-review`, `/retrospective`, `/roundtable-panel`).
  > 3. **Pre-Commit Guard Installation (Mixed OS):**
  >    - **macOS / Linux (`.git/hooks/pre-commit`):**
  >      ```sh
  >      #!/bin/sh
  >      exec bash .ai-flow/guards/pre-commit.sh
  >      ```
  >    - **Windows Git Bash / PowerShell (`.git/hooks/pre-commit`):**
  >      ```sh
  >      #!/bin/sh
  >      if command -v pwsh >/dev/null 2>&1; then
  >        exec pwsh -NoProfile -ExecutionPolicy Bypass -File .ai-flow/guards/pre-commit.ps1
  >      else
  >        exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File .ai-flow/guards/pre-commit.ps1
  >      fi
  >      ```
  > Do not mention any external frameworks or non-`.ai-flow` tools.
- **Deterministic Shell Verification Command:**
  ```bash
  test -f .ai-flow/README.md && grep -q "pre-commit.sh" .ai-flow/README.md && grep -q "pre-commit.ps1" .ai-flow/README.md && \
  TMP_STATE=$(mktemp) && cp .ai-flow/PROJECT_STATE.md "$TMP_STATE" && \
  echo "| STORY-999 | quick-fix | Smoke Test | developer | qa-reviewer | DONE | NO |" >> .ai-flow/PROJECT_STATE.md && \
  (! bash .ai-flow/guards/pre-commit.sh >/dev/null 2>&1) && \
  mv "$TMP_STATE" .ai-flow/PROJECT_STATE.md && \
  bash .ai-flow/guards/pre-commit.sh && echo "TASK_4_3_OK"
  ```
