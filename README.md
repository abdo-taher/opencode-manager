# OpenCode Manager

OpenCode Manager is a Linux/Ubuntu wrapper around OpenCode that runs OpenCode through disposable Linux worker users while preserving project sessions across worker rotation.

The permanent project owner stays untouched. OpenCode workers can be replaced, while the project directory and OpenCode session history remain available through shared OpenCode storage.

Current package version: **v1.2.3**.

Repository: `https://github.com/abdo-taher/opencode-manager`

## What it solves

A normal OpenCode installation stores project/session state under the Linux user's home directory. That becomes inconvenient when OpenCode is intentionally run through temporary Linux users.

OpenCode Manager provides one consistent lifecycle:

```text
permanent owner: abdotaher
        |
        +-- /home/abdotaher/project-a
        +-- /home/abdotaher/project-b
        |
        +-- shared OpenCode session database
                    |
                    +-- opencode-001
                    +-- opencode-002
                    +-- opencode-003
```

The permanent owner is never rotated. Only managed `opencode-NNN` workers are disposable.

## Proven behavior

- Permanent source/owner account is never deleted.
- Disposable Linux workers are named `opencode-001`, `opencode-002`, etc.
- The shell's current working directory is treated as the active project.
- Git repositories owned by the permanent account are automatically registered as `safe.directory` for the active worker.
- The newest OpenCode session whose stored `directory` matches the current project is resumed automatically.
- If no matching session exists, a new OpenCode session is started.
- OpenCode database/project/storage are shared.
- Worker auth/config/cache/state remain isolated.
- Manual worker rotation preserves project sessions.
- Temporary rate-limit/network failures retry without immediately deleting the worker.
- Installation and update preserve shared session data.

## Requirements

Supported target: Ubuntu/Debian-style Linux.

Required commands/packages include:

- Bash
- coreutils (`realpath`, `install`, `tee`)
- util-linux (`runuser`, `flock`, `script`)
- passwd/shadow utilities (`useradd`, `usermod`, `userdel`)
- procps (`pgrep`, `pkill`)
- Git
- Python 3
- `getent`
- findutils
- grep/sed/awk

Recommended:

- `acl` / `setfacl` for project permissions
- `cron` for cleanup of worker cron entries when present

OpenCode must already be installed for the permanent source user. The default expected binary is:

```text
/home/abdotaher/.opencode/bin/opencode
```

Verify it before installation:

```bash
/home/abdotaher/.opencode/bin/opencode --version
```

## Quick install from a GitHub release

Download both package artifacts from the GitHub Releases page, or use `gh`:

```bash
gh release download v1.2.3 \
  --repo abdo-taher/opencode-manager \
  --pattern 'opencode-manager-package-v1.2.3.zip'
```

Extract and install:

```bash
unzip opencode-manager-package-v1.2.3.zip
cd opencode-manager-package-v1.2.3
sudo ./scripts/install-dependencies-ubuntu.sh
./scripts/check-dependencies.sh
sudo ./install.sh
```

Verify:

```bash
opencode-manager version
```

Expected:

```text
1.2.3
```

## Install from source

Clone the repository:

```bash
git clone https://github.com/abdo-taher/opencode-manager.git
cd opencode-manager
```

Install dependencies and manager:

```bash
sudo ./scripts/install-dependencies-ubuntu.sh
./scripts/check-dependencies.sh
sudo ./install.sh
```

## Daily usage

Move into any project and run one command:

```bash
cd /home/abdotaher/fooderp
sudo opencode-manager run
```

For another project:

```bash
cd /home/abdotaher/another-project
sudo opencode-manager run
```

No project-specific manager configuration is required.

The lifecycle is:

```text
current directory
      |
      v
validate worker access
      |
      v
register Git safe.directory
      |
      v
OpenCode session list
      |
      +-- matching project session -> resume newest session
      |
      +-- no matching session ------> create new session
```

## Why `safe.directory` is automatic

The projects are normally owned by the permanent user (`abdotaher`) while OpenCode runs as a different disposable Linux user.

Without Git configuration, Git rejects the repository with:

```text
fatal: detected dubious ownership in repository
```

The manager automatically registers the current project for the active worker before OpenCode performs session discovery. This is required so OpenCode calculates the same project identity and sees the same project sessions after worker rotation.

## Session persistence

OpenCode sessions are discovered using OpenCode's own session metadata.

A session contains a directory such as:

```json
{
  "id": "ses_xxxxx",
  "directory": "/home/abdotaher/fooderp"
}
```

The manager searches for the newest session matching the current project directory and resumes it with OpenCode's session option.

That means:

```text
opencode-003 -> removed
opencode-004 -> created
project      -> unchanged
session      -> unchanged
```

## Commands

### Run

```bash
sudo opencode-manager run
```

### Status

```bash
sudo opencode-manager status
```

### Health check

```bash
sudo opencode-manager doctor
```

