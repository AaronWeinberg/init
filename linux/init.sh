#!/bin/bash

### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

# 1. Init Dir & Logging
INIT_DIR="$HOME/init"
echo ">>> Initializing setup in $INIT_DIR <<<"
mkdir -p "$INIT_DIR"
LOG_FILE="$INIT_DIR/init.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# 2. Variable Declarations & Helpers
apt_install() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

# Base URLs updated for new repo structure
linuxUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/linux/dotfiles'
sharedGitUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/shared/git'
sharedSshUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/shared/ssh'
sharedHelixUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/shared/helix'

host='desktop'
hypervisor=$(lscpu | grep -i 'hypervisor vendor' | awk -F ': ' '{print $2}')
sshDir="$HOME/.ssh"

# 3. Essential Bootstrap
sudo apt-get update

# 4. Core Packages & Dotfiles
apt_install bash-completion byobu ca-certificates curl dos2unix git htop hx wget gpg

# Linux-only dotfiles
wget -O ~/.bashrc        "${linuxUrl}/.bashrc"
wget -O ~/.bash_aliases  "${linuxUrl}/.bash_aliases"
wget -O ~/.eslintrc      "${linuxUrl}/.eslintrc"
wget -O ~/.inputrc       "${linuxUrl}/.inputrc"
wget -O ~/.prettierrc    "${linuxUrl}/.prettierrc"

# Byobu
sudo wget -O /usr/share/byobu/keybindings/f-keys.tmux "${linuxUrl}/f-keys.tmux"
mkdir -p ~/.byobu
wget -O ~/.byobu/.tmux.conf "${linuxUrl}/.tmux.conf"
byobu-enable

# Git (shared)
wget -O ~/.gitconfig "${sharedGitUrl}/.gitconfig"

# Helix (shared)
mkdir -p ~/.config/helix
wget -O ~/.config/helix/config.toml "${sharedHelixUrl}/config.toml"

# 5. Node & NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts

mkdir -p ~/.npm-global
wget -O ~/.npmrc "${linuxUrl}/.npmrc"
npm i -g eslint eslint-config-prettier pnpm prettier typescript

# 6. SSH
mkdir -p "$sshDir"
chmod 700 "$sshDir"

# 7. Host-specific Logic
if [[ $hypervisor == *'KVM'* ]]; then 
    host='vps'
    echo "--- Configuring $host Environment ---"

    default_port=22
    read -p "Enter the VPS port [Port ${default_port}]: " vps_port

    # Caddy Repo
    curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    
    sudo apt-get update
    apt_install caddy fail2ban libnss3-tools ufw

    # SSH & SSHD
    wget -O "$sshDir/authorized_keys" "${sharedSshUrl}/id_ed25519.pub"
    chmod 600 "$sshDir/authorized_keys"

    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sudo wget -N -P /etc/ssh "${linuxUrl}/sshd_config" -o /dev/null
    sudo sed -i "s/^# Port .*/Port ${vps_port:-$default_port}/" /etc/ssh/sshd_config

    # Firewall
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow http
    sudo ufw allow https
    sudo ufw allow "${vps_port:-$default_port}/tcp"
    sudo ufw --force enable

    sudo systemctl restart ssh

else 
    host='wsl'
    echo "--- Configuring desktop/$host Environment ---"

    # Microsoft & Google repos
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

    sudo apt-get update
    apt_install code google-chrome-stable microsoft-edge-stable wireguard xclip

    # Local SSH Config (shared)
    wget -N -P "$sshDir" "${sharedSshUrl}/id_ed25519.pub"
    chmod 644 "$sshDir/id_ed25519.pub"

    if ! grep -qi Microsoft /proc/version; then 
        host='desktop'
        echo "--- Configuring $host Environment ---"

        apt_install dconf-cli dconf-editor fonts-firacode gnome-tweaks gparted jq powertop unzip

        # Firmware & Nvidia
        sudo sed -i '/^deb/ s/\(main\b\)/\1 contrib non-free/g' /etc/apt/sources.list
        [ -f /etc/apt/sources.list.d/nonfree.list ] && sudo rm /etc/apt/sources.list.d/nonfree.list

        apt_install gnome-browser-connector firmware-misc-nonfree nvidia-driver steam

        # Dconf Load
        wget -O "$INIT_DIR/.dconf" "${linuxUrl}/.dconf"
        if [ -f "$INIT_DIR/.dconf" ]; then
            dbus-run-session -- dconf load / < "$INIT_DIR/.dconf"
        fi

        # GNOME Extensions Sync (unchanged)
        # ...
    fi
fi

# 8. Hostname & Cleanup
sudo hostnamectl set-hostname "$host"
sudo apt-get autoremove -y

echo ""
echo "################################################"
echo "   SETUP COMPLETE!"
echo "################################################"
echo " Hostname:    $(hostname)"
echo " Setup Log:   $LOG_FILE"
echo ""
