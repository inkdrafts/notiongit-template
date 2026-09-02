#!/usr/bin/env bash

set -euo pipefail

config_file="_config.yml"

if [[ ! -f "$config_file" ]]; then
  echo "Missing $config_file" >&2
  exit 1
fi

failures=0

require_line() {
  local description="$1"
  local pattern="$2"

  if ! grep -Eq "$pattern" "$config_file"; then
    echo "Expected neutral $description in $config_file" >&2
    failures=1
  fi
}

require_line "title" '^[[:space:]]*title:[[:space:]]*"NotionGit"[[:space:]]*$'
require_line "description" '^[[:space:]]*description:[[:space:]]*"A Notion-powered Jekyll site\."[[:space:]]*$'
require_line "url" '^[[:space:]]*url:[[:space:]]*""[[:space:]]*$'
require_line "baseurl" '^[[:space:]]*baseurl:[[:space:]]*""[[:space:]]*$'
require_line "author name" '^[[:space:]]*name:[[:space:]]*""[[:space:]]*$'
require_line "author email" '^[[:space:]]*email:[[:space:]]*""[[:space:]]*$'

if grep -Eiq 'leandrollosa|leandro[[:space:]-]+llosa' "$config_file"; then
  echo "Personal identity or domain found in $config_file" >&2
  failures=1
fi

if git grep -n -i -E 'leandrollosa|leandro[[:space:]-]+llosa' -- . \
  ':!README.md' ':!scripts/check-neutral-config.sh'; then
  echo "Personal identity or domain found outside documentation." >&2
  failures=1
fi

if (( failures != 0 )); then
  exit 1
fi

echo "_config.yml contains neutral template metadata."
