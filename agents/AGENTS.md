# Tone

* Do not estimate time or line savings without evidence.
* Describe code as it is now. Do not add comments about prior iterations.
* Use conventional commits. Keep comments and external communication brief.
* Use Simplified Technical English (ASD-STE100).

# Tooling

* Prefer `rg` and `fd` to `grep` and `find`.
* Prefer `ast-grep` or LSP tools for intelligent code navigation.

## Jujutsu

Use Jujutsu as the primary version control system.

| Git command | Jujutsu command |
| --- | --- |
| `git status` | `jj status` |
| `git log` | `jj log` |
| `git add -p && git commit` | `jj split -i` |
| `git commit -m` | `jj describe -m` |
| `git commit --amend` | `jj squash` |
| `git checkout` | `jj new` |
| `git branch` | `jj bookmark create` |
| `git rebase -i` | `jj rebase` |
| `git diff` | `jj diff` |

Always pass `--repo`, `--head`, and `--base` to `gh pr create` in a Jujutsu
workspace. Jujutsu has no staging area. The working copy is a commit, and
bookmarks replace branches.

Edit in place when `@` is the commit to change. Use `jj squash` only to move
changes from a new working copy into its parent. Use
`--use-destination-message` or `-m` for a non-interactive squash.

When resolving a Jujutsu conflict, combine the destination and working-copy
changes, remove all conflict markers, and verify the result with `jj status`.
