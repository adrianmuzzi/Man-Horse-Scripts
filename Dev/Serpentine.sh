#!/bin/bash
GREEN='\033[0;32m'
NOCOLOR='\033[0m'
echo -e "${GREEN}Running SERPENTINE${NOCOLOR}"
#install Chrome (checking which version is appropriate for Apple or Intel chipset)
  if
            [[ $(arch) == arm64 ]]; then
            echo "Architecture is Apple ARM"
            curl https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg --output googlechrome.dmg
        else
            echo "Architecture is Intel X86"
            curl https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg --output googlechrome.dmg
        fi