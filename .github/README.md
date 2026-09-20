<div align="center">
    <h1>【 end_4's Hyprland dotfiles 】</h1>
    <h3></h3>
</div>

<div align="center"> 

![](https://img.shields.io/github/last-commit/The1fEst/dots-hyprland?&style=for-the-badge&color=8ad7eb&logo=git&logoColor=D9E0EE&labelColor=1E202B)
![](https://img.shields.io/github/stars/The1fEst/dots-hyprland?style=for-the-badge&logo=andela&color=86dbd7&logoColor=D9E0EE&labelColor=1E202B)
![](https://img.shields.io/github/repo-size/The1fEst/dots-hyprland?color=86dbce&label=SIZE&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B)
<a href="https://discord.gg/GtdRBXgMwq"> <img alt="Dynamic JSON Badge" src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fdiscordapp.com%2Fapi%2Finvites%2FGtdRBXgMwq%3Fwith_counts%3Dtrue&query=approximate_member_count&style=for-the-badge&logo=discord&logoColor=D9E0EE&label=discord&labelColor=%231E202B&color=86dbc0&link=https%3A%2F%2Fdiscord.gg%2FGtdRBXgMwq"> </a>

</div>

<div align="center">
    <h2>• overview •</h2>
    <h3></h3>
</div>

> [!WARNING]  
> Hyprland 0.55 update:
> If your distro has not shipped Hyprland 0.55 and/or you're not ready for it, you should switch to the Pre-Hyprland Luaification release (or not update yet, if you're going to do that). See the wiki for more info: [Install](https://ii.clsty.link/en/ii-qs/01setup/#automated-installation) | [Update](https://ii.clsty.link/en/ii-qs/01setup/#updating)

<details> 
  <summary>What this is/isn't</summary>

  - Technically, configuration files
  - Realistically, mostly the custom graphical shell
  - NOT a system setup script: no graphic drivers, no zram setup, etc.
  
</details>

<details> 
  <summary>Notable features</summary>
     
  - **Overview**: Shows open apps with live previews
  - **Material themes**: Choose your wallpaper, done, enjoy
  - **Transparent installation**: Every command is shown before it's run
</details>

<details> 
  <summary>Installation</summary>

   - **Arch only.** The installer stops on anything else
   - **IMPORTANT: Hyprland 0.55 Update**: If your distro has not shipped Hyprland 0.55 and/or you're not ready for it, you should switch to the Pre-Hyprland Luaification release. See [the wiki](https://ii.clsty.link/en/ii-qs/01setup/) for more info
   - Clone this repo and run `./setup install`
     - The one-line `bash <(curl -s https://ii.clsty.link/get)` installs upstream, not this fork
     - See [the wiki](https://ii.clsty.link/en/ii-qs/01setup/) for what the steps do
   - **Keybinds**: Should be somewhat familiar to Windows or GNOME users. Important ones:
     - `Super`+`/` = keybind list
     - `Super`+`Enter` = terminal


</details>

<details>
  <summary>Software overview</summary>

  | Software | Purpose |
  | ------------- | ------------- |
  | [Hyprland](https://github.com/hyprwm/hyprland) | The compositor (manages and renders windows) |
  | [Quickshell](https://quickshell.outfoxxed.me/) | A QtQuick-based widget system, used for the status bar, sidebars, etc. |
  | Others | See [deps-info.md](https://github.com/The1fEst/dots-hyprland/blob/main/sdata/deps-info.md) |

</details>

<details>
    <summary>Discord</summary>
        <a href="https://discord.gg/GtdRBXgMwq"> Server link</a> | I hope this provides a friendlier environment for support without needing me to personally accept every friend request/DM. For real issues, prefer GitHub

</details>

<div align="center">
    <h2>• fork changes •</h2>
    <h3></h3>
</div>

This fork drops everything that talks to a remote service or runs inference, supports Arch only,
and keeps growing the settings app until the KDE and GNOME control panels are no longer needed.
Everything not listed here is upstream.

<details>
  <summary>Added</summary>

  - **Settings app** — grown from seven pages to seventeen, in a window that runs inside the
    shell rather than as its own process. Next to a Quick page for the common ones, it covers
    Wi-Fi, network and WireGuard, Bluetooth, displays, sound, power and idle, multitasking,
    appearance, applications and commands, notifications, search, mouse and touchpad, keyboard,
    accessibility, privacy and the system pages, reaching options that previously could only be
    edited by hand in `config.json`.
    Changing the account password and arranging displays happen here instead of in `kcmshell6`
  - **Welcome window** — also part of the shell now, and sets up displays, sound and power saving
    on the first run
  - **WireGuard** — quick toggle plus a connections dialog in the right sidebar
  - **Reboot to Windows** — a session screen button in place of the task manager one, backed by
    `scripts/system/boot-next-windows.sh`. It arms a one-shot UEFI `BootNext` at the Windows Boot
    Manager and reboots; the firmware clears `BootNext` itself, so a failed Windows boot lands
    back in Linux. Needs no setup — writing the variable goes through `pkexec`, so the shell's
    polkit agent asks for the password. To skip that prompt, allow the one call in
    `/etc/sudoers.d` and swap `pkexec` for `sudo -n` in the script
  - **Pending system updates** in the bar, read from `checkupdates`
  - **Drag to arrange** — dock icons pin, unpin and reorder by dragging; quick toggles are added,
    removed and rearranged the same way
  - **Region selector** — a mode panel and an options menu, the pointer can be kept in the
    capture, and saving a screenshot to a file is a setting rather than a fixed behaviour
  - **About page** — what the machine is, which graphics card it has, a card per mounted disk,
    and this fork's own name and link
  - **Calendar** — opens from the clock instead of the right sidebar
  - **Auto HDR** — Hyprland's three automatic modes, not just on and off
  - **Sounds** — the alert theme is picked from the themes that are installed, and the microphone
    alert has its own switch
  - **Lock screen** — shows the account's full name when one is set, and the keyboard layout in
    upper case
  - **Bar** — keyboard layout indicator in upper case
  - `StringUtils.splitList()` for parsing the comma-separated fields the settings app now uses

</details>

<details>
  <summary>Rewritten</summary>

  - **Media controls** — reworked `MprisController`, seeking and player filtering; the media
    keys drive the shell over IPC instead of shelling out to `playerctl`
  - **Bar layout** — consistency pass across the bar; the active-window widget was dropped
  - **Panels** — the waffle family is gone and the panels load directly; `ii` is the one family
    this fork develops
  - **Installer** — uses `paru` instead of `yay`, and refuses to run anywhere but Arch
  - **Fonts** — the interface defaults to Google Sans, so non-Latin text keeps a proper face;
    Google Sans Flex stays only on the background clock, which can pick its own family
  - **Clipboard history** — back on `cliphist`, with `wl-clip-persist` holding the clipboard after
    the program that filled it exits, both run as systemd user units. Images get their own preview
    row, and vendor blobs stay out of the list
  - **hypridle** — started from a systemd user unit instead of Hyprland's exec list, so the
    settings app can restart it
  - `scheme_for_image.py` moved from OpenCV to PIL, keeping the same colorfulness metric
  - Lock screen clock uses a 12-hour format

</details>

<details>
  <summary>Removed: anything leaving the machine</summary>

  - Screen translator — sent full screenshots to Google Cloud Vision (OCR) and the recognised
    text to Google Translate, together with the service-account keyring plumbing
  - `snip_to_search.sh` — uploaded screen regions to the public host uguu.se, then opened Google Lens
  - Google favicons in the launcher, which leaked searched domains before you pressed Enter
  - Web search in the launcher and the start menu
  - Random wallpapers from the konachan and osu APIs
  - Floating image overlay and its URL downloader
  - "Open network portal" button (nmcheck.gnome.org) and the Valorant crosshair editor link

</details>

<details>
  <summary>Removed: AI and heavy dependencies</summary>

  - Ollama scripts and the primary-selection query keybind
  - OpenCV, entirely. It backed content-region hints in the region selector and background
    widget placement; the latter now picks a random spot on the monitor
  - `hyprconfigurator.py`, along with game mode and the anti-flashbang Hyprland shader, the two
    features that wrote through it
  - tesseract OCR keybind

</details>

<details>
  <summary>Removed: features and dead code</summary>

  - Widget overlay on `Super`+`G`, with its FPS limiter, notes, recorder, resources and volume mixer
  - Crosshair overlay
  - Anti-flashbang in both variants — the Hyprland screen shader and the content-based
    brightness adjustment that screenshotted the display on every window switch
  - Left sidebar, AI chat, anime and music recognition
  - The waffle panel family, and the machinery for picking a family at all
  - The calendar view the bar's own calendar panel replaced
  - The `nwg-displays` `monitors.lua` and `workspaces.lua` hooks, which fought the settings app
    over the same files
  - The click-to-show tooltip option, and two settings nothing ever read
  - Leftovers from features upstream had already dropped: AI chat state, the booru service and
    its directories, translate-shell config, an "Enable translator" switch bound to a
    nonexistent option, and a "Generate translation with Gemini" button whose process was
    never declared

</details>

<details>
  <summary>What still uses the network</summary>

  - **Weather** — `wttr.in`, with GPS coordinates when `enableGPS` is set. Off by default
  - **Album art** — downloaded from the URL the MPRIS player reports
  - The installer fetches `uv` from `astral.sh` and cursors from GitHub releases

Nothing else in `dots/` makes an outgoing request.

</details>

<details>
  <summary>Packaging and setup</summary>

  - **Arch only.** The Fedora, Gentoo and Nix trees are gone, and the installer stops on anything
    that is not Arch rather than half-installing
  - Python packages drop from 33 to 16. Removed `opencv-contrib-python`, `google-auth` and
    `requests`, plus `pywayland`, `psutil`, `setproctitle`, `libsass` and
    `material-color-utilities`, which nothing in the repo referenced
  - `tesseract` and its language data are gone
  - `illogical-impulse-apps` is a new meta package for the applications the shell hands work to
    rather than uses itself: GNOME Calendar for `text/calendar` and Thunderbird for `mailto`
  - `power-profiles-daemon` is installed, so the power profile controls have a daemon to talk to
  - NetworkManager is enabled by the installer, unless the machine already has another network
    manager enabled
  - Directories open in Dolphin instead of whatever claimed `inode/directory` first
  - EasyEffects is installed but no longer autostarted; the sidebar toggle starts it
  - The systemd user units the shell relies on ship with it: `quickshell`, `hypridle`,
    `cliphist-text`, `cliphist-image` and `wl-clip-persist`
  - `colors.lua` and `hyprlock/colors.conf` are no longer tracked — matugen regenerates them
    on every wallpaper change

</details>

<div align="center">
    <h2>• screenshots •</h2>
    <h3></h3>
</div>

<div align="center">
    <img src="assets/illogical-impulse.svg" alt="illogical-impulse logo" style="float:left; width:400;">
</div>

Widget system: Quickshell | Support: Yes

[Showcase video](https://www.youtube.com/watch?v=RPwovTInagE)

| Settings app | Some widgets |
|:---|:---------------|
| <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5d4e7d07-d0b4-4406-a4c9-ed7ba90e3fe4" /> | <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/6a32395f-9437-4192-8faf-2951a9e84cbe" /> |
| Window management | wow look its orange |
| <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/c51bed8b-3670-4d4c-9074-873be224fb8e" /> | <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/98703a66-0743-439f-a721-cef7afa6ab95" /> |

<div align="center">
    <h2>• thank you •</h2>
    <h3></h3>
</div>

 - [@clsty](https://github.com/clsty) for making the dotfiles accessible by taking care of the install script and many other things
 - [@midn8hustlr](https://github.com/midn8hustlr) for greatly improving the color generation system
 - [@outfoxxed](https://github.com/outfoxxed/) for being extremely supportive in my Quickshell journey
 - Quickshell: [Soramane](https://github.com/caelestia-dots/shell/), [FridayFaerie](https://github.com/FridayFaerie/quickshell), [nydragon](https://github.com/nydragon/nysh)
 - AGS: [Aylur](https://github.com/Aylur/dotfiles/tree/ags-pre-ts), [kotontrion](https://github.com/kotontrion/dotfiles)
 - EWW: [fufexan](https://github.com/fufexan/dotfiles)

<div align="center">
    <h2>• stonks •</h2>
    <h3></h3>
</div>

- I promise not to attempt an +ULTRARICOSHOT irl... Coins can go here: https://github.com/sponsors/end-4
- Tentacle cat hub twinkle internet points

[![Stargazers over time](https://starchart.cc/end-4/dots-hyprland.svg?variant=adaptive)](https://starchart.cc/end-4/dots-hyprland)


---

<div align="center">
    <h2>• previous styles •</h2>
    <h3></h3>
</div>

- **Unsupported!**
- **Source**: illogical-impulse AGS in `ii-ags` branch, others in `archive` branch.
- List is in reverse chronological order

### illogical-impulse (AGS)

Widget system: AGS | Support: No

| AI | Common widgets |
|:---|:---------------|
| ![image](https://github.com/user-attachments/assets/9d7af13f-89ef-470d-ba78-d2288b79cf60) | ![image](https://github.com/end-4/dots-hyprland/assets/97237370/406b72b6-fa38-4f0d-a6c4-4d7d5d5ddcb7) |
| Window management | Weeb power |
| ![image](https://github.com/user-attachments/assets/02983b9b-79ba-4c25-8717-90bef2357ae5) | ![image](https://github.com/user-attachments/assets/bbb332ec-962a-4e88-a95b-486d0bd8ce76) |

#### m3ww

Widget system: EWW | Support: No

<a href="https://streamable.com/85ch8x">
<img src="https://github.com/end-4/dots-hyprland/assets/97237370/09533e64-b6d7-47eb-a840-ee90c6776adf" alt="Material Eww!">
</a>

#### NovelKnock

Widget system: EWW | Support: No

<a href="https://streamable.com/7vo61k">
<img src="https://github.com/end-4/dots-hyprland/assets/97237370/42903d03-bf6f-49d4-be7f-dd77e6cb389d" alt="Desktop Preview">
</a>

#### Hybrid

Widget system: EWW | Support: No

<a href="https://streamable.com/4oogot">
<img src="https://github.com/end-4/dots-hyprland/assets/97237370/190deb1e-f6f5-46ce-8cf0-9b39944c079d" alt="click the circles!">
</a>

#### Windoes

Widget system: EWW | Support: No

<a href="https://streamable.com/5qx614">
<img src="https://github.com/end-4/dots-hyprland/assets/97237370/b15317b1-f295-49f5-b90c-fb6328b8d886" alt="Desktop Preview">
</a>



<div align="center">
    <h2>• inspirations/copying •</h2>
    <h3></h3>
</div>

 - Inspiration: osu!lazer (Hybrid), Windows 11 (Windoes), AvdanOS (NovelKnock), Material Design 3 (m3ww & later)
 - Copying: Absolutely, feel free. Just follow the license and it's all good
 
