---
description: Rebase upstream etcd patch release and create pull request
---

I'll help you rebase an upstream etcd patch release into this OpenShift fork and create a pull request.

Let me start by gathering the necessary information and validating the environment.

## Step 1: Environment Validation

First, I'll check:
- That we're in a personal fork (not openshift/etcd or etcd-io/etcd)
- Required tools are installed (git, jq, podman, bash)
- The working directory is clean
- Current etcd version from git tags
- Available upstream versions

## Step 2: Get Rebase Information

I need the following information from you:

**Required:**
- **Target etcd version** (e.g., v3.5.23) - The upstream version to rebase to

**Optional:**
- **JIRA ticket ID** (e.g., 12345 for OCPBUGS-12345) - Recommended for tracking
- **OpenShift release** (e.g., openshift-4.21) - I'll auto-detect from current branch if not provided

## Step 3: Execute Rebase

Once I have the information, I'll:

1. Validate the target version exists in upstream
2. Determine the current version (fork point)
3. Execute `openshift-hack/rebase.sh` with the parameters:
   ```bash
   openshift-hack/rebase.sh \
     --etcd-tag=<target-version> \
     --openshift-release=<openshift-release> \
     --jira-id=<jira-id>
   ```

4. Monitor the rebase process and handle:
   - Automatic merge if no conflicts
   - Pause for manual conflict resolution if needed
   - Continue after conflicts are resolved

5. The script will:
   - Run `go mod tidy` with OpenShift's Go toolchain
   - Push the rebase branch to your fork
   - Create a pull request (via gh CLI or browser)

6. Report the PR URL and next steps

## Expected Behavior

**If no conflicts (typical time: 5-10 minutes):**
- Rebase executes cleanly
- `go mod tidy` completes
- Branch pushed to your fork
- PR created automatically
- You get the PR URL

**If conflicts occur (typical time: 15-30 minutes):**
- Script pauses and shows conflicted files
- You resolve conflicts in another terminal
- Script continues after you press Enter
- Commits resolution with `UPSTREAM: <drop>: manually resolve conflicts`
- Continues with `go mod tidy` and PR creation

## Next Steps After PR Creation

1. Add payload tests (in PR comments):
   ```
   /payload 4.21 nightly informing
   /payload 4.21 nightly blocking
   ```

2. Request reviews from etcd team

3. Monitor CI results

Let me start by checking the environment...
