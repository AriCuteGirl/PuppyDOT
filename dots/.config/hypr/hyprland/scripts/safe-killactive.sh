#!/bin/sh

active="$(hyprctl activewindow 2>/dev/null)"

if printf '%s\n' "$active" | grep -Eiq 'class:.*(minecraft|prismlauncher)|title:.*minecraft'; then
  notify-send "Minecraft protected" "Super+Q is disabled for Minecraft."
  exit 0
fi

hyprctl dispatch 'hl.dsp.window.close()'
