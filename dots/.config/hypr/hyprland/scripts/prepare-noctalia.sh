#!/bin/sh

set -eu

config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
cache_root="${XDG_CACHE_HOME:-$HOME/.cache}"
system_shell="/etc/xdg/quickshell/noctalia-shell"
user_shell="$config_root/quickshell/noctalia-shell"
provider_rel="Modules/Panels/Launcher/Providers/ApplicationsProvider.qml"
provider_override="$config_root/hypr/hyprland/noctalia/ApplicationsProvider.qml"
version_file="$cache_root/puppydot/noctalia-version"

if [ ! -d "$system_shell" ]; then
  printf 'PuppyDOT: Noctalia package files are missing at %s\n' "$system_shell" >&2
  exit 1
fi

mkdir -p "$user_shell" "$(dirname "$version_file")"

installed_version="$(pacman -Q noctalia-shell 2>/dev/null | awk '{print $2}' || true)"
prepared_version="$(cat "$version_file" 2>/dev/null || true)"

# Refresh package-owned shell files after installation and package upgrades.
if [ ! -f "$user_shell/shell.qml" ] || { [ -n "$prepared_version" ] && [ "$installed_version" != "$prepared_version" ]; }; then
  rsync -rlpt --delete "$system_shell/" "$user_shell/"
fi

if [ ! -f "$provider_override" ]; then
  printf 'PuppyDOT: Noctalia launcher override is missing at %s\n' "$provider_override" >&2
  exit 1
fi

install -Dm644 "$provider_override" "$user_shell/$provider_rel"

settings="$config_root/noctalia/settings.json"
if [ -f "$settings" ] && command -v jq >/dev/null 2>&1; then
  settings_tmp="$(mktemp "${settings}.XXXXXX")"
  if jq '.appLauncher.terminalCommand = "kitty -1"' "$settings" >"$settings_tmp"; then
    mv "$settings_tmp" "$settings"
  else
    rm -f "$settings_tmp"
  fi
fi

printf '%s\n' "$installed_version" >"$version_file"
