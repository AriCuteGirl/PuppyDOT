-- First-login walkthrough. It stops launching after "Finish setup" is selected.
hl.on("hyprland.start", function ()
    hl.exec_cmd("sleep 5 && $HOME/.config/hypr/hyprland/scripts/setup-assistant.sh --first-run")
    hl.exec_cmd("$HOME/.config/hypr/hyprland/scripts/start-noctalia.sh")
end)
