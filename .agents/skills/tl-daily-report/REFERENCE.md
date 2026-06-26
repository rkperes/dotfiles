# TL Daily Report — Setup Reference

## Prerequisites

### 1. jira-cli (ankitpokhrel)

```bash
GOPROXY=proxy.golang.org \
  go install github.com/ankitpokhrel/jira-cli/cmd/jira@latest
```

Ensure `$GOPATH/bin` (or `$HOME/go/bin`) is on `PATH`. Verify: `jira version`

**First-time config:**
```bash
jira init
```
- Server: `https://jira.uberinternal.com`
- Project: `PEOPLEPROD`
- Board: `Truelogic @ Uber TA` (ID 10089)
- Auth type: **bearer** (token is injected at runtime — do not set a static token)

Config file: `~/.config/.jira/.config.yml`

**Auth (Uber internal):**

The skill uses `scripts/jw.sh`, which mirrors the `jira()` shell function in `~/.uberrc`:
```bash
export JIRA_AUTH_TYPE=bearer
export JIRA_API_TOKEN="$(usso -ussh jira.uberinternal.com -print 2>/dev/null | tail -1)"
```

Requires `usso` and network/VPN access to `jira.uberinternal.com`.

Test auth:
```bash
bash ~/.agents/skills/tl-daily-report/scripts/jw.sh me
```

### 2. UBER_OWNER env var

Export your Uber email in your shell profile (`~/.zshrc` or `~/.bashrc`):
```bash
export UBER_OWNER="you@ext.uber.com"
```

The skill uses this in Jira JQL queries. Without it, `jira-tasks.sh` will exit with a clear error.

### 3. Slack MCP

The skill fetches standup threads via the `slack-mcp` MCP server. To set it up:

1. Visit: `https://usso.uberinternal.com/v2/third_party/oauth2/credentials`
2. Complete the Slack OAuth flow (authorize the `slack-mcp` partner)
3. Ensure `slack-mcp` is enabled in your Claude Code MCP config

The skill will work without Slack MCP, but you'll need to paste your previous standup manually so it can infer "accomplished yesterday."

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `jira CLI not found` | Install jira-cli; ensure `$HOME/go/bin` is on PATH |
| `failed to obtain bearer token` | Run `usso -ussh jira.uberinternal.com`; check VPN |
| `jira init` / config missing | Run `jira init`; confirm `~/.config/.jira/.config.yml` |
| `UBER_OWNER unset` | Export your Uber email in shell profile |
| Slack search returns nothing | Complete Slack MCP OAuth at usso link above |
| Standup thread not found | Paste your last standup manually when prompted |
