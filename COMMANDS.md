# Commands Guide

A reference of the commands used in this repo, with a plain explanation of what each one does and why it is used.

## 1. One-time Git setup

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

| Command | What it does |
|---|---|
| `git config --global user.name` | Sets the name stored in every commit you make |
| `git config --global user.email` | Sets the email stored in every commit (use the one linked to GitHub) |
| `git config --global init.defaultBranch main` | New repos start with a branch called `main` instead of `master` |

## 2. Creating the repo and connecting to GitHub

```bash
bash devops-bootstrap.sh linux-devops-lab
cd linux-devops-lab
git remote add origin git@github.com:<username>/linux-devops-lab.git
git push -u origin main
```

| Command | What it does |
|---|---|
| `bash devops-bootstrap.sh <name>` | Runs the setup script that creates the folders, scripts, Dockerfile, CI workflow and first commit |
| `git init -b main` | (Run inside the script) turns a folder into a Git repo with `main` as the first branch |
| `git remote add origin <url>` | Tells Git where the GitHub copy of the repo lives and names that link `origin` |
| `git push -u origin main` | Uploads `main` to GitHub. `-u` remembers the link, so later `git push` and `git pull` need no extra arguments |
| `git remote -v` | Shows which URL `origin` points to |
| `git remote set-url origin <url>` | Changes the URL, for example to fix a username spelling or switch between SSH and HTTPS |

## 3. The daily workflow: branch, change, PR, merge

This is the loop used for every change in this repo. Nothing is pushed straight to `main`.

```bash
git switch main
git pull
git switch -c feature/add-memory-check
# ...edit or create files...
git add scripts/memory_check.sh
git commit -m "feat: add memory check script"
git push -u origin feature/add-memory-check
# open a pull request on GitHub, wait for green checks, merge
git switch main
git pull
git branch -d feature/add-memory-check
git push origin --delete feature/add-memory-check
```

| Command | What it does |
|---|---|
| `git switch main` | Moves your working folder to the `main` branch |
| `git pull` | Downloads new commits from GitHub and applies them to your current branch. Always do this before starting new work |
| `git switch -c <branch>` | Creates a new branch and switches to it. The branch is a safe workspace separate from `main` |
| `git status` | Shows which files changed, which are staged, and which branch you are on |
| `git add <file>` | Stages a file, meaning it will be included in the next commit |
| `git commit -m "message"` | Saves the staged changes as a snapshot in history with a short description |
| `git push -u origin <branch>` | Uploads the branch to GitHub for the first time |
| `git branch --show-current` | Prints the name of the branch you are on |
| `git branch -d <branch>` | Deletes a local branch that has already been merged (Git refuses if it is not merged) |
| `git push origin --delete <branch>` | Deletes the branch on GitHub |
| `git log --oneline --graph` | Shows a compact history with branch and merge lines |

### Why a pull request instead of pushing to main

A pull request lets the CI pipeline check the change before it reaches `main`. It also leaves a reviewable record of what changed and why. Merging the PR is what updates `main` on GitHub, so nothing needs pushing afterwards, only a `git pull` locally.

### Commit message style

| Prefix | Meaning |
|---|---|
| `feat:` | A new feature or script |
| `fix:` | A bug fix |
| `docs:` | Documentation only |
| `chore:` | Maintenance such as setup or config |
| `ci:` | Changes to the pipeline |

## 4. Undoing mistakes

| Situation | Command | What it does |
|---|---|---|
| Discard edits to a file you have not committed | `git restore <file>` | Resets the file to the last commit. The changes are lost |
| Unstage a file but keep the edits | `git restore --staged <file>` | Reverses `git add` |
| Undo the last commit but keep the changes | `git reset --soft HEAD~1` | Moves the commit back to staged changes. Use only for commits not yet pushed |
| Undo a commit that is already pushed | `git revert <sha>` | Creates a new commit that cancels the old one. Safe for shared history |
| Park unfinished work temporarily | `git stash` | Saves your changes and cleans the working folder |
| Bring parked work back | `git stash pop` | Re-applies the stashed changes |
| Throw away all uncommitted changes | `git reset --hard` | Resets everything to the last commit. This is destructive, so use it deliberately |

## 5. Merge conflicts

A conflict happens when two branches change the same lines.

