local home_dir = os.getenv("HOME")

-- Wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Applications
-- A reload runs this file again over the environment the last one left behind, so the
-- list has to be rebuilt rather than prepended to. GTK walks every entry at startup.
local data_dirs = {
	home_dir .. "/.local/share/flatpak/exports/share",
	"/var/lib/flatpak/exports/share",
	"/usr/local/share",
	"/usr/share",
}
for dir in (os.getenv("XDG_DATA_DIRS") or ""):gmatch("[^:]+") do
	table.insert(data_dirs, dir)
end
local seen = {}
local unique = {}
for _, dir in ipairs(data_dirs) do
	if not seen[dir] and not dir:match("^%$[%w_]+$") then
		seen[dir] = true
		table.insert(unique, dir)
	end
end
hl.env("XDG_DATA_DIRS", table.concat(unique, ":"))

-- Themes
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")

-- Virtual environment
hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", home_dir .. "/.local/state/quickshell/.venv")

-- Games
hl.env("PROTON_ENABLE_WAYLAND", "1")
hl.env("DXVK_HDR", "1")

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

    hl.env("PROTON_ENABLE_NVAPI", "1")
    hl.env("DXVK_ENABLE_NVAPI", "1")
end