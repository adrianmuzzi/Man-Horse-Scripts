#!/bin/bash
GREEN='\033[0;32m'
NOCOLOR='\033[0m'
echo -e "${GREEN}Running SERPENTINE${NOCOLOR}"
system_profiler SPSoftwareDataType SPHardwareDataType
#####################################################
echo "Backing up User's dock..."
cp -af  ~/Library/Preferences/com.apple.dock.plist ~/Library/Preferences/com.apple.dock.plist.bak
echo "Clearing user's dock..."
defaults delete com.apple.dock persistent-apps; killall Dock
echo "Opening applications folder..."
open /Applications
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
    # Download the latest version of Google Chrome
    curl -O https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
    # Mount the downloaded DMG file
    hdiutil attach googlechrome.dmg
    # Install Google Chrome
    sudo cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications
    # Unmount the DMG file
    hdiutil detach /Volumes/Google\ Chrome
    # Remove the DMG file
    rm googlechrome.dmg
fi
echo -e "${GREEN}Chrome Install Complete.${NOCOLOR}"
#####################################################
echo "User's Microsoft Portal opening in Chrome..."
open -a "Google Chrome" https://portal.office.com
#####################################################