```bash
git switch -c branch-a
# edit line 1 of README.md, commit
git switch main
git switch -c branch-b
# edit line 1 differently, commit
git merge branch-a
```

Git stops and marks the file with `<<<<<<<`, `=======` and `>>>>>>>`. To resolve it:

1. Open the file and keep the text you want. Delete the marker lines.
2. `git add <file>` to mark it resolved.
3. `git commit` to finish the merge.

`git merge --abort` cancels the merge and returns to the state before it started.

## 6. Linux scripts in this repo

Run all scripts from the repo root.

| Script | Usage | What it does |
|---|---|---|
| `scripts/disk_check.sh` | `./scripts/disk_check.sh 80` | Warns if any filesystem is at or above 80% used. Exit code 1 if so |
| `scripts/memory_check.sh` | `./scripts/memory_check.sh 80` | Warns if memory use is at or above 80% |
| `scripts/service_check.sh` | `./scripts/service_check.sh sshd cron` | Checks that each systemd service is active |
| `scripts/system_info.sh` | `./scripts/system_info.sh` | Prints hostname, kernel, uptime and load average |

Commands used inside the scripts:

| Command or line | What it does |
|---|---|
| `#!/usr/bin/env bash` | Tells the system to run the file with bash |
| `set -euo pipefail` | Stops the script on errors (`-e`), on unset variables (`-u`), and on failures inside pipes (`pipefail`) |
| `df -P` | Lists filesystem usage in a stable, script-friendly format |
| `free -m` | Shows memory in megabytes |
| `awk '/^Mem:/ {print $2, $3}'` | Picks the total and used columns from the memory line |
| `systemctl is-active --quiet <svc>` | Succeeds if the service is running, prints nothing |
| `uptime -p` | Prints uptime in readable form |
| `chmod +x <file>` | Makes a file executable |

If `chmod` is not committed, Git may lose the executable bit. Check with `git ls-files --stage scripts/` (mode `100755` means executable).

## 7. Docker commands

```bash
docker build -t lab-app:test .
docker run --rm lab-app:test
```

| Command | What it does |
|---|---|
| `docker build -t lab-app:test .` | Builds an image from the `Dockerfile` in the current folder and names it `lab-app:test` |
| `docker run --rm lab-app:test` | Runs a container from the image and deletes the container when it exits |
| `docker images` | Lists images on your machine |

## 8. The CI pipeline (GitHub Actions)

The workflow lives in `.github/workflows/ci.yml` and runs on every push to `main` and on every pull request into `main`.

| Job | Steps | Purpose |
|---|---|---|
| `lint` | ShellCheck on `scripts/*.sh`, yamllint on all YAML | Catches script mistakes and YAML formatting errors |
| `docker-build` | Builds the image and runs it as a smoke test | Proves the image builds and starts |

`docker-build` has `needs: lint`, so it only runs if linting passes.

Run the same checks locally before pushing:

```bash
shellcheck scripts/*.sh
yamllint .
```

| Command | What it does |
|---|---|
| `shellcheck scripts/*.sh` | Static analysis for shell scripts: unquoted variables, bad syntax, risky patterns |
| `yamllint .` | Checks YAML files for syntax and style problems, using the rules in `.yamllint` |
| `pip install yamllint` | Installs yamllint (CI does this in every run) |

## 9. Working under WSL on a Windows drive

If the repo lives under `/mnt/c/...`, every file shows as `rwxrwxrwx` and Git may report permission changes that are not real. Fix it with:

```bash
git config core.fileMode false
```

For best speed, keep the repo inside the Linux home folder (for example `~/linux-devops-lab`).

## 10. Quick troubleshooting

| Problem | Likely cause and fix |
|---|---|
| A file seems to have disappeared after switching branches | It exists only on the other branch. Check `git branch` and switch back |
| `git push` says the repository moved | Username case or rename. Update with `git remote set-url origin <new-url>` |
| README change not visible on GitHub | The PR is not merged yet, or you are viewing a feature branch. Switch the branch dropdown to `main` |
| `chmod: cannot access 'scripts/x.sh'` | You are inside `scripts/` already, or the file does not exist yet. Check `pwd` and `ls` |
| CI fails on ShellCheck | Read the error line number, fix the script, push again. The PR re-runs automatically |
