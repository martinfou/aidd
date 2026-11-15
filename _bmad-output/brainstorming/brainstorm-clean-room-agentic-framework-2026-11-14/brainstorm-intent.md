# Brainstorm Intent: Clean-Room Serverless Agentic Framework

## 1. Problem & Goal
- **Problem:** Corporate/enterprise teams need an AI-driven development framework without installing servers, CLIs, or runtime dependencies, while avoiding workflow discovery friction (knowing what step/skill to run next) and context bloat across handoffs.
- **Goal:** Create a clean-room, serverless AI-driven development framework built solely from portable skills, prompts, and personas, streamlining the agile flow (`Brief -> Spec -> Arch -> Stories -> Dev -> Review`) for corporate work.

## 2. Non-Negotiable Constraints
- **GitHub Copilot Primary Target:** Designed natively around GitHub Copilot's `.github/` conventions (`.github/copilot-instructions.md`, `.github/agents/*.agent.md` for personas, `.github/prompts/*.prompt.md` and `.github/skills/*/SKILL.md` for skills/workflows).
- **Clean-room & Portable:** Zero-install portable folder structure (`.github/` + `.ai-flow/` state/work folder).
- **Zero-Runtime Pure Markdown:** Pure Markdown skills, prompts, and personas by default; zero Python/Node runtime dependencies, servers, CLIs, or daemons.
- **Optional Native Scripts Only:** Native `bash` / `powershell` scripts permitted strictly where deterministic checks are required (e.g., pre-commit guard).
- **Native-Readable State:** Use plain Markdown tables (e.g., `PROJECT_STATE.md`, `INDEX.md`) or simple JSON instead of complex YAML/TOML parsers so both LLMs and `bash`/`powershell` can read them natively.

## 3. v1 MUST Scope (MoSCoW)
**MUST:**
1. Portable pure-Markdown framework structure (`.ai/` or `.agent/`).
2. Single **GPS / Navigator** skill for state inspection and next-step routing.
3. **6-Persona** core roster: Analyst, PM, Architect, UX Designer, Developer, QA Reviewer.
4. **Repo Bootstrap** skill (auto-detect stack, CI, style into `PROJECT_CONVENTIONS.md`).
5. **Quick-Fix** fast-track lane for small tickets.
6. **Self-Contained Story Packets** + lightweight `INDEX.md`.
7. **3-Layer Quality Gate** (including `bash`/`powershell` pre-commit guard).
8. **Retrospective** and **Roundtable Panel** standalone skills.

**WON'T (v1):**
- Server, CLI, background daemons, or Python/Node runtime dependencies.

## 4. Architecture Principles
- **Filesystem as State Machine & GPS Navigator:** Shared Markdown state files + artifact frontmatter `next_step` inspected by a single GPS/Navigator skill that recommends the exact next command/persona to invoke.
- **Hybrid 6-Persona + Standalone Skills:** Core roles (Analyst, PM, Architect, UX Designer, Developer, QA Reviewer) operate as personas; cross-cutting actions (GPS, Review, Retrospective, Roundtable Panel, Repo Bootstrap, Quick-Fix) operate as standalone composable skills.
- **Self-Contained Story Packets + `INDEX.md`:** Each stage writes a compact top-of-file Handoff Summary (Context Capsule) to keep downstream token usage lean. Story packets inline all acceptance criteria (AC) and architectural constraints, paired with a lightweight `INDEX.md` for GPS routing.
- **3-Layer Quality Gate:**
  1. **Two-Hat Builder/Reviewer Split:** Developer/Builder cannot mark a story `Done`; a separate QA Reviewer skill verifies AC against `git diff` and runs tests.
  2. **Evidence-First Output:** Actual terminal/test output must be recorded in the story.
  3. **Deterministic Pre-Commit Guard:** Optional native `bash`/`powershell` pre-commit guard enforces deterministic checks.
- **Repo Bootstrap + Quick-Fix Lane:** Bootstrap fingerprints an existing corporate repo (stack, CI, style) into `PROJECT_CONVENTIONS.md` before planning; Quick-Fix provides a fast-track lane for small tickets without full ceremony.

## 5. Explicit Non-Goals
- No server, daemon, or persistent background process.
- No custom CLI binary or Python/Node runtime installation.
- No complex YAML/TOML parsing dependencies.
- No collapsed 4-persona model (explicitly replaced by the 6-persona roster).
