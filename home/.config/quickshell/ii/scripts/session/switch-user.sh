#!/usr/bin/env bash
set -euo pipefail

if command -v gdbus >/dev/null 2>&1; then
  gdbus call \
    --system \
    --dest org.gnome.DisplayManager \
    --object-path /org/gnome/DisplayManager/LocalDisplayFactory \
    --method org.gnome.DisplayManager.LocalDisplayFactory.CreateTransientDisplay \
    >/dev/null 2>&1 && exit 0
fi

loginctl lock-session
