# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is **OpenShift's fork** of etcd (github.com/openshift/etcd), not the upstream etcd-io/etcd repository. The fork incorporates upstream etcd releases while maintaining OpenShift-specific customizations and patches.

### Key Differences from Upstream

- **OpenShift-specific directories:**
  - `openshift-hack/` - OpenShift automation scripts (rebasing, tooling)
  - `openshift-tools/` - OpenShift-specific utilities (e.g., discover-etcd-initial-cluster)
  - Multiple OpenShift-specific Dockerfiles (Dockerfile.art, Dockerfile.rhel, etc.)

- **UPSTREAM commit prefix convention:** OpenShift uses specific commit message prefixes to track changes:
  - `UPSTREAM: <carry>:` - Long-term patches carried on top of upstream (e.g., configuration changes, OpenShift integrations)
  - `UPSTREAM: <drop>:` - Temporary commits during rebase process (conflicts, go mod tidy)
  - Regular commits follow upstream etcd style: `<package>: <what changed>`

- **Rebase process:** See `REBASE.openshift.md` for the complete manual rebase process. The automated workflow is in `openshift-hack/rebase.sh`.

## Claude Code Slash Commands

### /rebase-etcd - Automated Patch Release Rebase

**Purpose:** Automates rebasing upstream etcd patch releases (e.g., v3.5.21 → v3.5.23) into OpenShift's fork and creates a pull request.

**Usage:**
```bash
/rebase-etcd
```

**Interactive Prompts:**
The command will ask you for:
1. **Target etcd version** (required) - e.g., `v3.5.23`
2. **JIRA ticket ID** (optional but recommended) - e.g., `12345` (creates OCPBUGS-12345 in PR title)
3. **OpenShift release** (optional) - e.g., `openshift-4.21` (auto-detects from current branch if omitted)

**What it automates:**
1. ✅ Validates environment (fork check, required tools, clean working directory)
2. ✅ Fetches upstream tags from etcd-io/etcd
3. ✅ Determines current etcd version from git tags
4. ✅ Executes `openshift-hack/rebase.sh` with your parameters
5. ✅ Handles merge conflicts (pauses for manual resolution when needed)
6. ✅ Runs `go mod tidy` using OpenShift's Go toolchain in podman
7. ✅ Pushes rebase branch to your personal fork
8. ✅ Creates pull request to openshift/etcd (via gh CLI or browser)
9. ✅ Reports PR URL and next steps

**Prerequisites:**
- Must be in a personal fork of openshift/etcd (NOT the official openshift/etcd or etcd-io/etcd)
- Required tools: `git`, `jq`, `podman`, `bash`
- Optional: `gh` (GitHub CLI) - for automatic PR creation
- Clean working directory (no uncommitted changes)
- Checkout the appropriate OpenShift release branch (e.g., `openshift-4.21`)

**Example workflow:**
```bash
# 1. Checkout the OpenShift release branch
git checkout openshift-4.21

# 2. Run the slash command
/rebase-etcd

# 3. When prompted, provide:
#    Target version: v3.5.23
#    JIRA ID: 12345
#    OpenShift release: (press Enter to auto-detect from current branch)

# 4. If conflicts occur:
#    - Open another terminal
#    - Run: git status
#    - Edit conflicted files (usually go.mod, go.sum)
#    - Run: git add <resolved-files>
#    - Return to the slash command and press Enter to continue

# 5. Get the PR URL and next steps
```

**After the PR is created:**
1. Add payload tests in PR comments:
   ```
   /payload 4.21 nightly informing
   /payload 4.21 nightly blocking
   ```
2. Request reviews from the etcd team
3. Monitor CI results

**Common scenarios:**

| Scenario | Expected Time |
|----------|--------------|
| Clean rebase (no conflicts) | 5-10 minutes |
| Rebase with go.mod/go.sum conflicts | 15-20 minutes |
| Rebase with code conflicts | 20-30 minutes |

**Troubleshooting:**
- **"Not in etcd dir"** - Navigate to repository root
- **"cannot rebase against etcd-io/etcd or openshift/etcd"** - Clone from your personal fork
- **"Required tool 'X' not installed"** - Install missing tool (jq, podman, etc.)
- **"forkpoint matches given etcd tag"** - Already at that version, choose a newer tag

## Build Commands

### Basic build
```bash
# Build etcd, etcdctl, and etcdutl binaries
make build

# Or use build script directly
./build.sh

# Build with specific flags
GO_BUILD_FLAGS="-v" ./build.sh
```

Binaries are output to `./bin/`:
- `bin/etcd` - Main etcd server
- `bin/etcdctl` - Command-line client
- `bin/etcdutl` - Utility tool

