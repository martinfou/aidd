# Companion: 3-Layer Quality Gate & Mixed-OS Guards

## 1. Three-Layer Enforcement
1. **Layer 1 — Two-Hat Separation:** `developer.agent.md` cannot set `status: DONE`; only `qa-reviewer.agent.md` (or `/two-hat-review`) can flip a story to `DONE` after auditing `git diff` against Acceptance Criteria.
2. **Layer 2 — Evidence-First Closure:** Stories require pasted terminal output under `## Execution Evidence` and an explicit `## Review Verdict: APPROVED` section.
3. **Layer 3 — Deterministic Pre-Commit Guards (`.ai-flow/guards/`):**
   - `pre-commit.sh` (POSIX `bash` for macOS/Linux)
   - `pre-commit.ps1` (PowerShell for Windows)

## 2. Pre-Commit Guard Contract (`pre-commit.sh` & `pre-commit.ps1`)
When executed before commit:
1. Inspect staged/modified story files under `.ai-flow/work/stories/*.md`.
2. For any story with `status: DONE` (case-insensitive):
   - Fail with non-zero exit if `## Execution Evidence` is missing or empty.
   - Fail with non-zero exit if `## Review Verdict: APPROVED` is missing.
3. Parse `- **Test Command:** \`...\`` from `.ai-flow/PROJECT_CONVENTIONS.md`:
   - If present and not `NONE`, execute the test command and fail commit on non-zero exit.
   - If `NONE` or missing, skip test execution cleanly with an informational message.

## 3. Smoke Verification & Hook Setup
- Both `pre-commit.sh` and `pre-commit.ps1` must be verified with a 3-case smoke test:
  1. Valid `DONE` story with evidence + verdict → exit `0`.
  2. `DONE` story missing `## Execution Evidence` → non-zero exit.
  3. `DONE` story missing `## Review Verdict: APPROVED` → non-zero exit.
- `.ai-flow/README.md` documents non-destructive hook installation for both OSes (linking/appending into `.git/hooks/pre-commit` without overwriting existing corporate hooks).
