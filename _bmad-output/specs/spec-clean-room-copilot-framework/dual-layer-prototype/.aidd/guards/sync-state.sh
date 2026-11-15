#!/usr/bin/env bash
set -euo pipefail

STATE_FILE=".aidd/PROJECT_STATE.md"
VIEWS_DIR=".aidd/views"
BUNDLE_FILE=".aidd/views/aidd-data.js"
STORIES_DIR=".aidd/work/stories"

mkdir -p ".aidd" "$VIEWS_DIR" "$STORIES_DIR"
if [[ ! -f "$VIEWS_DIR/.gitignore" ]]; then
  printf '*\n!.gitignore\n' > "$VIEWS_DIR/.gitignore"
fi

TMP_STATE=$(mktemp)
TMP_BUNDLE=$(mktemp)
cleanup() {
  rm -f "$TMP_STATE" "$TMP_BUNDLE"
}
trap cleanup EXIT

cat > "$TMP_STATE" <<'HEADER'
# Project Delivery State

> Allowed Status values: `BACKLOG` | `READY` | `IN_PROGRESS` | `BLOCKED` | `IN_REVIEW` | `DONE`

| Story ID | Epic | Sprint | Lane | Title | Owner Persona | Reviewer | Status | Evidence Logged |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
HEADER

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
          gsub(/\|/, "/", val)
          print val
          exit
        }
      }
    }
  ' "$file"
}

