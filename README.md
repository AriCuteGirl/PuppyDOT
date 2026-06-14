# PuppyDOT

PuppyDOT is my personal Hyprland rice for Arch-based installs, with a Noctalia-first desktop flow and a guided first-login setup assistant.

## What it includes

- Hyprland install and config
- Noctalia shell setup and polish
- A searchable keybind cheatsheet
- Curated app preset for a fresh desktop
- Browser selection, mirrors, and driver guidance
- A setup assistant that walks through the common first steps

## Install

On a fresh Arch or EndeavourOS install:

```bash
git clone https://github.com/AriCuteGirl/PuppyDOT.git
cd PuppyDOT
./setup install
```

The installer already handles the Hyprland packages for Arch-based systems and then copies the rice/config layer on top.

## After first login

- `Super + /` opens the cheatsheet
- `Super + Enter` opens a terminal
- `Super + .` opens the app launcher
- `Super + W` opens the default browser

## Notes

- This repo is tuned for Noctalia Shell, not the old Quickshell/illogical-impulse flow.
- The first-login assistant can install the curated desktop bundle and guide through mirrors, browser choice, and GPU checks.
- I keep the setup explicit and visible so it is easier to hand to someone new.

