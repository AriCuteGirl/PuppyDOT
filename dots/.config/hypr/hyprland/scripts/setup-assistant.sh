#!/usr/bin/env bash

set -u

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/ari-dotfiles"
complete_file="$state_dir/setup-complete"
mkdir -p "$state_dir"

if [[ "${1:-}" == "--first-run" && -e "$complete_file" ]]; then
  exit 0
fi

notify() {
  notify-send "$1" "$2" -a "Dotfiles Setup"
}

terminal_run() {
  local title=$1
  local command=$2
  setsid kitty --title "$title" --hold sh -lc \
    "printf '\\033[1;36m%s\\033[0m\\n\\n' '$title'; printf '\\033[2m%s\\033[0m\\n\\n' '$command'; $command; status=\$?; printf '\\nCommand exited with status %s.\\n' \"\$status\"; exit \"\$status\"" \
    >/dev/null 2>&1 &
}

show_intro() {
  yad --text-info \
    --title="Welcome to my dotfiles" \
    --class="dotfiles-setup" \
    --width=760 --height=560 --center --on-top --wrap --margins=24 --formatted \
    --button="Continue:0" <<'EOF'
<span foreground="#ff8bd1" size="x-large"><b>Haiii!</b></span>
<span foreground="#d8b4fe"><b>I see you are using my dotfiles. Enjoy.</b></span>

<span foreground="#f3e8ff">This Noctalia-first setup assistant is here to make the first day with Hyprland less confusing.</span>
<span foreground="#f3e8ff">Nothing in this assistant makes hidden system changes. Anything requiring sudo opens</span>
<span foreground="#f3e8ff">in a terminal first so you can read the command and confirm it.</span>

<span foreground="#ff8bd1"><b>Already handled by the dotfiles:</b></span>
  <span foreground="#f3e8ff">- Hyprland appearance and keybinds</span>
  <span foreground="#f3e8ff">- Noctalia configuration and shell polish</span>
  <span foreground="#f3e8ff">- A searchable keybind cheatsheet on Super + /</span>
  <span foreground="#f3e8ff">- Default-browser shortcut on Super + W</span>
  <span foreground="#f3e8ff">- Common desktop services and theming</span>

<span foreground="#d8b4fe"><b>Useful first steps:</b></span>
  <span foreground="#f3e8ff">- Super + /       Keybind cheatsheet</span>
  <span foreground="#f3e8ff">- Super + Enter   Terminal</span>
  <span foreground="#f3e8ff">- Super + .       App launcher</span>
  <span foreground="#f3e8ff">- Super + W       Default browser</span>
  <span foreground="#f3e8ff">- Super + Q       Close a window</span>

<span foreground="#f3e8ff">You can close this assistant and it will return next login until you select</span>
<span foreground="#f3e8ff">"Finish setup".</span>
EOF
}

quick_tour() {
  yad --text-info \
    --title="Hyprland quick tour" --class="dotfiles-setup" \
    --width=800 --height=620 --center --on-top --wrap --margins=24 --formatted \
    --button="Back:0" <<'EOF'
<span foreground="#ff8bd1" size="x-large"><b>HYPRLAND QUICK TOUR</b></span>

<span foreground="#f3e8ff">Super is the Windows/Command key.</span>

<span foreground="#ff8bd1"><b>Windows</b></span>
  <span foreground="#f3e8ff">Super + Q                 Close focused window</span>
  <span foreground="#f3e8ff">Super + F                 Fullscreen</span>
  <span foreground="#f3e8ff">Super + Alt + Space       Toggle floating/tiled</span>
  <span foreground="#f3e8ff">Super + Arrow keys        Move focus</span>
  <span foreground="#f3e8ff">Super + Shift + Arrows    Move the focused window</span>

<span foreground="#d8b4fe"><b>Workspaces</b></span>
  <span foreground="#f3e8ff">Super + 1..0              Switch workspace</span>
  <span foreground="#f3e8ff">Super + Alt + 1..0        Send a window to a workspace</span>
  <span foreground="#f3e8ff">Super + mouse wheel       Change workspace</span>

<span foreground="#ff8bd1"><b>Apps and shell</b></span>
  <span foreground="#f3e8ff">Super + Enter             Terminal</span>
  <span foreground="#f3e8ff">Super + .                 Noctalia app launcher</span>
  <span foreground="#f3e8ff">Super + W                 Default browser</span>
  <span foreground="#f3e8ff">Super + C                 Steam</span>
  <span foreground="#f3e8ff">Super + N                 Noctalia control center</span>
  <span foreground="#f3e8ff">Super + /                 Full searchable cheatsheet</span>

<span foreground="#d8b4fe"><b>Recovery tip</b></span>
  <span foreground="#f3e8ff">If something looks wrong, open a terminal with Super + Enter and run:</span>
  <span foreground="#f3e8ff">    hyprctl reload</span>
EOF
}

