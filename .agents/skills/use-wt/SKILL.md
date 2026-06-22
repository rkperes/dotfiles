---
name: use-wt
description: Select and switch into an existing, manually-created git worktree (reused across tasks) instead of spawning a fresh one. Lists reusable worktrees, claims one via `git worktree lock` so two agents never collide, moves the agent root into it, and confines ALL further work to that worktree. Use when the user runs /use-wt or /use-worktree, passes /use-wt <index>, or asks to pick / claim / reuse / release an existing worktree without creating a new one.
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

### 1. Locate the monorepo

Run `git worktree list --porcelain` from the current cwd. If it fails (not in a
repo), ask the user for the monorepo path and run `git -C <path> worktree list --porcelain`.
Use that `<path>` as the git context for every command below.

### 2. List + classify worktrees

Parse the porcelain output. Records are separated by blank lines; the **first
record is the main worktree — it is off-limits and never claimable**.

For each record:
- `worktree <abs-path>` → path
- `branch refs/heads/<name>` → branch (or `detached`)
- a line starting with `locked` → **claimed**; the rest of that line is the reason.

For each non-main worktree also get its dirty state:
`git -C <path> status --porcelain | head -1` (non-empty = dirty).

Present a numbered table of non-main worktrees:

```
#  path                          branch        state
1  /repo/.worktrees/wt-a         feature/x     free, clean
2  /repo/.worktrees/wt-b         feature/y     CLAIMED (cursor | 2026-06-22T14:02 | host=mac) 
3  /repo/.worktrees/wt-c         (detached)    free, dirty
```

"free" = not locked. "CLAIMED" = locked (show the reason verbatim so stale claims are visible).

### 3. Choose a target

- If an arg was given, resolve it to a single free worktree (by index, branch, or
  path substring). If it resolves to a CLAIMED one, stop and report who holds it.
- No arg + one or more free → auto-claim the **first free** one (lowest index).
  State clearly which worktree was auto-claimed and that others were free (e.g.
  "Auto-claimed #1 /repo/.worktrees/wt-a (3 free; pass /use-wt <index> to choose).").
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

### 5. Move agent root into it

Call the `cursor-app-control` MCP tool **`move_agent_to_root`** with the worktree
absolute path (`WT`). This makes `WT` the workspace root so all new terminals
default to it. Then confirm: a fresh `git rev-parse --show-toplevel` must equal `WT`.

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

## Notes on claim semantics

- `git worktree lock` only blocks `git worktree remove/prune` and signals a claim;
  it does **not** lock the files. Concurrency safety comes from lock being atomic
  (the second `lock` fails), not from filesystem locking. That is sufficient here:
  whoever wins the `lock` owns the worktree.
- The reason string carries a UTC timestamp + host + user so humans can spot stale
  claims and decide whether to force-unlock.
