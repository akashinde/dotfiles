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

Maintenance rule: after fixing any Hyprland/end_4 config, launcher, script, or
desktop integration issue, sync the relevant files into this repository, commit
on the `hyprland` branch, and push `origin hyprland` before considering the fix
done.

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

Fix log, 2026-08-12:

- Symptom: the Quickshell app launcher showed multiple Outlook results.
- Cause: old Outlook `.desktop` backup files were still under
  `~/.local/share/applications/backups`, and app launchers can scan that
  directory recursively. The setup also had a separate visible `outlook.desktop`
  file plus a local Snap override.
- Fix: move launcher backups outside the XDG applications path, remove the
  extra `outlook.desktop`, and make `outlook-ew_outlook-ew.desktop` the single
  visible local launcher that shadows the Snap desktop ID.

The tracked `outlook-ew_outlook-ew.desktop` file intentionally uses the same
desktop ID as the Snap entry, so it shadows the Snap launcher with the working
Hyprland command instead of creating a second Outlook result. It runs:

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

Do not keep launcher backups under `~/.local/share/applications`. Some app
launchers scan that directory recursively and will show old backup `.desktop`
files as duplicate apps. Use `~/.local/backups/application-launchers/` for those
backup files instead.
