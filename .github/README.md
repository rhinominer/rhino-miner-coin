# GitHub Actions - Automated Builds

This directory contains GitHub Actions workflows and build scripts for automatically building Rhino Miner Coin releases.

## Workflow Overview

### `build-release.yml`

Automatically builds Rhino Miner Coin binaries for multiple platforms:

- **Windows** (x86_64) - GUI wallet + CLI tools
- **Linux GUI** (x86_64) - GUI wallet + CLI tools  
- **Linux CLI** (x86_64) - CLI/daemon only (no GUI)

## Triggering Builds

### Manual Trigger

1. Go to **Actions** tab in GitHub
2. Select **"Build Rhino Miner Coin Release"** workflow
3. Click **"Run workflow"**
4. Enter version (e.g., `v1.0.0`)
5. Click **"Run workflow"**

### Automatic Trigger (Git Tags)

Push a version tag to automatically build and create a GitHub release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This will:
1. Build all platforms
2. Create a GitHub release
3. Upload all binaries as release assets

## Build Scripts

Located in `.github/scripts/`:

| Script | Purpose |
|--------|---------|
| `00-install-deps.sh` | Install build dependencies for each platform |
| `01-build-depends.sh` | Build dependencies using the `depends/` system |
| `02-configure.sh` | Run autogen and configure with platform-specific flags |
| `03-build.sh` | Compile the binaries |
| `04-package.sh` | Package binaries into distributable archives |

## Build Artifacts

Each successful build produces:

### Windows
- `rhino-miner-coin-{version}-windows.zip`
  - `rhino-qt.exe` (GUI wallet)
  - `rhinod.exe` (daemon)
  - `rhino-cli.exe` (CLI tool)
  - `rhino-tx.exe` (transaction tool)
  - `rhino-wallet.exe` (wallet tool)

### Linux GUI
- `rhino-miner-coin-{version}-linux-gui.tar.gz`
  - `rhino-qt` (GUI wallet)
  - `rhinod` (daemon)
  - `rhino-cli` (CLI tool)
  - `rhino-tx` (transaction tool)
  - `rhino-wallet` (wallet tool)

### Linux CLI
- `rhino-miner-coin-{version}-linux.tar.gz`
  - `rhinod` (daemon)
  - `rhino-cli` (CLI tool)
  - `rhino-tx` (transaction tool)
  - `rhino-wallet` (wallet tool)

## Dependency Caching

Builds use GitHub Actions cache to speed up subsequent builds:
- Cached: `depends/built`, `depends/sources`, `depends/work`
- Cache key includes platform and depends file hashes
- First build: ~20-30 minutes
- Cached builds: ~5-10 minutes

## Adding New Platforms

To add a new platform (e.g., ARM, macOS):

1. Add platform to `strategy.matrix.platform` in `build-release.yml`
2. Update `00-install-deps.sh` with platform dependencies
3. Update `01-build-depends.sh` with platform host triplet
4. Update `02-configure.sh` with platform configure flags
5. Update `04-package.sh` with platform packaging logic

## Local Testing

Test build scripts locally before pushing:

```bash
# Install dependencies
bash .github/scripts/00-install-deps.sh linux

# Build dependencies
bash .github/scripts/01-build-depends.sh linux x86_64

# Configure
bash .github/scripts/02-configure.sh linux

# Build
bash .github/scripts/03-build.sh

# Package
bash .github/scripts/04-package.sh linux v1.0.0-test
```

## Troubleshooting

### Build fails on dependencies
- Check `.github/scripts/00-install-deps.sh` for missing packages
- Verify `depends/` submodules are properly initialized

### Configuration fails
- Ensure line endings are LF, not CRLF (scripts fix this automatically)
- Check `depends/` was built successfully

### Packaging fails
- Verify binaries were created in `src/` directory
- Check binary names match platform expectations

## Credits

Inspired by [CMUSICAI/Cmusic](https://github.com/CMUSICAI/Cmusic) build system.
