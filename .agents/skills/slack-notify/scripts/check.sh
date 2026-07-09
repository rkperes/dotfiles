#!/usr/bin/env bash
# Preflight: verify the Slack notify webhook is configured.
# Exit 0 = ready (prints "ready"). Exit 1 = missing (agent must collect URL).
set -euo pipefail

if [ -z "${SLACK_NOTIFY_WEBHOOK_URL:-}" ] && [ -f "$HOME/.envsecrets" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.envsecrets"
fi

if [ -z "${SLACK_NOTIFY_WEBHOOK_URL:-}" ]; then
  echo "missing"
  exit 1
fi
echo "ready"
