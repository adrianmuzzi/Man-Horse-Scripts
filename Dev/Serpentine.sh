#!/bin/bash
GREEN='\033[0;32m'
NOCOLOR='\033[0m'
echo -e "${GREEN}Running SERPENTINE${NOCOLOR}"
export HISTIGNORE='*sudo -S*' #make sure we dont save the password in ~/.bash_history
export HISTIGNORE='*admin_pass*' #make sure we dont save the password in ~/.bash_history
read -p "Enter local admin password:" admin_pass

#export HISTIGNORE='*sudo -S*' #make sure we dont save the password in ~/.bash_history
if open -Ra "/Applications/Google Chrome.app"; then
    echo "Google Chrome is already installed on this Mac"
else
    echo "Downloading and installing Google Chrome..."
    #install Chrome (checking which version is appropriate for Apple or Intel chipset)
    if
                [[ $(arch) == arm64 ]]; then
                echo "Architecture is Apple ARM"
                curl https://dl.google.com/chrome/mac/stable/ --output ~/Downloads/Serpentine/googlechrome.dmg
            else
                echo "Architecture is Intel X86"
                curl https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg --output ~/Downloads/Serpentine/googlechrome.dmg
            fi

    open ~/Downloads/Serpentine/googlechrome.dmg
    echo admin_pass | sudo -S -k cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
    open /Applications
fi
echo "Chrome install complete."