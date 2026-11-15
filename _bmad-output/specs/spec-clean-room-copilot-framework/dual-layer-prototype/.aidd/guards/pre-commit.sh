#!/usr/bin/env bash
set -euo pipefail

STATE_FILE=".aidd/PROJECT_STATE.md"
CONVENTIONS_FILE=".aidd/PROJECT_CONVENTIONS.md"
STORIES_DIR=".aidd/work/stories"

is_valid_status() {
  case "$1" in
    BACKLOG|READY|IN_PROGRESS|BLOCKED|IN_REVIEW|DONE) return 0 ;;
    *) return 1 ;;
  esac
}

extract_fm() {
  local file="$1" key="$2"
  awk -v k="$key" '
    NR==1 && /^---[[:space:]]*$/ { in_fm=1; next }
    in_fm && /^---[[:space:]]*$/ { exit }
    in_fm {
      pos = index($0, ":")
      if (pos > 0) {
        fk = substr($0, 1, pos - 1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", fk)
        if (tolower(fk) == tolower(k)) {
          val = substr($0, pos + 1)
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
          gsub(/^["'\'']|["'\'']$/, "", val)
          print val
          exit
        }
      }
    }
  ' "$file"
}

validate_evidence_section() {
  local story_file="$1" label="$2"
  if [[ ! -f "$story_file" ]]; then
    echo "[aidd gate] ERROR: Story packet not found: $story_file" >&2
    exit 1
  fi
  if ! grep -q "^## Execution Evidence[[:space:]]*$" "$story_file"; then
    echo "[aidd gate] ERROR: $story_file ($label) is missing '## Execution Evidence' heading." >&2
    exit 1
  fi
  if grep -q "PENDING_EVIDENCE" "$story_file"; then
    echo "[aidd gate] ERROR: $story_file ($label) still contains placeholder PENDING_EVIDENCE." >&2
    exit 1
  fi
  local evidence_lines
  evidence_lines=$(awk '
    /^## Execution Evidence[[:space:]]*$/ { flag=1; next }
    flag && /^## / { flag=0 }
    flag && !/^```/ && NF > 0 { count++ }
    END { print count+0 }
  ' "$story_file")
  if [[ "$evidence_lines" -lt 1 ]]; then
    echo "[aidd gate] ERROR: $story_file ($label) has empty '## Execution Evidence' output." >&2
    exit 1
  fi
}

validate_approved_verdict() {
  local story_file="$1"
  if ! awk '
    /^## Review Verdict[[:space:]]*$/ { in_rv=1; next }
    in_rv && /^## / { in_rv=0 }
    in_rv && tolower($0) ~ /^- \*\*verdict:\*\*[[:space:]]*`?approved`?[[:space:]]*$/ { ok=1 }
    END { exit !ok }
  ' "$story_file"; then
    echo "[aidd gate] ERROR: $story_file is DONE but lacks '- **Verdict:** APPROVED' under '## Review Verdict'." >&2
    exit 1
  fi
}

# 1. Validate 9-column schema, enums & IN_REVIEW / DONE rows in PROJECT_STATE.md
if [[ -f "$STATE_FILE" ]]; then
  while IFS= read -r raw_row; do
    [[ -n "$raw_row" ]] || continue
    pipe_count=$(awk -F'|' '{print NF}' <<< "$raw_row")
    if [[ "$pipe_count" -lt 11 ]]; then
      echo "[aidd gate] ERROR: Malformed row in $STATE_FILE (expected 9 columns): $raw_row" >&2
      exit 1
    fi
    IFS='|' read -r _ c_id _ _ _ _ _ _ c_status c_evid _ <<< "$raw_row"
    story_id=$(echo "${c_id:-}" | xargs)
    status_val=$(echo "${c_status:-}" | tr '[:lower:]' '[:upper:]' | xargs)
    evid_val=$(echo "${c_evid:-}" | tr '[:lower:]' '[:upper:]' | xargs)

    [[ -n "$story_id" ]] || continue

    if ! is_valid_status "$status_val"; then
      echo "[aidd gate] ERROR: Invalid Status '$status_val' for $story_id in $STATE_FILE." >&2
      exit 1
    fi
    if [[ "$evid_val" != "YES" && "$evid_val" != "NO" ]]; then
      echo "[aidd gate] ERROR: Invalid Evidence Logged '$evid_val' (must be YES or NO) for $story_id in $STATE_FILE." >&2
      exit 1
    fi

    if [[ "$status_val" == "IN_REVIEW" || "$status_val" == "DONE" ]]; then
      if [[ "$evid_val" != "YES" ]]; then
        echo "[aidd gate] ERROR: $story_id is $status_val in $STATE_FILE without Evidence Logged = YES." >&2
        exit 1
      fi
      matched_file=$(find "$STORIES_DIR" -maxdepth 1 -type f -name "${story_id}*.md" 2>/dev/null | LC_ALL=C sort | head -n 1 || true)
      if [[ -z "$matched_file" ]]; then
        echo "[aidd gate] ERROR: Missing story file in $STORIES_DIR for $status_val story $story_id." >&2
        exit 1
      fi
      validate_evidence_section "$matched_file" "$status_val"
      if [[ "$status_val" == "DONE" ]]; then
        validate_approved_verdict "$matched_file"
      fi
    fi
  done < <(awk '/^\|/ { r++; if (r >= 3) print }' "$STATE_FILE")
fi

# 2. Validate frontmatter & gates directly on all .aidd/work/stories/*.md files
if [[ -d "$STORIES_DIR" ]]; then
  for sf in "$STORIES_DIR"/*.md; do
    [[ -e "$sf" ]] || continue
    fm_status=$(extract_fm "$sf" "status" | tr '[:lower:]' '[:upper:]')
    if [[ -z "$fm_status" ]]; then
      echo "[aidd gate] ERROR: Missing 'status:' in YAML frontmatter of $sf." >&2
      exit 1
    fi
    if ! is_valid_status "$fm_status"; then
      echo "[aidd gate] ERROR: Invalid frontmatter status '$fm_status' in $sf." >&2
      exit 1
    fi
    if [[ "$fm_status" == "IN_REVIEW" || "$fm_status" == "DONE" ]]; then
      validate_evidence_section "$sf" "$fm_status"
    fi
    if [[ "$fm_status" == "DONE" ]]; then
      validate_approved_verdict "$sf"
    fi
  done
fi

# 3. Reject any accidental .html files placed inside .aidd/work/ (Zero-LLM-HTML Rule)
if [[ -d ".aidd/work" ]]; then
  rogue_html=$(find .aidd/work -type f -name "*.html" 2>/dev/null | head -n 1 || true)
  if [[ -n "$rogue_html" ]]; then
    echo "[aidd gate] ERROR: HTML file found in .aidd/work/ ($rogue_html). Keep .aidd/work/ 100% pure Markdown; use .aidd/cockpit.html for HTML review." >&2
    exit 1
  fi
fi

# 4. Enforce Quick-Fix blast radius (<= 3 non-governance code/test files staged)
if git rev-parse --git-dir >/dev/null 2>&1; then
  has_staged_quickfix=0
  while IFS= read -r staged_sf; do
    [[ -n "$staged_sf" && -f "$staged_sf" ]] || continue
    sf_lane=$(extract_fm "$staged_sf" "lane" | tr '[:upper:]' '[:lower:]')
    sf_status=$(extract_fm "$staged_sf" "status" | tr '[:lower:]' '[:upper:]')
    if [[ "$sf_lane" == "quick-fix" && ( "$sf_status" == "IN_REVIEW" || "$sf_status" == "DONE" ) ]]; then
      has_staged_quickfix=1
      break
    fi
  done < <(git diff --cached --name-only --diff-filter=ACMR -- "$STORIES_DIR" 2>/dev/null || true)

  if [[ "$has_staged_quickfix" -eq 1 ]]; then
    code_count=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null | awk '!/^(\.aidd\/|\.github\/|AGENTS\.md$|docs\/)/ && NF > 0 { c++ } END { print c+0 }')
    if [[ "$code_count" -gt 3 ]]; then
      echo "[aidd gate] ERROR: Quick-fix blast radius exceeded ($code_count code/test files staged; max allowed is 3). Use standard lane." >&2
      exit 1
    fi
  fi
fi

# 5. Execute machine-parsed Lint, Typecheck & Test Commands from PROJECT_CONVENTIONS.md
run_convention_cmd() {
  local label="$1"
  local cmd
  cmd=$(sed -n "s/^- \*\*${label}:\*\*[[:space:]]*\`\([^\`]*\)\`.*/\1/p" "$CONVENTIONS_FILE" | head -n 1)
  if [[ -n "$cmd" && "$cmd" != "NONE" && "$cmd" != "<"* ]]; then
    echo "[aidd gate] Running ${label}: $cmd"
    bash -c "$cmd"
  else
    echo "[aidd gate] ${label} is NONE or unconfigured; skipping."
  fi
}

if [[ -f "$CONVENTIONS_FILE" ]]; then
  run_convention_cmd "Lint Command"
  run_convention_cmd "Typecheck Command"
  run_convention_cmd "Test Command"
fi

echo "[aidd gate] Passed."
