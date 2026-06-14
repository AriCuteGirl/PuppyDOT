#!/bin/sh

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

mkdir -p "$XDG_RUNTIME_DIR/quickshell"

if ! "$HOME/.config/hypr/hyprland/scripts/prepare-noctalia.sh"; then
  notify-send "PuppyDOT" "Could not prepare Noctalia. Check ~/.cache/noctalia-autostart.log" -u critical 2>/dev/null || true
  exit 1
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

log_file="$HOME/.cache/noctalia-autostart.log"
printf '\n[%s] starting Noctalia\n' "$(date '+%F %T')" >>"$log_file"
setsid -f /usr/bin/qs -c noctalia-shell >>"$log_file" 2>&1
