#!/usr/bin/env bash
# Send a Slack self-notification via the Workflow Builder webhook.
# Usage: notify.sh "message text"
# Reads SLACK_NOTIFY_WEBHOOK_URL from env, falling back to ~/.envsecrets.
set -euo pipefail

msg="${1:-}"
if [ -z "$msg" ]; then
  echo "usage: notify.sh \"message\"" >&2
  exit 2
fi

if [ -z "${SLACK_NOTIFY_WEBHOOK_URL:-}" ] && [ -f "$HOME/.envsecrets" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.envsecrets"
fi

if [ -z "${SLACK_NOTIFY_WEBHOOK_URL:-}" ]; then
  echo "SLACK_NOTIFY_WEBHOOK_URL not set (checked env and ~/.envsecrets)" >&2
  exit 1
fi

# Build JSON safely (escapes quotes/newlines in the message).
payload=$(msg="$msg" python3 -c 'import json,os; print(json.dumps({"message": os.environ["msg"]}))')

curl -sS -X POST -H "Content-Type: application/json" \
  -d "$payload" "$SLACK_NOTIFY_WEBHOOK_URL"
echo