app_installer() {
  local selected
  selected=$(yad --list --checklist \
    --title="App installer" --class="dotfiles-setup" \
    --text="Choose apps to install from the official repositories." \
    --width=780 --height=620 --center --on-top \
    --column="Install:CHK" --column="Package" --column="Description" \
    FALSE firefox "Web browser" \
    FALSE steam "PC game launcher" \
    FALSE discord "Chat and communities" \
    FALSE vlc "Video and audio player" \
    FALSE libreoffice-fresh "Office suite" \
    FALSE gimp "Image editor" \
    FALSE obs-studio "Recording and streaming" \
    FALSE thunderbird "Email client" \
    FALSE signal-desktop "Private messenger" \
    FALSE prismlauncher "Minecraft launcher" \
    FALSE flatpak "Flatpak application support" \
    --print-column=2 --separator=" " \
    --button="Cancel:1" --button="Install selected:0") || return

  [[ -n "$selected" ]] || {
    notify "No apps selected" "Choose at least one application to install."
    return
  }

  terminal_run "Install selected apps" "sudo pacman -S --needed $selected"
}

ari_preset() {
  terminal_run "Install Ari desktop" "
    sudo pacman -S --needed steam discord vlc libreoffice-fresh gimp obs-studio thunderbird signal-desktop prismlauncher flatpak &&
    if command -v yay >/dev/null 2>&1; then
      yay -S --needed --noconfirm brave-origin-nightly-bin
    fi &&
    if command -v brave-origin-nightly >/dev/null 2>&1; then
      xdg-settings set default-web-browser brave-origin-nightly.desktop
    fi &&
    printf '\\nAri preset installed.\\n' &&
    printf 'Super + W will now open the default browser.\\n'
  "
}

open_noctalia_settings() {
  if qs -c noctalia-shell ipc call settings open >/dev/null 2>&1; then
    return
  fi
  yad --warning --title="Noctalia is not available" --center --on-top \
    --text="No running Noctalia shell was detected. Log out and back in after installation, then try again."
}

