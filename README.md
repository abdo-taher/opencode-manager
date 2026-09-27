# OpenCode Manager v1.2.1

Production bundle for running OpenCode through disposable Linux worker accounts while preserving OpenCode sessions/history across worker rotation.

## Proven behavior

- The permanent owner account (default: `abdotaher`) is never deleted.
- Disposable Linux workers are named `opencode-001`, `opencode-002`, etc.
- Current working directory is treated as the project.
- Git repositories owned by the permanent user are registered as `safe.directory` for the worker before OpenCode session discovery.
- The newest OpenCode session whose stored `directory` matches the current project is resumed automatically.
- If no project session exists, OpenCode starts a new session.
- OpenCode database/project/storage are shared; auth/config/cache/state remain isolated per worker.
- Manual or automatic worker rotation preserves OpenCode sessions.
- Temporary rate limits/network failures retry without immediate worker deletion.

## Supported OS

Ubuntu/Debian-style Linux with systemd not required. The provided dependency installer uses `apt-get`.

## Dependencies

Required commands/packages include:

- bash
- coreutils (`realpath`, `install`, `tee`)
- util-linux (`runuser`, `flock`, `script`)
- passwd/shadow utilities (`useradd`, `usermod`, `userdel`)
- procps (`pgrep`, `pkill`)
- git
- python3
- libc/getent
- findutils, grep

Recommended/optional:

- acl (`setfacl`) — preferred project permission handling; manager has a group-permission fallback
- cron (`crontab`) — used only to clean a disposable worker's cron entries if present

OpenCode itself must already exist for `SOURCE_USER`, by default at:

`/home/abdotaher/.opencode/bin/opencode`

## Fresh installation

```bash
unzip opencode-manager-package-v1.2.1.zip
cd opencode-manager-package-v1.2.1
sudo ./scripts/install-dependencies-ubuntu.sh
./scripts/check-dependencies.sh
sudo ./install.sh
```

Then:

```bash
cd /home/abdotaher/fooderp
sudo opencode-manager doctor
sudo opencode-manager run
```

## Update an existing installation

```bash
cd opencode-manager-package-v1.2.1
sudo ./update.sh
opencode-manager version
```

The update keeps shared sessions, state, history, and logs.

## Daily use

```bash
cd /path/to/project
sudo opencode-manager run
```

Other commands:

```bash
sudo opencode-manager status
sudo opencode-manager doctor
sudo opencode-manager rotate
sudo opencode-manager stop
sudo opencode-manager logs
opencode-manager version
```

## New project

No manager configuration change is needed:

```bash
cd /home/abdotaher/another-project
sudo opencode-manager run
```

The manager registers that Git repository as safe for the active worker, discovers sessions for that exact directory, and resumes the newest matching session if one exists.

## Rotation test

```bash
cd /home/abdotaher/fooderp
sudo opencode-manager run
sudo opencode-manager rotate
sudo opencode-manager run
```

The second run should log a `Registered Git safe.directory ...` line for the new worker and then resume the same project session.

## Configuration

Optional config file:

`/etc/opencode-manager/config.env`

A complete example is included at `config/config.env.example`.

## Uninstall

Preserve state/config:

```bash
sudo ./uninstall.sh
```

Remove manager state/config too:

```bash
sudo ./uninstall.sh --purge
```

Even purge intentionally does not delete `/opt/opencode-shared`; shared OpenCode data should only be removed manually after a verified backup.

## Security / safety

- `SOURCE_USER` is protected and is never treated as a disposable worker.
- Worker deletion is restricted to usernames matching the configured managed prefix and numeric suffix.
- A lock prevents concurrent manager lifecycle operations.
- Worker rotation does not create or bypass provider credentials. Use only accounts/credentials you are authorized to use.
