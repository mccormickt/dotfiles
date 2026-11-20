# Tone

* Don't estimate time savings or line savings unless you actually have a good idea of how much time or lines it will save. It is rarely correct and often misleading.
* Never add comments in code about prior iterations, or compare implementations to past state. Always describe the code as it is *currently*.
* Always use conventional commits and keep comments, commit & PR descriptions, and external communications focused and brief
* Use Simplified Technical English (ASD-STE100) for ALL communication, internal and external

# Tooling
* Prefer ripgrep `rg` and `fd` to traditional `grep` and `find` commands, respectively
* Prefer `ast-grep`, or LSP tooling for intelligent codebase navigation over string searching

## Jujutsu (jj) - Preferred Over Git

Use **Jujutsu** (`jj`) as the primary version control system. Jujutsu is a Git-compatible VCS with a simpler, more powerful workflow. Always prefer `jj` commands over `git` commands.

### Workflows

| Git Command | Jujutsu Equivalent | Notes |
|-------------|-------------------|-------|
| `git status` | `jj status` or `jj st` | Shows working copy changes |
| `git log` | `jj log` | Shows commit graph |
| `git add -p && git commit` | `jj split -i` | Split working copy interactively |
| `git commit -m "msg"` | `jj describe -m "msg"` | Describe current commit |
| `git commit --amend` | `jj squash` | Squash changes into parent |
| `git checkout <branch>` | `jj new <bookmark>` | Create new commit on bookmark |
| `git branch <name>` | `jj bookmark create <name>` | Create bookmark (not branch) |
| `git rebase -i` | `jj rebase -r <rev> -d <dest>` | Rebase specific commits |
| `git diff` | `jj diff` | Show changes |

**`gh` in jj workspaces**

Always pass `--repo`, `--head`, and `--base` explicitly to `gh pr create` (and similar `gh` commands that infer the current branch). jj workspaces use symlinks to the parent repo's `.git` directory, and `gh` can't infer the current branch from that layout — otherwise you'll get:

```
could not determine the current branch: could not determine current branch: failed to run git: not on any branch
```

```
gh pr create --repo <owner/repo> --head <bookmark-name> --base main --title "..." --body "..."
```

**Important Notes**
- No staging area: There's no git add equivalent - changes are always tracked
- Bookmarks, not branches: Use jj bookmark commands instead of git branch
- Working copy is a commit: Your working directory is treated as a regular commit. Any file edits automatically amend the current working copy commit — there is no separate "stage and commit" step.
- Conflicts are okay: You can commit conflicts and resolve them later
- You start a new working copy *before* you start work and can rename it at any time.

**When to use `jj squash` vs just editing in place:**
- If you edit files while the working copy (`@`) is the commit you want to change, the edits amend that commit directly. No `jj squash` needed — just push the bookmark.
- Only use `jj squash` when you created a *new* working copy (`jj new`) on top of a commit, made fixes there, and want to fold those fixes back into the parent.
- In other words: `jj squash` moves changes from `@` into `@-`. If `@` is already the commit you're fixing, squashing would incorrectly meld it into its parent.
- `jj squash` is interactive if the working copy (`@`) has a description. It will hang waiting on an editor to merge the two descriptions. Use `--use-destination-message` or `-m` for headless.

### Resolve Merge Conflicts

Resolve jj merge conflicts in the current workspace after a rebase operation.
jj conflicts look like this:

```
<<<<<<< conflict N of M
+++++++ [destination commit info]
content from destination (what we rebased onto)
%%%%%%% diff from: [base] to: [our branch]
+lines we added
-lines we removed
>>>>>>> conflict N of M ends
```

1. Read each conflicted file
2. For each conflict block:
   - Look at what destination added (`+++++++` section)
   - Look at what we added (`+` lines in `%%%%%%%` section)
   - Combine both sets of changes
   - Remove ALL conflict markers
3. Run `jj status` to verify conflicts are resolved

