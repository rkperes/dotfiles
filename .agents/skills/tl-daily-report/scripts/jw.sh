#!/usr/bin/env bash
# Auth helpers for jira-cli (ankitpokhrel). Mirrors ~/.uberrc jira() function.
set -euo pipefail

if ! command -v jira >/dev/null 2>&1; then
  echo "Error: jira CLI not found. See REFERENCE.md for install steps." >&2
  exit 127
fi

jira_setup_auth() {
  export JIRA_AUTH_TYPE=bearer
  export JIRA_API_TOKEN
  JIRA_API_TOKEN="$(usso -ussh jira.uberinternal.com -print 2>/dev/null | tail -1 || true)"

  if [[ -z "${JIRA_API_TOKEN}" ]]; then
    echo "Error: failed to obtain Jira bearer token via usso (jira.uberinternal.com)." >&2
    echo "Check VPN/network and try: usso -ussh jira.uberinternal.com" >&2
    exit 1
  fi
}

# Run jira with auth; close stdin so non-interactive commands do not hang.
jira_cmd() {
  jira "$@" </dev/null
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  jira_setup_auth
  exec jira "$@" </dev/null
fi
