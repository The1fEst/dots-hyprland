local home_dir = os.getenv("HOME")

-- Wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Applications
local xdg_data_dirs_old = os.getenv("XDG_DATA_DIRS") or ""
hl.env("XDG_DATA_DIRS", home_dir .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:" .. xdg_data_dirs_old)

-- Themes
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")

-- Virtual environment
hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", home_dir .. "/.local/state/quickshell/.venv")

-- Every value below names NVIDIA's own driver, so the file it registers is what says
-- whether any of them mean anything here. Nouveau does not create it.
local nvidia = is_file_exists("/proc/driver/nvidia/version")

if nvidia then
    -- Qt draws through its software fallback on this driver and every widget app drags
    hl.env("QT_WIDGETS_RHI", "1")
    hl.env("QT_WIDGETS_RHI_BACKEND", "opengl")

    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("NVD_BACKEND", "direct")
    hl.env("GBM_BACKEND", "nvidia-drm")
end