has_evidence() {
  local file="$1"
  grep -q "^## Execution Evidence[[:space:]]*$" "$file" || return 1
  ! grep -q "PENDING_EVIDENCE" "$file" || return 1
  local count
  count=$(awk '
    /^## Execution Evidence[[:space:]]*$/ { flag=1; next }
    flag && /^## / { flag=0 }
    flag && !/^```/ && NF > 0 { c++ }
    END { print c+0 }
  ' "$file")
  [[ "$count" -ge 1 ]]
}

json_str_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    printf '""'
    return
  fi
  awk '
    function esc(s,    out, i, c, prev) {
      out = ""; prev = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\r") continue
        if (c == "\\") out = out "\\\\"
        else if (c == "\"") out = out "\\\""
        else if (c == "\t") out = out "\\t"
        else if (c == "/" && prev == "<") out = out "\\/"
        else out = out c
        prev = c
      }
      return out
    }
    BEGIN { ORS=""; printf "\"" }
    {
      if (NR > 1) printf "\\n"
      printf "%s", esc($0)
    }
    END { printf "\"" }
  ' "$file"
}

json_str_val() {
  printf '%s' "${1:-}" | awk '
    function esc(s,    out, i, c, prev) {
      out = ""; prev = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\r") continue
        if (c == "\\") out = out "\\\\"
        else if (c == "\"") out = out "\\\""
        else if (c == "\t") out = out "\\t"
        else if (c == "/" && prev == "<") out = out "\\/"
        else out = out c
        prev = c
      }
      return out
    }
    BEGIN { ORS=""; printf "\"" }
    {
      if (NR > 1) printf "\\n"
      printf "%s", esc($0)
    }
    END { printf "\"" }
  '
}

while IFS= read -r sf; do
  [[ -n "$sf" && -f "$sf" ]] || continue
  base=$(basename "$sf" .md)
  s_id=$(extract_fm "$sf" "id")
  [[ -n "$s_id" ]] || s_id="${base%%-*}"
  s_lane=$(extract_fm "$sf" "lane")
  [[ -n "$s_lane" ]] || s_lane="standard"
  s_epic=$(extract_fm "$sf" "epic")
  if [[ -z "$s_epic" ]]; then
    [[ "$s_lane" == "quick-fix" ]] && s_epic="QUICK-FIX" || s_epic="EPIC-01"
  fi
  s_sprint=$(extract_fm "$sf" "sprint")
  if [[ -z "$s_sprint" ]]; then
    [[ "$s_lane" == "quick-fix" ]] && s_sprint="HOTFIX" || s_sprint="SPRINT-01"
  fi
  s_title=$(extract_fm "$sf" "title")
  [[ -n "$s_title" ]] || s_title="$base"
  s_owner=$(extract_fm "$sf" "owner")
  [[ -n "$s_owner" ]] || s_owner="developer"
  s_rev=$(extract_fm "$sf" "reviewer")
  [[ -n "$s_rev" ]] || s_rev="qa-reviewer"
  s_status=$(extract_fm "$sf" "status" | tr '[:lower:]' '[:upper:]')
  [[ -n "$s_status" ]] || s_status="READY"
  if has_evidence "$sf"; then s_evid="YES"; else s_evid="NO"; fi

  printf '| %s | %s | %s | %s | %s | %s | %s | %s | %s |\n' \
    "$s_id" "$s_epic" "$s_sprint" "$s_lane" "$s_title" "$s_owner" "$s_rev" "$s_status" "$s_evid" >> "$TMP_STATE"
done < <(find "$STORIES_DIR" -maxdepth 1 -type f -name "*.md" | LC_ALL=C sort)

mv "$TMP_STATE" "$STATE_FILE"

SYNC_TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_STATUS=""
GIT_DIFF=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  GIT_STATUS=$(git status --short 2>/dev/null || true)
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    GIT_DIFF=$(git diff HEAD 2>/dev/null | head -n 2000 || true)
  else
    GIT_DIFF=$(git diff --cached 2>/dev/null | head -n 2000 || true)
  fi
fi

{
  printf 'window.AIDD_DATA = {\n'
  printf '  "version": "2.2",\n'
  printf '  "syncedAt": %s,\n' "$(json_str_val "$SYNC_TS")"
  printf '  "conventions": %s,\n' "$(json_str_file ".aidd/PROJECT_CONVENTIONS.md")"
  printf '  "context": %s,\n' "$(json_str_file ".aidd/PROJECT_CONTEXT.md")"
  printf '  "index": %s,\n' "$(json_str_file ".aidd/INDEX.md")"
  printf '  "state": %s,\n' "$(json_str_file "$STATE_FILE")"
  printf '  "gitStatus": %s,\n' "$(json_str_val "$GIT_STATUS")"
  printf '  "gitDiff": %s,\n' "$(json_str_val "$GIT_DIFF")"
  printf '  "artifacts": [\n'

  first_art=1
  for stage_dir in briefs specs architecture stories; do
    dir_path=".aidd/work/$stage_dir"
    [[ -d "$dir_path" ]] || continue
    while IFS= read -r af; do
      [[ -n "$af" && -f "$af" ]] || continue
      [[ "$first_art" -eq 1 ]] && first_art=0 || printf ',\n'
      a_base=$(basename "$af" .md)
      a_id=$(extract_fm "$af" "id")
      [[ -n "$a_id" ]] || a_id="${a_base%%-*}"
      a_title=$(extract_fm "$af" "title")
      [[ -n "$a_title" ]] || a_title="$a_base"
      a_status=$(extract_fm "$af" "status" | tr '[:lower:]' '[:upper:]')
      a_owner=$(extract_fm "$af" "owner")
      a_up=$(extract_fm "$af" "upstream")
      a_next=$(extract_fm "$af" "next_step")
      a_epic=$(extract_fm "$af" "epic")
      a_sprint=$(extract_fm "$af" "sprint")
      a_lane=$(extract_fm "$af" "lane")
      a_lines=$(wc -l < "$af" | xargs)
      a_evid="NO"
      if [[ "$stage_dir" == "stories" ]] && has_evidence "$af"; then a_evid="YES"; fi

      printf '    {"id": %s, "stage": %s, "path": %s, "title": %s, "status": %s, "owner": %s, "upstream": %s, "nextStep": %s, "epic": %s, "sprint": %s, "lane": %s, "lines": %s, "evidenceLogged": %s, "markdown": %s}' \
        "$(json_str_val "$a_id")" \
        "$(json_str_val "$stage_dir")" \
        "$(json_str_val "$af")" \
        "$(json_str_val "$a_title")" \
        "$(json_str_val "$a_status")" \
        "$(json_str_val "$a_owner")" \
        "$(json_str_val "$a_up")" \
        "$(json_str_val "$a_next")" \
        "$(json_str_val "$a_epic")" \
        "$(json_str_val "$a_sprint")" \
        "$(json_str_val "$a_lane")" \
        "${a_lines:-0}" \
        "$(json_str_val "$a_evid")" \
        "$(json_str_file "$af")"
    done < <(find "$dir_path" -maxdepth 1 -type f -name "*.md" | LC_ALL=C sort)
  done

  printf '\n  ]\n};\n'
} > "$TMP_BUNDLE"

mv "$TMP_BUNDLE" "$BUNDLE_FILE"
echo "[aidd sync] Synchronized $STATE_FILE and $BUNDLE_FILE."
