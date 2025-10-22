# Claude Code for OpenShift etcd

This directory contains Claude Code configurations for the OpenShift etcd fork.

## Available Slash Commands

### `/rebase-etcd` - Automated Patch Release Rebase

Automates rebasing upstream etcd patch releases into OpenShift's fork and creates a pull request.

**Quick Start:**
```bash
git checkout openshift-4.21
/rebase-etcd
# Provide: target version (e.g., v3.5.23), JIRA ID (e.g., 12345), OpenShift release (auto-detected)
```

**What it does:**
1. ✅ Validates environment (fork, tools, clean working directory)
2. ✅ Fetches upstream tags and determines current version
3. ✅ Executes `openshift-hack/rebase.sh` with your parameters
4. ✅ Handles merge conflicts (pauses for manual resolution)
5. ✅ Runs `go mod tidy` with OpenShift's Go toolchain
6. ✅ Pushes rebase branch and creates PR
7. ✅ Reports PR URL and next steps

**Prerequisites:**
- Personal fork of openshift/etcd (NOT the official repo)
- Tools: `git`, `jq`, `podman`, `bash`
- Optional: `gh` (GitHub CLI) for automatic PR creation
- Clean working directory

**Example workflow:**

```bash
# 1. Ensure you're on the right branch
git checkout openshift-4.21

# 2. Run the command
/rebase-etcd

# 3. When prompted, provide:
#    Target version: v3.5.23
#    JIRA ID: 12345
#    OpenShift release: (just press Enter to auto-detect)

# 4. If conflicts occur:
#    - Open another terminal
#    - Run: git status
#    - Edit conflicted files
#    - Run: git add <resolved-files>
#    - Return and press Enter to continue

# 5. Get PR URL and next steps
```

**After the PR is created:**
```bash
# Add these comments to the PR:
/payload 4.21 nightly informing
/payload 4.21 nightly blocking
```

## Files in This Directory

```
.claude/
├── commands/
│   └── rebase-etcd.md        # Slash command implementation
└── README.md                  # This file
```

## How the Slash Command Works

When you run `/rebase-etcd`, Claude Code will:

1. **Validate your environment:**
   ```bash
   # Check you're in a personal fork
   git remote get-url origin

   # Verify required tools exist
   command -v git jq podman bash

   # Ensure clean working directory
   git status
   ```

2. **Determine current version:**
   ```bash
   # Find the latest merged upstream tag
   git tag --merged | sort -V | tail -2 | head -1
   ```

3. **Ask for information:**
   - Target etcd version (e.g., v3.5.23)
   - JIRA ticket ID (optional, e.g., 12345)
   - OpenShift release (auto-detects from current branch if omitted)

4. **Execute the rebase:**
   ```bash
   openshift-hack/rebase.sh \
     --etcd-tag=v3.5.23 \
     --openshift-release=openshift-4.21 \
     --jira-id=12345
   ```

5. **Handle the rebase process:**
   - Fetches upstream tags
   - Rebases with `git rebase --rebase-merges --fork-point <old> <new>`
   - Merges with OpenShift release branch
   - Pauses if conflicts occur
   - Runs `go mod tidy` in OpenShift container
   - Pushes to your fork
   - Creates PR (via gh or browser)

6. **Report results:**
   - PR URL
   - Changelog link
   - Next steps for testing

## Common Scenarios

### Scenario 1: Clean rebase (no conflicts)

```bash
$ /rebase-etcd
Target version: v3.5.23
JIRA ID: 12345
OpenShift release: (blank - auto-detected as openshift-4.21)

# Wait 5-10 minutes...

✅ Rebase completed successfully!
PR: https://github.com/openshift/etcd/pull/XXX
Changelog: https://github.com/etcd-io/etcd/blob/master/CHANGELOG/CHANGELOG-3.5.md#v3523
```

### Scenario 2: Rebase with conflicts

```bash
$ /rebase-etcd
Target version: v3.5.24
JIRA ID: 12346
OpenShift release: (blank)

# Conflicts detected in: go.mod, go.sum
# Paused for manual resolution...

# In another terminal:
$ git status
$ vim go.mod go.sum
$ git add go.mod go.sum

# Back to slash command:
# Press Enter to continue

# Wait for completion...

✅ Rebase completed successfully!
PR: https://github.com/openshift/etcd/pull/XXX
```

## Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| "Not in etcd dir" | Wrong directory | `cd` to repository root |
| "cannot rebase against etcd-io/etcd or openshift/etcd" | Not in personal fork | Clone from your fork: `git clone git@github.com:yourname/etcd` |
| "Required tool 'jq' not installed" | Missing jq | Install: `brew install jq` or `dnf install jq` |
| "Required tool 'podman' not installed" | Missing podman | Install: `brew install podman` or `dnf install podman` |
| "forkpoint matches given etcd tag" | Already at that version | Choose a newer target version |
| gh CLI not creating PR | gh not installed or not authenticated | Install gh and run `gh auth login`, or use browser |

## Manual Alternative

If you prefer to run the script manually without the slash command:

```bash
openshift-hack/rebase.sh \
  --etcd-tag=v3.5.23 \
  --openshift-release=openshift-4.21 \
  --jira-id=12345
```

## Documentation

- **Repository guidance:** `CLAUDE.md` (in repository root)
- **Full rebase process:** `REBASE.openshift.md` (in repository root)
- **Rebase script:** `openshift-hack/rebase.sh`
- **Slash command:** `.claude/commands/rebase-etcd.md`

## Support

For help:
- Check `REBASE.openshift.md` for detailed manual process
- Review `CLAUDE.md` for repository-specific guidance
- See script usage: `openshift-hack/rebase.sh --help`
