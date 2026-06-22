---
name: use-worktree
description: Alias of the use-wt skill. Select and switch into an existing, reused git worktree, claim it via `git worktree lock` so two agents never collide, move the agent root into it, and confine all work to that worktree. Use when the user runs /use-worktree or asks to pick / claim / reuse an existing worktree.
disable-model-invocation: true
---

# use-worktree (alias of use-wt)

This is an alias. Read and follow the canonical skill at
`~/.agents/skill/use-wt/SKILL.md` and execute that workflow exactly, passing
through any argument the user gave (index, branch/path substring, or `release`).
