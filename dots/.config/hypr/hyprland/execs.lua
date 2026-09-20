-- put former exec-once commands inside the func and former exec commands outside
hl.on("hyprland.start", function ()

    -- Bar, wallpaper
    hl.exec_cmd("$HOME/.config/hypr/hyprland/scripts/start_geoclue_agent.sh")
    -- The target is what the rest of the session hangs off: binding to
    -- graphical-session.target is what starts the portals and the autostarted apps.
    -- quickshell is named as well so that it comes up even where enabling it failed.
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd --all && systemctl --user start hyprland-session.target quickshell.service")
    hl.exec_cmd("$HOME/.config/hypr/custom/scripts/__restore_video_wallpaper.sh")

    -- Core components (authentication, lock screen, notification daemon)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP") -- Some fix idk

    -- Audio
    hl.exec_cmd("easyeffects --hide-window --service-mode")

    -- Cursor: follow XCURSOR_* so custom/env.lua wins instead of racing this line
    hl.exec_cmd("hyprctl setcursor \"${XCURSOR_THEME:-Bibata-Modern-Classic}\" \"${XCURSOR_SIZE:-24}\"")
end)