### Docker builds
```bash
# Build test container (uses version from .go-version)
make build-docker-test

# Build release container for specific architecture
ARCH=amd64 make build-docker-release-main
```

## Test Commands

### Test execution via test.sh

The `./test.sh` script is the main test runner. Control test passes via the `PASSES` environment variable:

```bash
# Run default tests (fmt, bom, dep, build, unit)
./test.sh

# Run specific test passes
PASSES="unit" ./test.sh
PASSES="integration" ./test.sh
PASSES="build unit integration" ./test.sh
PASSES="build e2e" ./test.sh
```

### Test targets via Makefile

```bash
# Run unit tests only
make test-unit

# Run integration tests
make test-integration

# Run e2e tests
make test-e2e

# Run smoke tests (fmt, bom, dep, build, unit)
make test-smoke

# Run all tests
make test-full
```

### Running tests for specific packages

```bash
# Test single package with custom timeout
PASSES=unit PKG=./wal TIMEOUT=1m ./test.sh

# Test specific test case
PASSES=unit PKG=./wal TESTCASE=TestNew TIMEOUT=1m ./test.sh

# Test exact test name (with word boundaries)
PASSES=unit PKG=./wal TESTCASE="\bTestNew\b" TIMEOUT=1m ./test.sh
```

### Docker-based testing

```bash
# Run tests in container (good for CI or clean environment)
TEST_OPTS="PASSES='unit'" make docker-test
TEST_OPTS="PASSES='build unit integration'" make docker-test

# With verbose output
TEST_OPTS="VERBOSE=2 PASSES='unit'" make docker-test
```

### Coverage

```bash
# Generate coverage (COVERDIR must be absolute or relative to etcd root)
COVERDIR=coverage PASSES="build build_cov cov" ./test.sh

# View coverage report
go tool cover -html ./coverage/cover.out
```

## Code Architecture

### Module structure

This is a Go v3 module (`go.etcd.io/etcd/v3`). The codebase uses multiple nested modules:
- Root: `go.etcd.io/etcd/v3`
- API: `go.etcd.io/etcd/api/v3`
- Client: `go.etcd.io/etcd/client/v3`
- Server: `go.etcd.io/etcd/server/v3`
- Raft: `go.etcd.io/etcd/raft/v3`
- Package utilities: `go.etcd.io/etcd/pkg/v3`

**Important:** Scripts like `test_lib.sh` verify you're in the correct module directory (`go.etcd.io/etcd/v3`).

### Directory structure

**Core server components:**
- `server/` - Main etcd server code
  - `server/etcdserver/` - Core server logic, Raft integration
  - `server/etcdmain/` - Entry point and configuration
  - `server/embed/` - Embedded etcd server
  - `server/storage/` - Storage backend interfaces
  - `server/mvcc/` - Multi-version concurrency control
  - `server/wal/` - Write-ahead log implementation
  - `server/auth/` - Authentication and authorization
  - `server/lease/` - Lease management
  - `server/proxy/` - gRPC proxy

**Client and API:**
- `client/` - Client libraries (v2 and v3)
  - `client/v3/` - v3 client implementation
  - `client/pkg/` - Shared client utilities
- `api/` - gRPC API definitions and generated code
- `etcdctl/` - Command-line client tool
- `etcdutl/` - Utility tool for etcd operations

**Consensus and replication:**
- `raft/` - Raft consensus algorithm implementation (used by etcd and other projects)

**Supporting infrastructure:**
- `pkg/` - Shared packages (types, utilities, etc.)
- `tests/` - Integration and E2E tests
- `scripts/` - Build and test automation scripts
- `tools/` - Development tools

**OpenShift-specific:**
- `openshift-hack/` - OpenShift automation (rebase.sh, etc.)
- `openshift-tools/` - OpenShift utilities

### Key architectural concepts

1. **Raft consensus:** etcd uses the Raft algorithm (`raft/`) for distributed consensus. The etcd server (`server/etcdserver/`) integrates with Raft to replicate operations across cluster members.

2. **MVCC (Multi-Version Concurrency Control):** The `server/mvcc/` package implements versioned key-value storage, enabling features like watch, transactions, and time-travel queries.

3. **WAL (Write-Ahead Log):** The `server/wal/` package provides durable logging of all changes before they're applied to the state machine.

4. **gRPC API:** The v3 API (`api/`) is defined using Protocol Buffers and served over gRPC. The v2 API is HTTP/JSON-based (legacy).

5. **Embedded mode:** The `server/embed/` package allows etcd to be embedded into other Go applications (used by Kubernetes, etc.).

## OpenShift-Specific Development

### Rebasing upstream releases

**Automated rebase with slash command (recommended):**
```bash
/rebase-etcd
```

