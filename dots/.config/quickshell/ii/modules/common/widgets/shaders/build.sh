#!/usr/bin/env bash
set -euo pipefail

qsb_bin="$(command -v qsb || echo /usr/lib/qt6/bin/qsb)"
cd "$(dirname "$0")"

for shader in *.frag *.vert; do
    [ -e "$shader" ] || continue
    "$qsb_bin" --qt6 -o "$shader.qsb" "$shader"
    echo "built $shader.qsb"
done
