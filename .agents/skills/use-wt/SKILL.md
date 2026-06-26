---
name: use-wt
description: Select and switch into an existing, manually-created git worktree (reused across tasks) instead of spawning a fresh one. Lists reusable worktrees, prefers ones scoped to the current workspace/cwd (project-level, e.g. ~/repo/src/.../my-project/.worktrees) over repo-root ones, claims one via `git worktree lock` so two agents never collide, moves the agent root into it, and confines ALL further work to that worktree. Use when the user runs /use-wt or /use-worktree, passes /use-wt <index>, or asks to pick / claim / reuse / release an existing worktree without creating a new one.
disable-model-invocation: true
---

# use-wt — work inside a reused worktree

Analogous to `/worktree`, but the source of work is an **existing** worktree that
the user pre-created (they live in a gitignored dir and show up in
`git worktree list`). This skill never creates or deletes worktrees.

## Arguments

- `/use-wt` — list claimable worktrees and pick one (auto-pick if exactly one free).
- `/use-wt <index>` — claim the worktree at `<index>` from the list this skill prints.
- `/use-wt <branch|path-substring>` — claim the worktree matching that branch or path.
- `/use-wt release` — release the worktree currently claimed by this session.

> `/use-wt-<index>` as a literal command is not feasible (it would need one skill
> per index). Use the argument form `/use-wt <index>` instead.

## Workflow

Copy this checklist and track it:

```
- [ ] 1. Locate the monorepo
- [ ] 2. List + classify worktrees
- [ ] 3. Choose a target
- [ ] 4. Claim it (atomic lock)
- [ ] 5. Move agent root into it
- [ ] 6. Lock in the hard restrictions
- [ ] 7. (later) Release
```

### 1. Locate the repo + capture the workspace scope chain

Run these from a fresh terminal (its cwd defaults to the current Cursor workspace root):

```bash
git rev-parse --show-toplevel   # REPO_ROOT = main checkout root
git rev-parse --show-prefix     # OFFSET = workspace subdir relative to repo root (may be empty)
pwd -P                          # WORKSPACE = current workspace/cwd, symlinks resolved
```

If the first fails (not in a repo), ask the user for the monorepo path and use
`git -C <path> worktree list --porcelain` for every command below.

- `REPO_ROOT` = main checkout (also the first record of `git worktree list`).
- `WORKSPACE` = the **current Cursor workspace root** (or plain cwd when not in a
  Cursor workspace) = `REPO_ROOT/OFFSET`. This is the **preferred scope** — agents
  usually run in the context of one project (e.g. `~/go-code/src/people/scout-hire`),
  not the whole monorepo.
- `OFFSET` = `WORKSPACE` relative to `REPO_ROOT` (e.g.
  `src/code.uber.internal/people/scout-hire/`). Empty if the workspace **is** the repo root.

Build the **scope chain**: start at `WORKSPACE`, then walk parent directories
recursively, up to and including `REPO_ROOT`. Order it most-specific first
(`WORKSPACE`) to least-specific last (`REPO_ROOT`). Example, working in scout-hire:

```
1. ~/go-code/src/code.uber.internal/people/scout-hire   (WORKSPACE — most specific)
2. ~/go-code/src/code.uber.internal/people
3. ~/go-code/src/code.uber.internal
4. ~/go-code/src
5. ~/go-code                                             (REPO_ROOT — least specific)
```

The scope chain is what makes selection prefer **project-level** worktrees (e.g.
`~/go-code/src/.../scout-hire/.worktrees/…`) over repo-root ones
(`~/go-code/.worktrees/…`) when both exist. See Step 3.

Why scope also matters for *opening*: a worktree is a *separate full checkout*. If
you open the worktree **root** while the user's workspace is scoped to a subdir,
Cursor opens a differently-scoped workspace (the whole monorepo). `OFFSET` lets you
open the worktree's **equivalent subdir** so the new workspace mirrors the current
one. See "Workspace scoping" at the end.

### 2. List + classify worktrees

