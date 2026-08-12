# Dotfiles

This repository uses branches for different desktop styles.

The `hyprland` branch contains the Hyprland/end_4 setup from this machine.

## Layout

Tracked config is stored in a `home/` mirror:

```text
home/.config/hypr
home/.config/quickshell
home/.config/kitty
home/.local/bin
home/.local/share/applications
packages/
```

The large timestamped backup archives are not tracked in git. They stay under:

```bash
~/.local/backups/hyprland
```

## Sync Current Machine Into Repo

From the Hyprland machine:

```bash
~/.local/bin/sync-hyprland-dotfiles
cd ~/Projects/dotfiles
git status
git diff --stat
git add .
git commit -m "Update Hyprland dotfiles"
git push -u origin hyprland
```

## Restore From Git On A Machine

Clone the branch:

```bash
git clone -b hyprland git@github.com:akashinde/dotfiles.git ~/Projects/dotfiles
```

Copy tracked files into the home directory:

```bash
rsync -a ~/Projects/dotfiles/home/ ~/
chmod +x ~/.local/bin/backup-hyprland-config ~/.local/bin/restore-hyprland-setup ~/.local/bin/sync-hyprland-dotfiles
systemctl --user daemon-reload
systemctl --user enable --now backup-hyprland-config.timer
```

This restores configuration only. Install Hyprland, Quickshell, Kitty, themes,
fonts, and desktop packages first, or use the package lists under `packages/` as
a guide.

## Full Archive Restore

For complete config restore, prefer the timestamped backup archives:

```bash
~/.local/bin/restore-hyprland-setup \
  --archive /path/to/hyprland-config-YYYYMMDD-HHMMSS.tar.zst \
  --install-packages
```

That path verifies checksums, creates a pre-restore backup, restores config, and
rewrites old home paths when moving to another username.

## Teams For Linux On Hyprland

The Snap package is intentionally bypassed in this setup. On this machine the
Snap wrapper hardcoded `--ozone-platform=x11`, but inside the Snap sandbox
`/tmp/.X11-unix` was unavailable, so Electron exited with:

```text
Missing X server or $DISPLAY
```

Forcing native Wayland got past that error but then hit the Snap/core22 Mesa
runtime crash path described by upstream for newer Ubuntu systems.

The tracked launcher therefore shadows the Snap desktop entry and runs:

```text
~/.local/bin/teams-for-linux -> teams-for-linux-portable
```

The portable binary itself is not committed to git. Install or refresh it with:

```bash
~/Projects/dotfiles/scripts/install-teams-for-linux-portable
```

Or restore dotfiles and install the portable Teams build in one step:

```bash
~/Projects/dotfiles/scripts/install-hyprland-dotfiles --yes --install-teams-portable
```

References:

- Teams for Linux troubleshooting: `https://ismaelmartinez.github.io/teams-for-linux/troubleshooting/`
- Snap core22/core24 tracking issue: `https://github.com/IsmaelMartinez/teams-for-linux/issues/2590`

## Outlook On Hyprland

The `outlook-ew` Snap desktop entry is hidden locally because it can leave a
stale Wayland-forced Snap process after resume, and it also appears as a second
Outlook result in the launcher. The visible `outlook.desktop` entry runs:

```text
~/.local/bin/outlook-ew
```

That wrapper calls the packaged Electron binary directly:

```text
/snap/outlook-ew/current/outlook-ew --ozone-platform=x11 --no-sandbox --disable-gpu --disable-gpu-compositing
```

The `outlook-ew` Snap still needs to be installed because this uses its packaged
binary. The wrapper exports Snap identity variables so the app does not enter
its non-Snap relaunch/update path, but it avoids the Snap launcher/runtime
wrapper and stores Outlook state under `~/.config/Microsoft Outlook` instead of
`~/snap/outlook-ew/...`. A one-time sign-in after switching launchers is
expected; after that, session state should persist in the normal config
directory.
