#!/bin/bash
GREEN='\033[0;32m'
NOCOLOR='\033[0m'
echo -e "${GREEN}Running SERPENTINE${NOCOLOR}"
system_profiler SPSoftwareDataType SPHardwareDataType
#####################################################
#export HISTIGNORE='*sudo -S*' #make sure we dont save the password in ~/.bash_history
#export HISTIGNORE='*admin_pass*' #make sure we dont save the password in ~/.bash_history
#echo "Enter your local user password:"
#read -r admin_pass
#echo "${admin_pass}" | sudo -S -k <do thing>
#####################################################
installed_apps=$(mdfind "kMDItemKind == 'Application'")
if [[ "$installed_apps" == *"Google Chrome"* ]]; then
    echo -e "${GREEN}Google Chrome was already detected on this system.${NOCOLOR}"
else
    if [ ! -d ~/Downloads/Serpentine/ ]; then
        mkdir ~/Downloads/Serpentine/
    fi
    #install Chrome (checking which version is appropriate for Apple or Intel chipset)
    echo "Downloading and installing Google Chrome..."
    if
                [[ $(arch) == arm64 ]]; then
                echo "Architecture is Apple ARM"
                curl https://dl.google.com/chrome/mac/stable/ --output ~/Downloads/Serpentine/googlechrome.dmg
            else
                echo "Architecture is Intel X86"
                curl https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg --output ~/Downloads/Serpentine/googlechrome.dmg
            fi
    #install chrome from the downloaded .dmg
    yes | hdiutil attach -noverify -nobrowse -mountpoint ~/Downloads/Serpentine/mount ~/Downloads/Serpentine/googlechrome.dmg
    cp -r ~/Downloads/Serpentine/mount/*.app /Applications
    hdiutil detach ~/Downloads/Serpentine/mount
    rm -r ~/Downloads/Serpentine
    open /Applications
fi
echo -e "${GREEN}Chrome Install Complete.${NOCOLOR}"
#####################################################
echo "User's Microsoft Portal opening in Chrome..."
open -a "Google Chrome" https://portal.office.com
#####################################################
echo "Backing up User's dock..."
cp -af  ~/Library/Preferences/com.apple.dock.plist ~/Library/Preferences/com.apple.dock.plist.bak
echo "Clearing user's dock..."
defaults delete com.apple.dock persistent-apps; killall Dock
echo "Opening applications folder..."
open /Applications