**Automated rebase with script:**
```bash
# Must be in a personal fork (not openshift/etcd or etcd-io/etcd)
openshift-hack/rebase.sh \
  --etcd-tag=v3.5.23 \
  --openshift-release=openshift-4.21 \
  --jira-id=12345
```

The script will:
1. Fetch upstream tags
2. Determine the current etcd version (fork point)
3. Rebase OpenShift commits onto the new upstream tag
4. Handle conflicts (pauses for manual resolution)
5. Run `go mod tidy` with OpenShift's Go toolchain
6. Push rebase branch and create PR

**Manual rebase:** See `REBASE.openshift.md` for detailed steps.

### Commit message conventions for OpenShift changes

When making OpenShift-specific changes:

```
UPSTREAM: <carry>: short description

Longer explanation of why this change is needed for OpenShift
and why it's being carried as a patch rather than upstreamed.
```

For rebase-related commits:
```
UPSTREAM: <drop>: go mod tidy
UPSTREAM: <drop>: manually resolve conflicts
```

For changes that span multiple packages in OpenShift context:
```
*: description of cross-cutting change
```

### Testing OpenShift builds

After making changes, test with OpenShift's container builds:

```bash
# Test with podman using OpenShift's build image
podman run -it --rm -v "$(pwd):/go/etcd:Z" \
  --workdir=/go/etcd \
  registry.ci.openshift.org/openshift/release:rhel-8-release-golang-1.22-openshift-4.21 \
  make build
```

## Common Development Patterns

### Running a local etcd cluster

```bash
# Install goreman
go install github.com/mattn/goreman@latest

# Start 3-member cluster using Procfile
goreman start

# Add a learner node
goreman -f ./Procfile.learner start
```

This creates:
- `infra1`, `infra2`, `infra3` - Three etcd members
- Optional `grpc-proxy` - gRPC proxy instance

### Running single etcd instance

```bash
# After building
./bin/etcd

# etcd listens on:
# - 2379 for client requests
# - 2380 for peer communication

# Use etcdctl to interact
./bin/etcdctl put mykey "myvalue"
./bin/etcdctl get mykey
```

### Working with test failures

Test logs are written to `test-<timestamp>.log`. The Makefile automatically checks for:
- Test failures (`--- FAIL:`)
- Data races (`DATA RACE`)
- Panics (`panic: test timed out`)
- Leaked goroutines (`appears to have leaked`)

To debug:
```bash
# Run with verbose output
VERBOSE=2 PASSES=unit PKG=./wal ./test.sh

# Run specific test with race detector
RACE=true PASSES=unit PKG=./wal TESTCASE=TestNew ./test.sh

# Increase timeout for slow tests
TIMEOUT=10m PASSES=integration PKG=./clientv3 ./test.sh
```

## Important Files

- `build.sh` - Main build script (builds etcd, etcdctl, etcdutl)
- `test.sh` - Main test runner (supports PASSES variable)
- `scripts/test_lib.sh` - Test utilities and helpers
- `Procfile` - goreman config for local multi-node cluster
- `REBASE.openshift.md` - Complete OpenShift rebase documentation
- `openshift-hack/rebase.sh` - Automated rebase script
- `.go-version` - Go version used for builds (important for OpenShift compatibility)
- `bill-of-materials.json` - Dependency tracking for OpenShift builds

## Key Constraints

1. **Go module readonly mode:** Tests run with `GOFLAGS=-mod=readonly` to catch missing dependency updates
2. **ETCD_VERIFY=all:** Verification checks are enforced during tests
3. **Race detection:** Enabled by default on amd64, configurable via RACE variable
4. **Branch structure:** Development on `main` (upstream) vs `openshift-X.Y` branches (OpenShift releases)
5. **Git remotes:** When working on OpenShift fork:
   - `upstream` - etcd-io/etcd (for rebasing)
   - `openshift` - openshift/etcd (official OpenShift fork)
   - `origin` - Your personal fork (for PRs)

## Environment Variables

Common variables for builds and tests:
- `PASSES` - Test passes to run (fmt, bom, dep, build, unit, integration, e2e, functional, grpcproxy)
- `PKG` - Specific package to test (e.g., `./wal`, `./clientv3`)
- `TESTCASE` - Specific test case to run (regex pattern)
- `TIMEOUT` - Test timeout (default varies by pass type)
- `RACE` - Enable/disable race detector (default: true on amd64)
- `CPU` - CPU count for tests
- `VERBOSE` - Verbosity level (1, 2)
- `GO_BUILD_FLAGS` - Flags passed to go build (e.g., `-v`)
- `GOARCH` - Target architecture
- `COVERDIR` - Coverage output directory
