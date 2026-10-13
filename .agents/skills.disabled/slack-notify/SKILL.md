---
name: slack-notify
description: Send a Slack notification to yourself via a Workflow Builder incoming webhook. Use when the user wants to be pinged/notified on Slack about an event, task completion, long-running job, or when they say "notify me", "ping me on slack", "send me a slack", or "let me know when done".
---

# Slack Notify (self-ping)

Sends a Slack notification that actually pings you. Slack never notifies you
about your own messages, so a plain user-token send won't work — this skill
posts through a **Workflow Builder webhook**, which delivers as Workflowbot
(a different sender) and triggers a real notification.

## Step 0 — Preflight (do this IMMEDIATELY when the skill is triggered)

Verify the webhook is configured **up front**, before starting any slow work
the user asked to be notified about. The actual send may happen minutes later;
the URL must be collected now, not at send time.

```bash
~/.agents/skills/slack-notify/scripts/check.sh   # prints "ready" or "missing"
```

If it prints `missing`:

1. Ask the user for their Slack Workflow webhook URL (format
   `https://hooks.slack.com/triggers/...`). Explain briefly how to get one:
   Slack → Automations/Workflow Builder → new workflow → **From a webhook**
   trigger with one Text variable `message` → **Send a message** step (DM to
   self, or channel with `<@USER_ID>` to force a ping) → publish → copy URL.
2. Persist it for future sessions:
   ```bash
   ~/.agents/skills/slack-notify/scripts/set-webhook.sh "<PASTED_URL>"
   ```
3. Re-run `check.sh` to confirm `ready`, then proceed with the user's task.

Only after preflight passes should you kick off the long-running work.

## Quick start

```bash
~/.agents/skills/slack-notify/scripts/notify.sh "Build finished ✅"
```

Success prints `{"ok":true}`.

## How it works

- The webhook URL is **secret**. It lives in `~/.envsecrets` as
  `SLACK_NOTIFY_WEBHOOK_URL` (sourced by `~/.profile`; never committed to
  dotfiles).
- `scripts/notify.sh` reads the URL from the env var, falling back to sourcing
  `~/.envsecrets` directly, then POSTs `{"message": "<text>"}`.

## Manual call (if not using the script)

Read the URL, then POST the exact body shape (only change `message`):

```bash
. ~/.envsecrets
curl -sS -X POST -H "Content-Type: application/json" \
  -d '{"message": "your text here"}' "$SLACK_NOTIFY_WEBHOOK_URL"
```

## Auto-notify (hooks)

This skill is also driven automatically by Claude Code hooks (in
`~/.claude/settings.local.json`), tuned **low-noise**: you're pinged only when
you've gone **idle** ("come back"), when a **run took 1 min+** (`Stop` gated by a
`UserPromptSubmit` start-stamp), or when a **background agent finishes**. Glue:
`scripts/hook-notify.sh` + `scripts/hook-timer.sh`. Threshold override:
`SLACK_NOTIFY_LONGRUN_S`. See [HOOKS.md](HOOKS.md) for the event map and rollback.

## Rules

- Only alter the value of `message`; keep the JSON shape `{"message": "..."}`.
- Never print, log, or commit the webhook URL — treat it as a credential.
- Keep messages concise; no sensitive/PII data in notifications.
