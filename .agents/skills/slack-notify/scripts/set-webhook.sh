#!/usr/bin/env bash
# Persist the Slack notify webhook URL to ~/.envsecrets for future sessions.
# Usage: set-webhook.sh "https://hooks.slack.com/triggers/..."
set -euo pipefail

url="${1:-}"
case "$url" in
  https://hooks.slack.com/triggers/*) ;;
  *) echo "invalid webhook url (expected https://hooks.slack.com/triggers/...)" >&2; exit 2 ;;
esac

secrets="$HOME/.envsecrets"
touch "$secrets"
chmod 600 "$secrets"

# Replace any existing line, else append.
if grep -q '^export SLACK_NOTIFY_WEBHOOK_URL=' "$secrets" 2>/dev/null; then
  tmp=$(mktemp)
  grep -v '^export SLACK_NOTIFY_WEBHOOK_URL=' "$secrets" > "$tmp"
  mv "$tmp" "$secrets"
  chmod 600 "$secrets"
fi
printf 'export SLACK_NOTIFY_WEBHOOK_URL=%q\n' "$url" >> "$secrets"
echo "saved to ~/.envsecrets"
