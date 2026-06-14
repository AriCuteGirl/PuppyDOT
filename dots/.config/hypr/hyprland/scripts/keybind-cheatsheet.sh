#!/usr/bin/env bash

set -uo pipefail

fail() {
  notify-send "Keybind cheatsheet failed" "$1" -a Hyprland
  exit 1
}

cheatsheet=$(mktemp --tmpdir hyprland-keybinds.XXXXXX)
trap 'rm -f "$cheatsheet"' EXIT

cat >"$cheatsheet" <<'EOF'
HYPRLAND KEYBIND CHEATSHEET

Super means the Windows/Command key. Press Ctrl+F to search this list.
The most useful starter shortcuts are Super+Enter for a terminal,
Super+Period for apps, Super+Q to close a window, and Super+/ for this help.

CATEGORY         SHORTCUT                         ACTION
────────────────────────────────────────────────────────────────────────────────
EOF

binds_json=$(hyprctl binds -j 2>&1) || fail "$binds_json"

printf '%s\n' "$binds_json" | jq -r '
  def hasbit($value; $bit): ((($value / $bit) | floor) % 2) == 1;
  def modifiers:
    .modmask as $m
    | [
        if hasbit($m; 64) then "Super" else empty end,
        if hasbit($m; 4) then "Ctrl" else empty end,
        if hasbit($m; 8) then "Alt" else empty end,
        if hasbit($m; 1) then "Shift" else empty end
      ];
  def bindkey:
    if (.key // "") != "" then
      (.key | if ascii_downcase == "slash" then "/"
              elif ascii_downcase == "period" then "."
              elif ascii_downcase == "return" then "Enter"
              elif ascii_downcase == "escape" then "Esc"
              else . end)
    elif (.keycode // 0) != 0 then "code:" + (.keycode | tostring)
    else "Unknown" end;
  map(select((.description // "") != ""))
  | map({
      category: (.description | split(":")[0]),
      shortcut: ((modifiers + [bindkey]) | join("+")),
      action: (.description | sub("^[^:]+:[ ]*"; ""))
    })
  | unique_by(.shortcut, .action)
  | sort_by(.category, .action, .shortcut)
  | .[]
  | [.category, .shortcut, .action]
  | @tsv
' | column -t -s $'\t' >>"$cheatsheet" || fail "Could not parse active Hyprland keybinds."

yad --text-info \
  --title="Hyprland Keybind Cheatsheet" \
  --class="hyprland-cheatsheet" \
  --filename="$cheatsheet" \
  --fontname="Monospace 11" \
  --width=980 \
  --height=720 \
  --center \
  --on-top \
  --margins=18 \
  --button="Close:0" || true
