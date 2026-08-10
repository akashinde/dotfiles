# Hyprland Backup And Restore

This directory stores timestamped backups for the Hyprland/end_4 desktop setup.

The backup system has two scripts:

- `~/.local/bin/backup-hyprland-config`
- `~/.local/bin/restore-hyprland-setup`

The daily backup timer is:

- `~/.config/systemd/user/backup-hyprland-config.timer`
- `~/.config/systemd/user/backup-hyprland-config.service`

## What Is Backed Up

The backup archive includes Hyprland, Quickshell/end_4, Kitty, lock/idle config,
user systemd units, app launchers, GTK/Qt theme config, icons, themes, fonts,
local helper scripts, and package metadata.

Package metadata is saved for:

- APT manual packages
- Installed Debian package versions
- Flatpak apps
- Snap apps
- Hyprland and Quickshell version output when available
- Default browser/mime handler info

The archive restores configuration and metadata. It does not replace a full OS
image or guarantee GPU driver compatibility.

## Manual Backup

Run this any time before editing desktop config:

```bash
~/.local/bin/backup-hyprland-config
```

Backups are written to:

```bash
~/.local/backups/hyprland
```

The script keeps the newest 30 archives by default. Override that with:

```bash
HYPRLAND_BACKUP_KEEP=60 ~/.local/bin/backup-hyprland-config
```

## Check The Daily Timer

```bash
systemctl --user list-timers backup-hyprland-config.timer --no-pager
systemctl --user status backup-hyprland-config.timer --no-pager
```

Enable it again if needed:

```bash
systemctl --user daemon-reload
systemctl --user enable --now backup-hyprland-config.timer
```

## Restore On The Same Machine

Use the newest backup:

```bash
~/.local/bin/restore-hyprland-setup --latest --install-packages
```

Use a specific backup:

```bash
~/.local/bin/restore-hyprland-setup \
  --archive ~/.local/backups/hyprland/hyprland-config-YYYYMMDD-HHMMSS.tar.zst \
  --install-packages
```

The restore script verifies the checksum when a `.sha256` file exists, creates a
pre-restore backup, extracts the config, reloads user systemd, re-enables the
backup timer, and tries `hyprctl reload` when Hyprland is available.

## Restore After Reinstall

After reinstalling Ubuntu, copy a backup archive and its `.sha256` file onto the
machine. If the restore script is not available yet, extract it from the archive:

```bash
mkdir -p ~/.local/bin
tar --zstd -xpf /path/to/hyprland-config-YYYYMMDD-HHMMSS.tar.zst \
  -C ~ \
  .local/bin/backup-hyprland-config \
  .local/bin/restore-hyprland-setup
chmod +x ~/.local/bin/backup-hyprland-config ~/.local/bin/restore-hyprland-setup
```

Then restore:

```bash
~/.local/bin/restore-hyprland-setup \
  --archive /path/to/hyprland-config-YYYYMMDD-HHMMSS.tar.zst \
  --install-packages
```

Snap restore is opt-in:

```bash
~/.local/bin/restore-hyprland-setup \
  --archive /path/to/hyprland-config-YYYYMMDD-HHMMSS.tar.zst \
  --install-packages \
  --install-snaps
```

## Use On Another Machine

This can be used on another Ubuntu machine, but expect a few checks afterward:

- Monitor names and resolution can differ.
- GPU/NVIDIA settings can differ.
- Some app launchers only work if the same apps are installed.
- Some hardware-specific settings may need adjustment.
- The restore script rewrites old absolute home paths, such as `/home/akash`, to
  the current `$HOME` by default.

Recommended cross-machine dry run:

```bash
~/.local/bin/restore-hyprland-setup \
  --archive /path/to/hyprland-config-YYYYMMDD-HHMMSS.tar.zst \
  --install-packages \
  --dry-run
```

Actual cross-machine restore:

```bash
~/.local/bin/restore-hyprland-setup \
  --archive /path/to/hyprland-config-YYYYMMDD-HHMMSS.tar.zst \
  --install-packages
```

If you do not want home-path rewriting:

```bash
~/.local/bin/restore-hyprland-setup \
  --archive /path/to/hyprland-config-YYYYMMDD-HHMMSS.tar.zst \
  --install-packages \
  --no-rewrite-home
```

## Useful Modes

Show help:

```bash
~/.local/bin/restore-hyprland-setup --help
```

Check what would happen without changing files:

```bash
~/.local/bin/restore-hyprland-setup --latest --dry-run
```

Install packages only, without restoring config:

```bash
~/.local/bin/restore-hyprland-setup --latest --packages-only
```

Restore config without package installation:

```bash
~/.local/bin/restore-hyprland-setup --latest
```

## Safety Notes

- The restore script does not delete the archive.
- The restore script creates a pre-restore backup before extracting config.
- The restore script does not install Snap apps unless `--install-snaps` is used.
- The restore script validates archive paths before extraction.
- The restore script checks SHA-256 when the matching `.sha256` file is present.
- This is config restore, not a full disk image.
- This setup does not intentionally update NVIDIA drivers.