set_default_browser() {
  local rows=()
  local desktop name

  while IFS= read -r desktop; do
    [[ -n "$desktop" ]] || continue
    name=$(grep -m1 '^Name=' "$desktop" | cut -d= -f2-)
    rows+=("$(basename "$desktop")" "${name:-$(basename "$desktop" .desktop)}")
  done < <(grep -l 'x-scheme-handler/http' \
    /usr/share/applications/*.desktop "$HOME"/.local/share/applications/*.desktop 2>/dev/null | sort -u)

  if (( ${#rows[@]} == 0 )); then
    notify "No browser found" "Install a browser first, then return here."
    return
  fi

  desktop=$(yad --list --title="Choose default browser" --class="dotfiles-setup" \
    --text="Super + W will launch the browser selected here." \
    --width=620 --height=460 --center --on-top \
    --column="Desktop file" --column="Browser" "${rows[@]}" \
    --hide-column=1 --print-column=1 \
    --button="Cancel:1" --button="Set default:0") || return

  desktop=${desktop%|}
  [[ -n "$desktop" ]] || return
  xdg-settings set default-web-browser "$desktop" && \
    notify "Default browser updated" "Super + W will now open $(xdg-settings get default-web-browser)."
}

setup_mirrors() {
  local country
  country=$(yad --entry --title="Set fast mirrors" --class="dotfiles-setup" \
    --text="Enter one or more nearby countries separated by commas.\nExample: Czechia,Germany,Austria\n\nThis updates Arch mirrors and then ranks EndeavourOS mirrors." \
    --entry-text="Czechia,Germany,Austria" --width=620 --center --on-top \
    --button="Cancel:1" --button="Continue:0") || return

  if [[ ! "$country" =~ ^[A-Za-z[:space:],.-]+$ ]]; then
    notify "Invalid country list" "Use country names separated by commas."
    return
  fi

  local quoted_country
  printf -v quoted_country '%q' "$country"
  terminal_run "Optimize package mirrors" \
    "sudo reflector --country $quoted_country --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && if command -v eos-rankmirrors >/dev/null; then sudo eos-rankmirrors --sort rate; fi && sudo pacman -Syy"
}

driver_check() {
  local gpu report wiki="https://wiki.archlinux.org/title/Xorg#Driver_installation"
  gpu=$(lspci 2>/dev/null | grep -Ei 'VGA|3D|Display' || true)
  [[ -n "$gpu" ]] || gpu="No graphics adapter was reported by lspci."

  if grep -qi nvidia <<<"$gpu"; then
    wiki="https://wiki.archlinux.org/title/NVIDIA"
  elif grep -Eqi 'AMD|ATI' <<<"$gpu"; then
    wiki="https://wiki.archlinux.org/title/AMDGPU"
  elif grep -qi intel <<<"$gpu"; then
    wiki="https://wiki.archlinux.org/title/Intel_graphics"
  fi

  report="Detected graphics hardware:\n\n$gpu\n\nCurrent graphics stack:\n\n$(inxi -Gxxc0 2>/dev/null || true)\n\nThe assistant will not install a graphics driver automatically because the correct package depends on the GPU and kernel."

  yad --text="$report" --title="Graphics driver check" --class="dotfiles-setup" \
    --width=760 --center --on-top \
    --button="Back:0" \
    --button="Open Arch Wiki!help-browser:2" \
    --button="Open EndeavourOS Welcome!applications-system:3"
  case $? in
    2) xdg-open "$wiki" ;;
    3)
      if command -v eos-welcome >/dev/null; then eos-welcome &
      else notify "EndeavourOS Welcome not found" "Use the Arch Wiki button for driver guidance."
      fi
      ;;
  esac
}

system_update() {
  terminal_run "Update the system" "sudo pacman -Syu"
}

finish_setup() {
  if yad --question --title="Finish setup?" --class="dotfiles-setup" \
    --text="Mark setup complete and stop opening this assistant automatically?\n\nYou can still run ~/.config/hypr/hyprland/scripts/setup-assistant.sh later." \
    --center --on-top --button="Not yet:1" --button="Finish:0"; then
    touch "$complete_file"
    notify "Setup complete" "Enjoy the dotfiles. Press Super + / whenever you need help."
    exit 0
  fi
}

show_intro

while true; do
  noctalia_status="Not detected"
  qs -c noctalia-shell ipc call state all >/dev/null 2>&1 && noctalia_status="Running and configured"

  action=$(yad --list \
    --title="My Dotfiles Setup Assistant" --class="dotfiles-setup" \
    --text="Choose a setup step. You can return to this menu at any time." \
    --width=860 --height=610 --center --on-top \
    --column="Action" --column="What it does" --column="Status" \
    "Quick tour" "Learn the essential Hyprland shortcuts" "Recommended" \
    "Install Ari desktop" "Install your curated browser, games and media apps" "Recommended" \
    "App installer" "Install common applications" "Optional" \
    "Noctalia settings" "Customize the shell, bar, colors and wallpaper" "$noctalia_status" \
    "Default browser" "Choose what Super + W opens" "$(xdg-settings get default-web-browser 2>/dev/null || echo 'Not set')" \
    "Fast mirrors" "Rank nearby Arch and EndeavourOS mirrors" "Optional" \
    "Graphics drivers" "Detect the GPU and open the correct guidance" "Review recommended" \
    "System update" "Run a full package update" "Recommended" \
    "Keybind cheatsheet" "Open the searchable shortcut list" "Super + /" \
    "Finish setup" "Stop showing this assistant on login" "Final step" \
    --print-column=1 --separator="" \
    --button="Close for now:1" --button="Open:0") || exit 0

  case "$action" in
    "Quick tour") quick_tour ;;
    "Install Ari desktop") ari_preset ;;
    "App installer") app_installer ;;
    "Noctalia settings") open_noctalia_settings ;;
    "Default browser") set_default_browser ;;
    "Fast mirrors") setup_mirrors ;;
    "Graphics drivers") driver_check ;;
    "System update") system_update ;;
    "Keybind cheatsheet") "$HOME/.config/hypr/hyprland/scripts/keybind-cheatsheet.sh" & ;;
    "Finish setup") finish_setup ;;
  esac
done
