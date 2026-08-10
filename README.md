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

