---
name: tl-weekly-report
description: Generates a weekly standup summary for Rafael Koch Peres by fetching standup messages from the #truelogic-ta Slack channel. Use when user says 'weekly report', 'tl weekly report', 'generate my weekly report', 'standup report', or 'weekly standup summary'.
---

# TL Weekly Report

Fetches standup thread replies from #truelogic-ta and outputs them as plain text, one entry per day. No markdown, no narrative rewriting — copy the standup content as-is.

## Quick start

Invoke with `/tl-weekly-report` or ask "generate my weekly report". Defaults to current week; uses last week if today is Sunday or Monday.

## Workflow

### 1. Determine the target week

Today is available via the `currentDate` context. 
- If today is **Sunday or Monday** → target = **last week** (Mon–Fri)
- Otherwise → target = **current week** (Mon–Fri up to today)

Compute the Monday and Friday timestamps for the target week.

### 2. Find standup threads in #truelogic-ta

Channel ID: `C04937T44M6`  
User ID: `U04F4ELC10T` (rkochp)

Search for standup workflow messages using `slack_search_public_and_private`:
```
in:truelogic-ta on:week is:thread "Here are the updates from" rkochp
```

Or for last week:
```
in:truelogic-ta on:lastweek is:thread "Here are the updates from" rkochp
```

These threads are started by the "Time for our Daily Stand Up updates" workflow. The workflow message starts with `:sunny: Please provide your Stand-Up Updates`.

### 3. Read each standup thread

For each matching thread, use `slack_read_thread` with the thread's `message_ts` and channel ID `C04937T44M6`. Filter replies authored by `U04F4ELC10T` (rkochp) — those are Rafael's standup entries.

Map each thread to its weekday based on the message timestamp.

### 4. Parse each standup entry

Each standup reply typically contains three sections. Extract the bullet points under each section verbatim. The sections may be labeled with Slack emoji or plain text variants of:
- "Accomplished yesterday" / "Yesterday"
- "Will accomplish today" / "Today"
- "Blockers"

Copy the bullet items exactly as written — do not rephrase, summarize, or reformat.

### 5. Generate the report

Output plain text — no markdown headers, no bold, no formatting symbols. Use this exact structure for each day:

```
[Weekday name]

Accomplished yesterday:
- item 1
- item 2

Will accomplish today:
- item 1
- item 2

Blockers:
- item 1

---
```

Separate each day with a `---` divider line.

- Use the full weekday name as the day label (e.g., `Monday`, `Tuesday`)
- Copy bullet text verbatim from the standup; strip any Slack emoji if they clutter the text
- If a section has no items, write `- None`
- If no standup found for a day (holiday, absence), skip that day silently
- Do not add introductory or closing summaries

## Example output

```
Monday

Accomplished yesterday:
- Investigated PSI automation flow for careers environment
- Reviewed integration points with freeze flag

Will accomplish today:
- Implement freeze gating logic
- Submit PR for review

Blockers:
- None

---

Tuesday

Accomplished yesterday:
- Submitted PR for automation freeze gating (PEOPLEPROD-30198)
- Triaged issue with recruiters added as Optional attendees in interview invites

Will accomplish today:
- Address review feedback on freeze PR
- Follow up on PEOPLEPROD-30198 triage

Blockers:
- Waiting for design sign-off on freeze behavior

---
```

## Notes

- The Slack search `on:week` / `on:lastweek` covers Mon–Sun; filter results to Mon–Fri only
- If search returns no threads, try reading the channel directly with `slack_read_channel` for the date range and scan for workflow messages manually
- The workflow bot posts once per day per weekday; Rafael's reply in that thread is his standup update
