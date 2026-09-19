# This script is meant to be sourced.
# It's not for directly running.
printf "${STY_CYAN}[$0]: 1. Install dependencies\n${STY_RST}"

#####################################################################################

if [[ "$INSTALL_VIA_NIX" == "true" ]]; then

  TARGET_ID=nix
  printf "${STY_YELLOW}"
  printf "===WARNING===\n"
  printf "./sdata/dist-${TARGET_ID}/install-deps.sh will be used.\n"
  printf "The process is still WIP.\n"
  printf "Proceed only at your own risk.\n"
  printf "\n"
  printf "${STY_RST}"
  pause
  source ./sdata/dist-${TARGET_ID}/install-deps.sh

elif [[ "$OS_GROUP_ID" == "arch" ]]; then

  TARGET_ID=arch
  printf "./sdata/dist-${TARGET_ID}/install-deps.sh will be used.\n"
  source ./sdata/dist-${TARGET_ID}/install-deps.sh
fi
