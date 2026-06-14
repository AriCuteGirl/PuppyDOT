# This script is meant to be sourced.
# It's not for directly running.

# shellcheck shell=bash

#####################################################################################

printf "${STY_CYAN}${STY_BOLD}Haiii! I see you are installing my dotfiles. Enjoy!${STY_RST}\n"
printf "\n"
printf "${STY_PURPLE}This installer prepares Hyprland, Noctalia, and the rest of the desktop rice.${STY_RST}\n"
printf "${STY_PURPLE}After the first login, a friendly setup assistant will guide you through:${STY_RST}\n"
printf "${STY_PURPLE}  - essential Hyprland shortcuts\n"
printf "  - installing common apps\n"
printf "  - Noctalia customization\n"
printf "  - choosing a default browser\n"
printf "  - package mirrors and system updates\n"
printf "  - graphics driver guidance${STY_RST}\n"
printf "\n"
pause
printf "${STY_CYAN}${STY_BOLD}What this installer does:${STY_RST}\n"
printf "${STY_CYAN}"
printf "  1. Install Hyprland and the desktop dependencies.\n"
printf "  2. Setup permissions/services etc.\n"
printf "  3. Copying config files and Noctalia polish.${STY_RST}\n"
pause
printf "${STY_CYAN}${STY_BOLD}Before continuing:${STY_RST}\n"
printf "${STY_CYAN}"
printf "  a) The installer can be run again if a step is interrupted.\n"
printf "  b) Existing configuration conflicts can be backed up.\n"
printf "  c) Use ${STY_INVERT} --help ${STY_RST}${STY_CYAN} for advanced options.${STY_RST}\n"
printf "${STY_YELLOW}${STY_BOLD}Note: ${STY_RST}"
printf "${STY_YELLOW}"
printf "Graphics drivers are hardware-specific. The first-login assistant detects the GPU and opens the correct guidance instead of installing a risky guess.\n"
printf "${STY_RST}"
printf "\n"
pause

case $ask in
  false) sleep 0 ;;
  *) 
    printf "${STY_BLUE}"
    printf "${STY_BOLD}Do you want to confirm every time before a command executes?${STY_RST}\n"
    printf "${STY_BLUE}"
    printf "  y = Yes, ask me before executing each of them. (DEFAULT)\n"
    printf "  n = No, I know everything this script will do, just execute them automatically.\n"
    printf "  a = Abort.\n"
    read -p "===> [Y/n/a]: " p
    case $p in
      n) ask=false ;;
      a) exit 1 ;;
      *) ask=true ;;
    esac
    printf "${STY_RST}"
    ;;
esac
