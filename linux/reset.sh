#!/bin/bash

### ### ### ### ### ### ###
#   Linux Reset / Uninstall
### ### ### ### ### ### ###

INIT_DIR="$HOME/init"
mkdir -p "$INIT_DIR"

LOG_FILE="$INIT_DIR/reset.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo ">>> Starting Linux reset. Log: $LOG_FILE"

sshDir="$HOME/.ssh"

#############################################
# 1. Remove Packages Installed by init.sh
#############################################

echo "--- Removing packages installed by init.sh ---"

sudo apt-get remove -y \
    bash-completion \
    byobu \
    curl \
    dos2unix \
    git \
    htop \
    hx \
    wget \
    gpg \
    code \
    google-chrome-stable \
    microsoft-edge-stable \
    wireguard \
    xclip \
    dconf-cli \
    dconf-editor \
    fonts-firacode \
    gnome-tweaks \
    gparted \
    jq \
    powertop \
    unzip \
    firmware-misc-nonfree \
    nvidia-driver \
    steam-installer

sudo apt-get autoremove -y

#############################################
# 2. Remove Dotfiles Installed by init.sh
#############################################

echo "--- Removing dotfiles ---"

rm -f ~/.bashrc
rm -f ~/.bash_aliases
rm -f ~/.eslintrc
rm -f ~/.inputrc
rm -f ~/.prettierrc
rm -f ~/.npmrc
rm -f ~/.gitconfig

rm -rf ~/.byobu
rm -rf ~/.config/helix
rm -rf ~/.npm-global

#############################################
# 3. Remove SSH Keys / Config Installed
#############################################

echo "--- Removing SSH files ---"

rm -f "$sshDir/id_ed25519.pub"
rm -f "$sshDir/authorized_keys"

#############################################
# 4. Restore SSHD Config (VPS case)
#############################################

if [ -f /etc/ssh/sshd_config.bak ]; then
    echo "--- Restoring SSHD config backup ---"
    sudo mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
    sudo systemctl restart ssh
fi

#############################################
# 5. Restore GNOME Settings (Desktop case)
#############################################

if command -v gsettings &>/dev/null; then
    echo "--- Resetting GNOME settings to defaults ---"
    dbus-run-session -- dconf reset -f /
fi

#############################################
# 6. Remove GNOME Extensions Installed
#############################################

EXT_DIR="$HOME/.local/share/gnome-shell/extensions"

if [ -d "$EXT_DIR" ]; then
    echo "--- Removing GNOME extensions ---"
    rm -rf "$EXT_DIR"
fi

#############################################
# 7. Remove NVM and Node
#############################################

echo "--- Removing NVM and Node ---"

rm -rf "$HOME/.nvm"
rm -rf "$HOME/.npm"
rm -rf "$HOME/.cache/node-gyp"

#############################################
# 8. Remove Init Directory (optional)
#############################################

# echo "--- Removing init directory ---"
# rm -rf "$HOME/init"

#############################################
# 9. Final Summary
#############################################

echo ""
echo "################################################"
echo "   LINUX RESET COMPLETE"
echo "   Log File: $LOG_FILE"
echo "################################################"
echo ""
