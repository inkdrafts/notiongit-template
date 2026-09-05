#!/usr/bin/env bash
#
# Deterministic hygiene scan for the notiongit-template repository.
#
# Rejects personal content and unsafe template artifacts: a CNAME file,
# non-placeholder content in the sync-managed _pages/_posts/_data
# directories, source-site identity/domain strings, private AI-assistant
# files, obvious secret patterns, and unpinned third-party actions. Matched
# secret values are never printed; only the file path and rule name are
# reported.
#
# Only tracked (or staged) files are scanned, matching what a checkout of
# the repository actually ships — the same scope scripts/check-neutral-config.sh
# uses via `git grep`. Local build output, vendored gems, and other untracked
# or gitignored files are out of scope.
#
# Usage: ./scripts/check-hygiene.sh [TARGET_DIR]   (defaults to the current directory)

set -euo pipefail

target="${1:-.}"
target="${target%/}"
[[ -z "$target" ]] && target="."

if ! git -C "$target" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "hygiene: $target is not a git working tree" >&2
  exit 1
fi

failures=0

fail() {
  echo "hygiene: $1" >&2
  failures=1
}

# Files that legitimately reference the source-identity pattern as literal
# text (this script and check-neutral-config.sh embed the regex; README.md
# and test-hygiene.sh document/demonstrate it) are exempt from the
# identity/domain scan. Kept narrow and explicit on purpose: reusable docs
# are allowlisted by exact path, never by excluding a whole directory.
IDENTITY_ALLOWLIST=(
  "README.md"
  "scripts/check-hygiene.sh"
  "scripts/check-neutral-config.sh"
  "scripts/test-hygiene.sh"
)

# Only test-hygiene.sh is exempt from the secret-pattern scan: it
# intentionally embeds fake values shaped like each rule to prove the
# scanner rejects them. Nothing else — including README.md — gets a pass on
# secret patterns.
SECRET_ALLOWLIST=(
  "scripts/test-hygiene.sh"
)

is_identity_allowlisted() {
  local rel="$1" entry
  for entry in "${IDENTITY_ALLOWLIST[@]}"; do
    [[ "$rel" == "$entry" ]] && return 0
  done
  return 1
}

is_secret_allowlisted() {
  local rel="$1" entry
  for entry in "${SECRET_ALLOWLIST[@]}"; do
    [[ "$rel" == "$entry" ]] && return 0
  done
  return 1
}

TRACKED_FILES=()
while IFS= read -r -d '' rel; do
  TRACKED_FILES+=("$rel")
done < <(git -C "$target" ls-files -z)

# 1. No CNAME file: custom domains belong to the provisioned site, not the template.
for rel in "${TRACKED_FILES[@]}"; do
  [[ "$rel" == "CNAME" ]] && fail "CNAME [cname]: custom-domain file must not be committed to the template"
done

# 2. _pages/, _posts/, and _data/ are sync-managed output. Only the
# documented .gitkeep placeholder may be committed there.
for rel in "${TRACKED_FILES[@]}"; do
  case "$rel" in
    _pages/*|_posts/*|_data/*)
      [[ "$(basename "$rel")" == ".gitkeep" ]] && continue
      fail "$rel [sync-managed-output]: ${rel%%/*}/ must contain only the .gitkeep placeholder"
      ;;
  esac
done

# 3. Source-site identity or domain strings.
for rel in "${TRACKED_FILES[@]}"; do
  is_identity_allowlisted "$rel" && continue
  if grep -IqiE 'leandrollosa|leandro[[:space:]-]+llosa' "$target/$rel" 2>/dev/null; then
    fail "$rel [source-identity]: source-site domain or personal identity string found"
  fi
done

# 4. Private AI-assistant files must not be committed to the template.
PRIVATE_ASSISTANT_NAMES=(
  "CLAUDE.md"
  ".claude"
  "AGENTS.md"
  ".cursor"
  ".cursorrules"
  ".codex"
  ".windsurfrules"
  ".aider.conf.yml"
  ".aider.chat.history.md"
  ".aider.input.history"
  "copilot-instructions.md"
)
# Case-insensitive: a checkout on a case-insensitive filesystem would
# collapse e.g. "Claude.md" onto "CLAUDE.md" anyway, so match the same way here.
for rel in "${TRACKED_FILES[@]}"; do
  IFS='/' read -ra parts <<< "$rel"
  for part in "${parts[@]}"; do
    for name in "${PRIVATE_ASSISTANT_NAMES[@]}"; do
      if [[ "${part,,}" == "${name,,}" ]]; then
        fail "$rel [private-assistant-file]: private assistant file must not be committed"
        continue 3
      fi
    done
  done
done

# 5. Obvious secret patterns. Reports the path and rule name only; the
# matched value is never printed.
SECRET_RULES=(
  "github-token:gh[opsu]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}"
  "aws-access-key:AKIA[0-9A-Z]{16}"
  "notion-token:secret_[A-Za-z0-9]{43}|ntn_[A-Za-z0-9]{20,}"
  "slack-token:xox[baprs]-[A-Za-z0-9-]{10,}"
  "private-key-block:-----BEGIN [A-Z ]*PRIVATE KEY-----"
)
for rel in "${TRACKED_FILES[@]}"; do
  is_secret_allowlisted "$rel" && continue
  for rule_entry in "${SECRET_RULES[@]}"; do
    rule_name="${rule_entry%%:*}"
    pattern="${rule_entry#*:}"
    if grep -IqE -e "$pattern" "$target/$rel" 2>/dev/null; then
      fail "$rel [$rule_name]: possible secret detected (value withheld)"
    fi
  done
done

# 6. Third-party actions and reusable workflows are pinned to a full commit
# SHA: the sync workflow runs with contents:write, so a moved upstream tag
# executes attacker code with those permissions. Local ./ refs are this
# repository and carry no upstream to move.
USES_LINE_RE='^[[:space:]]*(-[[:space:]]+)?uses:[[:space:]]*([^[:space:]]+)(.*)$'
VERSION_COMMENT_RE='#[[:space:]]*v?[0-9]+(\.[0-9]+)+'
quote="'"
for rel in "${TRACKED_FILES[@]}"; do
  case "$rel" in
    .github/workflows/*.yml|.github/workflows/*.yaml) ;;
    *) continue ;;
  esac
  while IFS= read -r line; do
    [[ "$line" =~ $USES_LINE_RE ]] || continue
    value="${BASH_REMATCH[2]}"
    rest="${BASH_REMATCH[3]}"
    value="${value%\"}"; value="${value#\"}"
    value="${value%$quote}"; value="${value#$quote}"
    [[ "$value" == ./* ]] && continue
    ref="${value##*@}"
    if [[ ! "$ref" =~ ^[0-9a-fA-F]{40}$ ]]; then
      fail "$rel [action-pin]: uses: '$value' must be pinned to a full 40-hex commit SHA"
    elif [[ ! "$rest" =~ $VERSION_COMMENT_RE ]]; then
      fail "$rel [action-pin]: uses: '$value' is pinned but has no version comment (expected '@<sha> # vX.Y.Z')"
    fi
  done < "$target/$rel"
done

if (( failures != 0 )); then
  exit 1
fi

echo "Template hygiene checks passed."
