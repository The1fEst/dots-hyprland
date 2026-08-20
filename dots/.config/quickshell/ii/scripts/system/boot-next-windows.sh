#!/usr/bin/env bash
# Arm a one-shot UEFI BootNext pointing at the Windows Boot Manager.
# The firmware clears BootNext itself on the next boot, so a failed Windows
# boot falls back to the normal BootOrder (Linux) instead of getting stuck.
#
# Reading the boot list works unprivileged; only the write needs root, so that
# single call goes through pkexec and the shell's polkit agent asks for the
# password. Nothing to install, and nothing runs as root except efibootmgr.

set -euo pipefail

num=$(efibootmgr | grep -m1 -oP '^Boot\K[0-9A-Fa-f]{4}(?=\*?\s+Windows Boot Manager(\s|$))') || {
    echo "boot-next-windows: no 'Windows Boot Manager' entry in the UEFI boot list" >&2
    exit 1
}

pkexec efibootmgr --bootnext "$num" >/dev/null
echo "boot-next-windows: BootNext set to Boot$num (Windows Boot Manager)"
