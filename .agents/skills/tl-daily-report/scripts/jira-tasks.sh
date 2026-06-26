#!/usr/bin/env bash
# Fetches active Jira tasks for the current user and prints KEY | SUMMARY | STATUS.
# Requires: UBER_OWNER env var (e.g. rkochp@ext.uber.com)
# Usage: bash jira-tasks.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=jw.sh
source "${SCRIPT_DIR}/jw.sh"

: "${UBER_OWNER:?UBER_OWNER env var is not set. Export your Uber email, e.g.: export UBER_OWNER=you@ext.uber.com}"

jira_setup_auth

jira_cmd issue list \
  --jql "assignee = \"${UBER_OWNER}\" AND statusCategory != Done" \
  --no-headers \
  --plain \
  --columns KEY,SUMMARY,STATUS