Worktrees come from `git worktree list --porcelain` (git's own registry), **not**
from scanning the filesystem — that is authoritative and catches worktrees wherever
they physically live. Parse it: records are separated by blank lines; the **first
record is the main worktree — it is off-limits and never claimable**.

For each record:
- `worktree <abs-path>` → path
- `branch refs/heads/<name>` → branch (or `detached`)
- a line starting with `locked` → **claimed**; the rest of that line is the reason.

For each non-main worktree also get its dirty state:
`git -C <path> status --porcelain | head -1` (non-empty = dirty).

**Tag each worktree with its scope depth.** Walk the scope chain from most specific
to least specific; a worktree's scope = the first chain entry `S` such that its
abs-path starts with `S/`. A worktree at `WORKSPACE/.worktrees/…` tags to depth 1
(in-workspace); one at `REPO_ROOT/.worktrees/…` tags to the last entry (repo-root).
A worktree under a sibling project (no chain entry is a prefix) is **out-of-scope**.

Present a numbered table of non-main worktrees, sorted by scope depth
(most-specific scope first), and show the matched scope so the preference is visible:

```
#  path                                              branch      scope          state
1  /repo/src/.../scout-hire/.worktrees/wt-a          feature/x   workspace      free, clean
2  /repo/src/.../scout-hire/.worktrees/wt-b          feature/y   workspace      CLAIMED (cursor | 2026-06-22T14:02 | host=mac)
3  /repo/.worktrees/wt-c                             feature/z   repo-root      free, clean
4  /repo/src/.../other-team/.worktrees/wt-d          (detached)  out-of-scope   free, dirty
```

"free" = not locked. "CLAIMED" = locked (show the reason verbatim so stale claims are visible).

### 3. Choose a target

Selection prefers worktrees that match the **most specific** scope (Step 1 chain),
so an agent working inside a project reuses that project's worktree instead of a
repo-root one.

- If an arg was given, resolve it to a single free worktree (by index, branch, or
  path substring) regardless of scope. If it resolves to a CLAIMED one, stop and
  report who holds it.
- No arg → among **free** worktrees, pick from the **most specific scope that has a
  free worktree**: prefer in-workspace, then each parent scope, then repo-root, and
  only then out-of-scope. Within the chosen scope, take the lowest index.
  State clearly what was auto-claimed, the scope it matched, and that others were
  free (e.g. "Auto-claimed #1 …/scout-hire/.worktrees/wt-a (workspace scope; 3 free
  total, 2 in-workspace; pass /use-wt <index> to choose).").
- If the only free worktrees are **out-of-scope** (no chain match), do **not**
  auto-claim — list them and ask the user to confirm, since the user is likely
  working in a different project than where those worktrees live.
- **No free worktrees** → show the claimed table with reasons/timestamps and ask
  the user whether to force-release a stale claim (`git worktree unlock <path>`).
  Never silently steal a claim.

### 4. Claim it (atomic lock)

Claiming and the race-arbiter are the same step. `git worktree lock` fails if the
worktree is already locked, so it is an effective mutex:

```bash
git -C <repo> worktree lock --reason "cursor | $(date -u +%FT%TZ) | host=$(hostname -s) | user=$USER | note=<short task note>" <abs-path>
```

- Exit 0 → you own it. Continue.
- Non-zero (already locked) → someone claimed it first. Re-list and pick another
  free one, or report to the user. Do **not** retry on the same path.

Set `WT` = the chosen absolute path. Record `MAIN` = the main worktree path and
`OTHERS` = every other worktree path. These define the no-go zones.

### 5. Move agent root into it — at the same scope

Compute the scoped entry dir: `ENTRY = WT/OFFSET`.

- If `ENTRY` exists (`test -d "$WT/$OFFSET"`), call the `cursor-app-control` MCP
  tool **`move_agent_to_root`** with `ENTRY`. This opens the worktree scoped
  exactly like the user's current workspace (e.g. the scout-hire subdir), not the
  whole monorepo.
- If `OFFSET` is empty, `ENTRY` == `WT` (workspace was already the repo root).
- If `ENTRY` does not exist (worktree's branch lacks that subdir), fall back to
  `move_agent_to_root WT` and warn the user that scope could not be preserved.

Then confirm you landed in the right checkout: a fresh `git rev-parse --show-toplevel`
must equal `WT`. New terminals now default to `ENTRY`.

### 6. Lock in the hard restrictions

From now on, for the rest of this session, treat these as inviolable:

- **`WT` is the only writable root.** Never write, edit, delete, move, `chmod`, or
  generate files outside `WT`.
- **Never touch `MAIN` or any path in `OTHERS`** — no edits, no `cd` into them, no
  `git -C <main>` mutations, no branch switches there.
- **Every terminal command runs with cwd inside `WT`.** Never `cd` out to the main
  repo root. Use `git -C "$WT" ...` or stay inside `WT`.
- **Pre-flight guard before any mutation/commit** — verify the target resolves
  inside `WT`:

```bash
[[ "$(realpath -m "$TARGET")" == "$WT"/* || "$(realpath -m "$TARGET")" == "$WT" ]] \
  || { echo "BLOCKED: $TARGET is outside the claimed worktree"; exit 1; }
```

- **Git scope:** operate only on the branch checked out in `WT`. Don't run
  repo-wide commands from `MAIN`, don't push/rebase other worktrees' branches.
- **Worktree admin:** the only worktree-administration commands you may run are
  `lock`/`unlock` for **this** `WT`. Never `git worktree add/remove/prune/move`.
- Reading a file outside `WT` is allowed only when strictly necessary for
  reference and read-only; prefer staying inside `WT`. If a task genuinely needs
  changes outside `WT`, **stop and ask** — do not cross the boundary on your own.

### 7. Release

When the work is done or handed off, release the claim so the worktree is reusable:

```bash
git -C <repo> worktree unlock "$WT"
```

`/use-wt release` performs this for the current `WT`. If the user wants the claim
to persist across sessions (so they keep "owning" it), leave it locked and tell
them to run the unlock above when finished. A claim left locked blocks others
until released — that is the intended safety, not a bug.

## Workspace scoping

- A worktree is a **separate directory tree**, so opening it is always a distinct
  workspace folder from the main checkout — that is inherent to worktrees, not a
  bug. The goal here is to make that workspace have the **same shape** as the
  current one, not to literally stay in the same window.
- `ENTRY = WT/OFFSET` reproduces the user's subdir-scoped view inside the worktree.
  This holds wherever the worktree physically lives — a worktree is always a full
  checkout, so `OFFSET` is appended regardless of whether the worktree dir sits at
  repo-root `.worktrees/` or under a project subdir's `.worktrees/`.
- The user does **not** need to create worktrees in any special location — but
  worktrees placed under the current workspace/project (e.g.
  `…/scout-hire/.worktrees/`) are **preferred** during selection (Step 3) because
  they belong to the project the agent is working in. Repo-root `.worktrees/` still
  works as a fallback.
- The safety boundary stays the **whole worktree root `WT`** (since `ENTRY ⊂ WT`),
  so all Step 6 guards apply unchanged.
- True single-window (the main subdir and a worktree subdir open together) is only
  possible with a multi-root `.code-workspace` that adds the worktree subdir as a
  second folder — that is a manual VS Code/Cursor setup, not something
  `move_agent_to_root` can do, and it weakens the "one agent per worktree"
  isolation. Prefer the scoped-entry approach above.

## Notes on claim semantics

- `git worktree lock` only blocks `git worktree remove/prune` and signals a claim;
  it does **not** lock the files. Concurrency safety comes from lock being atomic
  (the second `lock` fails), not from filesystem locking. That is sufficient here:
  whoever wins the `lock` owns the worktree.
- The reason string carries a UTC timestamp + host + user so humans can spot stale
  claims and decide whether to force-unlock.