A healthy Git project should include checks similar to:

```text
[PASS] managed worker exists
[PASS] worker DB is shared
[PASS] worker can read project
[PASS] worker recognizes Git project (safe.directory)
[PASS] worker can execute OpenCode
Result: HEALTHY
```

### Rotate worker manually

```bash
sudo opencode-manager rotate
```

Then simply run again:

```bash
sudo opencode-manager run
```

The new worker gets the project's Git `safe.directory` entry automatically and resumes the existing project session.

### Stop

```bash
sudo opencode-manager stop
```

### Logs

```bash
sudo opencode-manager logs
```

### Version

```bash
opencode-manager version
```

## Update an installed manager

When installing a newer release package:

```bash
unzip opencode-manager-package-v1.2.3.zip
cd opencode-manager-package-v1.2.3
sudo ./update.sh
```

Then verify:

```bash
opencode-manager version
sudo opencode-manager doctor
```

The update process preserves shared sessions/state/history/logs.

Do not delete `/opt/opencode-manager` or `/opt/opencode-shared` as part of a normal upgrade.

## Configuration

Default configuration is stored at:

```text
/etc/opencode-manager/config.env
```

The package contains a complete example:

```text
config/config.env.example
```

The permanent account should remain the real project owner. Disposable workers should not become owners of your source repositories.

## Important directories

Manager files:

```text
/usr/local/bin/opencode-manager
/etc/opencode-manager/
/opt/opencode-manager/
```

Shared OpenCode state:

```text
/opt/opencode-shared/
```

Typical shared data includes:

```text
opencode.db
opencode.db-wal
opencode.db-shm
project/
storage/
```

Do not manually remove these while OpenCode sessions are needed.

## Uninstall

Remove the manager but preserve state/config:

```bash
sudo ./uninstall.sh
```

Remove manager state/config as well:

```bash
sudo ./uninstall.sh --purge
```

Even purge intentionally does not automatically delete `/opt/opencode-shared`.

Back up and remove shared OpenCode data manually only when you are certain it is no longer needed.

## Dependency verification

Check dependencies:

```bash
./scripts/check-dependencies.sh
```

Install Ubuntu dependencies:

```bash
sudo ./scripts/install-dependencies-ubuntu.sh
```

## Building release packages

From the repository root:

```bash
./scripts/build-release.sh
```

Artifacts are created under:

```text
dist/
```

For v1.2.3:

```text
dist/opencode-manager-package-v1.2.3.zip
dist/opencode-manager-package-v1.2.3.tar.gz
```

The build script also refreshes `SHA256SUMS` before packaging.

## Publishing a GitHub release with `gh`

Prerequisites:

```bash
gh auth status
```

Your working tree must contain the actual release changes before tagging.

Recommended release flow:

```bash
cd ~/Downloads/opencode-manager

./scripts/build-release.sh

git add .
git commit -m "Release v1.2.3"

git tag -a v1.2.3 -m "OpenCode Manager v1.2.3"

git push origin main
git push origin v1.2.3

./scripts/publish-github-release.sh
```

The publisher checks that the release artifacts exist before calling `gh release create`.

### If a tag was accidentally created before the release commit

Do not leave a release tag pointing at the wrong commit.

For example, if `v1.2.3` was accidentally created on the previous release:

```bash
git tag -d v1.2.3
git push origin :refs/tags/v1.2.3
```

Make the real release commit, then recreate and push the tag:

```bash
git tag -a v1.2.3 -m "OpenCode Manager v1.2.3"
git push origin v1.2.3
```

## Verifying a GitHub release

```bash
gh release view v1.2.3 --repo abdo-taher/opencode-manager
```

List releases:

```bash
gh release list --repo abdo-taher/opencode-manager
```

Download and verify later:

```bash
gh release download v1.2.3 \
  --repo abdo-taher/opencode-manager \
  --pattern 'opencode-manager-package-v1.2.3.zip'

sha256sum opencode-manager-package-v1.2.3.zip
```

## Security and safety

- The permanent `SOURCE_USER` is protected and is never treated as disposable.
- Worker deletion is restricted to the configured managed worker naming convention.
- Manager lifecycle operations use locking to prevent concurrent destructive operations.
- Session storage and Linux worker identity are separate concerns.
- Worker rotation does not manufacture, bypass, or extend provider credentials/quotas.
- Only use provider accounts and credentials you are authorized to use.

## Package layout

```text
opencode-manager/
├── bin/
│   └── opencode-manager
├── config/
│   └── config.env.example
├── scripts/
│   ├── build-release.sh
│   ├── check-dependencies.sh
│   ├── install-dependencies-ubuntu.sh
│   └── publish-github-release.sh
├── install.sh
├── update.sh
├── uninstall.sh
├── README.md
├── SHA256SUMS
└── VERSION
```

## License

No license file is included yet. Add a `LICENSE` file before describing this project as open-source under a specific license.
