# This script is meant to be sourced.
# It's not for directly running.

function setup_user_group(){
  if [[ -z $(getent group i2c) ]]; then
    x sudo groupadd i2c
  fi

  x sudo usermod -aG video,i2c,input "$(whoami)"
}

function set_default_apps(){
  local mime

  x gio mime inode/directory org.kde.dolphin.desktop
  for mime in image/jpeg image/png image/gif image/webp image/tiff image/bmp; do
    x gio mime "$mime" satty.desktop
  done
  for mime in video/mp4 video/x-matroska video/webm video/quicktime audio/mpeg audio/flac; do
    x gio mime "$mime" vlc.desktop
  done
}

function network_managed_elsewhere(){
  local svc
  for svc in systemd-networkd iwd connman netctl dhcpcd; do
    systemctl is-enabled --quiet "$svc" 2>/dev/null && return 0
  done
  return 1
}
#####################################################################################
# These python packages are installed using uv into the venv (virtual environment). Once the folder of the venv gets deleted, they are all gone cleanly. So it's considered as setups, not dependencies.
showfun install-python-packages
v install-python-packages

showfun setup_user_group
v setup_user_group

if [[ ! -z $(systemctl --version) ]]; then
  v bash -c "echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf"
  # When $DBUS_SESSION_BUS_ADDRESS and $XDG_RUNTIME_DIR are empty, it commonly means that the current user has been logged in with `su - user` or `ssh user@hostname`. In such case `systemctl --user enable <service>` is not usable. It should be `sudo systemctl --machine=$(whoami)@.host --user enable <service>` instead.
  if [[ ! -z "${DBUS_SESSION_BUS_ADDRESS}" ]]; then
    v systemctl --user enable ydotool --now
  else
    v sudo systemctl --machine=$(whoami)@.host --user enable ydotool --now
  fi
  v sudo systemctl enable bluetooth --now
  if network_managed_elsewhere; then
    printf "${STY_YELLOW}[$0]: Another network manager is enabled, leaving NetworkManager alone.${STY_RST}\n"
  else
    v sudo systemctl enable NetworkManager --now
  fi
elif [[ ! -z $(openrc --version) ]]; then
  v bash -c "echo 'modules=i2c-dev' | sudo tee -a /etc/conf.d/modules"
  v sudo rc-update add modules boot
  v sudo rc-update add ydotool default
  v sudo rc-update add bluetooth default
  if [ -x /etc/init.d/NetworkManager ]; then
    v sudo rc-update add NetworkManager default
    x sudo rc-service NetworkManager start
  fi

  x sudo rc-service ydotool start
  x sudo rc-service bluetooth start
elif [[ ! -z $(dinitctl --version 2>/dev/null) ]]; then
  # Modules loading
  v bash -c "echo i2c-dev | sudo tee -a /etc/modules"
  v bash -c "echo -e '-- Fix user Ydotool not working\nhl.env(\"YDOTOOL_SOCKET\", \"/tmp/.ydotool_socket\")' | tee -a \$HOME/.config/hypr/custom/env.lua"
  v bash -c "echo -e 'type = process\ncommand = /usr/bin/ydotoold\nlogfile = /var/log/dinit/ydotool.log\ndepends-on = dbus\nsmooth-recovery = true' | sudo tee /etc/dinit.d/ydotool"
  
  # Quick check for services to avoid "service already enabled" error"
  # System services
  for srv in userspawn bluetoothd ydotool NetworkManager; do
    if [ -e "/etc/dinit.d/$srv" ] && [ ! -e "/etc/dinit.d/boot.d/$srv" ]; then
      v sudo dinitctl enable "$srv"
    fi
  done

  # User services
  for usrv in pipewire wireplumber pipewire-pulse; do
    if [ ! -e "$HOME/.config/dinit.d/boot.d/$usrv" ]; then
      v dinitctl --user enable "$usrv"
    fi
  done
  
else
  printf "${STY_RED}"
  printf "====================INIT SYSTEM NOT FOUND====================\n"
  printf "${STY_RST}"
  pause
fi

showfun set_default_apps
v set_default_apps
v gsettings set org.gnome.desktop.interface font-name 'Google Sans Medium 11 @opsz=11,wght=500'
v gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
v kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly
