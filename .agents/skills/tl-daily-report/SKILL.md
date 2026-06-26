---
name: tl-daily-report
description: Generates a daily standup report by pulling current Jira tasks, yesterday's standup from #truelogic-ta, and recent Slack messages. Drafts answers to all four standup questions with task progress indicators, then grills the user on today's priorities before finalizing. Use when user says 'daily report', 'standup report', 'daily standup', 'generate my standup', 'what should I report today', or invokes /tl-daily-report.
---

# TL Daily Report

Drafts the daily standup for #truelogic-ta from Jira task state, yesterday's standup thread, and Slack activity.

## Identity

- Slack channel: `#truelogic-ta` (ID: `C04937T44M6`)
- Jira project: `PEOPLEPROD`
- User identified via `UBER_OWNER` env var (e.g. `rkochp@ext.uber.com`)

## Step 0 — Check prerequisites

Before fetching data, verify setup. If anything is missing, print the relevant section from [REFERENCE.md](REFERENCE.md) and stop.

**Check jira CLI:**
```bash
bash ~/.agents/skills/tl-daily-report/scripts/jira-tasks.sh
```
- Exit 127 → jira CLI not installed → show install instructions from REFERENCE.md § jira-cli
- Auth error → show REFERENCE.md § Auth
- `UBER_OWNER` unset → show REFERENCE.md § UBER_OWNER

**Check Slack MCP:**
- Try `slack_search_public_and_private` with a simple query
- If unavailable or auth error → note it, fall back to manual paste (see Step 1b)

## Step 1 — Gather data (run in parallel where possible)

**1a. Jira — active tasks:**
```bash
bash ~/.agents/skills/tl-daily-report/scripts/jira-tasks.sh
```
Returns `KEY | SUMMARY | STATUS` for all non-Done tasks assigned to `$UBER_OWNER`.

**1b. Slack — yesterday's standup thread:**
Via `slack_search_public_and_private`:
```
in:truelogic-ta from:me is:thread "Here are the updates from" rkochp
```
Take the most recent result. Its "will accomplish today" = "accomplished yesterday" in today's report.

If Slack MCP unavailable: ask the user to paste their last standup update.

**1c. Slack — today's ad-hoc messages:**
```
in:truelogic-ta from:me on:today
```
Add `on:yesterday` if early in the day. Look for deploys, reviews, coordination, announcements not in Jira.

If Slack MCP unavailable: ask the user to describe any additional work done yesterday.

## Step 2 — Map task progress

For each Jira task, infer its current stage from Jira status + standup history:

| Stage | Meaning |
|---|---|
| `to do` | Not yet started |
| `in development` | Being coded, no PR yet |
| `pending tests` | Code done, testing in progress |
| `pr up for review` | PR submitted, awaiting review/approval |
| `done` | Landed / closed |

A task with multiple code changes may show progression inline:
`[pr up for review → in development]` (PR 1 landed, PR 2 in progress)

Use standup history clues: "PR raised" → `pr up for review`, "landed" → `done`, "tested" → `pending tests`, "coding" → `in development`.

## Step 3 — Draft the report

Bullet format:
```
* PEOPLEPROD-XXXX "Task name" [stage]: one-line description
* Report for additional effort w/o Jira task [stage]: description
```

**Q1 — Accomplished yesterday:**
- Base on previous standup's "will accomplish today"
- Add Slack-visible work (PRs, deploys, reviews, coordination)
- Skip pure waiting

**Q2 — Will accomplish today:**
- Suggest from active tasks with clear next steps + user's stated priorities
- Do NOT finalize — grill user first (Step 4)

**Q3 — Blockers:**
- Only critical external dependencies (other team, non-team approval, external system)
- Format: `* PEOPLEPROD-XXXX: blocked on [who] for [reason]`
- Routine review waits: skip unless materially blocking
- If none: `-`

**Q4 — Other comments:**
- Only genuinely noteworthy items (incident, announcement, team-wide impact)
- If none: `-`

## Step 4 — Grill the user

Present the draft, then ask:
- "Accomplished yesterday — anything missing or wrong?"
- "Today's focus — anything new that should reprioritize what I suggested?"
- "Any blockers to add?"
- "Anything for comments?"

Incorporate answers and finalize.

## Step 5 — Handle untracked work

For any "Report for additional effort w/o Jira task" bullet, offer:
> "Want me to create a Jira ticket for this?"

If yes:
```bash
bash ~/.agents/skills/tl-daily-report/scripts/jw.sh issue create \
  --project PEOPLEPROD --type Task --summary "..." --no-input
```
Update the bullet with the returned ticket key.

## Step 6 — Output

Print paste-ready standup text:
```
What was accomplished yesterday for each JIRA task assigned?:
* PEOPLEPROD-XXXX "..." [stage]: ...

What will be accomplished today for each JIRA task assigned?:
* PEOPLEPROD-XXXX "..." [stage]: ...

Status of blockers for each JIRA task assigned:
-

Other comments or highlights worth reporting?:
-
```

## See also

- [REFERENCE.md](REFERENCE.md) — install instructions, auth setup, troubleshooting
- [scripts/jw.sh](scripts/jw.sh) — Jira auth wrapper (mirrors `~/.uberrc` jira function)
- [scripts/jira-tasks.sh](scripts/jira-tasks.sh) — fetches active tasks
