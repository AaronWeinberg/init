#!/bin/bash

### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

# 1. Init Dir & Logging
INIT_DIR="$HOME/init"
mkdir -p "$INIT_DIR"
LOG_FILE="$INIT_DIR/init.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# 2. Variable Declarations & Helpers
apt_install() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}
baseUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles'
hypervisor=$(lscpu | grep -i 'hypervisor vendor' | awk -F ': ' '{print $2}')
sshDir="$HOME/.ssh"
user='debian'
default_ip='192.168.1.100'
default_port='22'

echo ">>> Initializing setup in $INIT_DIR <<<"
read -p "Enter VPS port [Port ${default_port}]: " vps_port
read -p "Enter VPS IP [${default_ip}]: " vps_ip

# 3. Essential Bootstrap
sudo apt-get update
sudo apt-get install --fix-broken -y
sudo apt-get upgrade -y

# 4. Standard Directories
mkdir -p ~/dev ~/.npm-global "$sshDir"
chmod 700 "$sshDir"

# 5. Core Packages & Dotfiles
apt_install bash-completion byobu ca-certificates curl dos2unix git htop hx wget gpg

wget -O ~/.bashrc "${baseUrl}/.bashrc"
wget -O ~/.inputrc "${baseUrl}/.inputrc"

# Byobu Config
sudo wget -O /usr/share/byobu/keybindings/f-keys.tmux "${baseUrl}/f-keys.tmux"
mkdir -p ~/.byobu
wget -O ~/.byobu/.tmux.conf "${baseUrl}/.tmux.conf"
byobu-enable

# Git & Helix Config
wget -O ~/.gitconfig "${baseUrl}/.gitconfig"
mkdir -p ~/.config/helix
wget -O ~/.config/helix/config.toml "${baseUrl}/config.toml"

# 6. Node & NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
wget -O ~/.npmrc "${baseUrl}/.npmrc"
npm i -g eslint eslint-config-prettier pnpm prettier typescript

# 7. Shared SSH Keys (Private key needs manual paste later)
wget -nc -P "$sshDir" "${baseUrl}/id_ed25519.pub"
touch "$sshDir/id_ed25519" "$sshDir/known_hosts"
chmod 600 "$sshDir/id_ed25519"
chmod 644 "$sshDir/id_ed25519.pub" "$sshDir/known_hosts"

# 8. Host-specific Logic
if [[ $hypervisor == *'KVM'* ]]; then 
    echo "--- Configuring VPS Environment ---"
    host='vps1'

    # Caddy Repo
    curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    
    sudo apt-get update
    apt_install caddy fail2ban libnss3-tools ufw

    # SSH & SSHD
    wget -nc -P "$sshDir" "${baseUrl}/authorized_keys"
    chmod 600 "$sshDir/authorized_keys"
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sudo wget -N -P /etc/ssh "${baseUrl}/sshd_config" -o /dev/null
    sudo sed -i "s/^# Port .*/Port ${vps_port:-$default_port}/" /etc/ssh/sshd_config

    # Firewall
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow http
    sudo ufw allow https
    sudo ufw allow "${vps_port:-$default_port}/tcp"
    sudo ufw --force enable

else 
    echo "--- Configuring Desktop/WSL (Snap-Free/Repo-First) ---"
    
    # Add Microsoft (Code/Edge) and Google (Chrome) Keys/Repos
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

    sudo apt-get update
    apt_install code microsoft-edge-stable google-chrome-stable wireguard xclip

    # Local SSH Config
    wget -nc -P "$sshDir" "${baseUrl}/config"
    sed -i "s/<VPS1_IP>/${vps_ip:-${default_ip}}/g" "$sshDir/config"
    sed -i "s/<SSH_PORT>/${vps_port:-${default_port}}/g" "$sshDir/config"
    sed -i "s/<SSH_USER>/${user}/g" "$sshDir/config"

    if ! grep -qi Microsoft /proc/version; then 
        echo "--- Configuring Physical Desktop Tweaks ---"
        host='desktop'

        apt_install fonts-firacode gnome-tweaks gparted powertop dconf-cli dconf-editor jq unzip

        # Dconf Load
        wget -O "$INIT_DIR/.dconf" "${baseUrl}/.dconf"
        dconf load / < "$INIT_DIR/.dconf"

        # GNOME Extensions
        if command -v gnome-shell &> /dev/null; then
            GNOME_VER=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)
            EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
            LIST_FILE="$HOME/dev/extensions.list"
            mkdir -p "$EXT_DIR"
            if [ -f "$LIST_FILE" ]; then
                while IFS= read -r uuid || [ -n "$uuid" ]; do
                    [ -z "$uuid" ] && continue
                    if [ ! -d "$EXT_DIR/$uuid" ]; then
                        DOWNLOAD_URL=$(curl -s "https://extensions.gnome.org/extension-query/?search=$uuid" | jq -r ".extensions[] | select(.uuid==\"$uuid\") | .shell_version_map[\"$GNOME_VER\"].pk")
                        if [ "$DOWNLOAD_URL" != "null" ]; then
                            wget -q -O "/tmp/$uuid.zip" "https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_pk=$DOWNLOAD_URL"
                            mkdir -p "$EXT_DIR/$uuid"
                            unzip -o "/tmp/$uuid.zip" -d "$EXT_DIR/$uuid" > /dev/null
                        fi
                    fi
                done < "$LIST_FILE"
                CLEAN_LIST=$(awk '{printf "'\''%s'\'', ", $0}' "$LIST_FILE" | sed 's/, $//')
                gsettings set org.gnome.shell enabled-extensions "[$CLEAN_LIST]"
            fi
        fi

        # Etcher (Standalone repo logic is complex for Etcher, keeping wget for simplicity)
        curl -s https://api.github.com/repos/balena-io/etcher/releases/latest | grep -oP '"browser_download_url": "\K[^"]+amd64[^"]*\.deb(?=")' | xargs wget -P "$INIT_DIR"
        sudo apt install "$INIT_DIR"/balena-etcher*.deb -y || sudo apt-get install -f -y
        
        # Firmware & Nvidia Repo Setup
        echo "deb http://deb.debian.org/debian $(lsb_release -cs) main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/nonfree.list
        sudo apt-get update
        apt_install chrome-gnome-shell firmware-misc-nonfree nvidia-driver

        # Grub
        wget -O "$INIT_DIR/grub" "${baseUrl}/grub"
        sudo cp "$INIT_DIR/grub" /etc/default/grub
        sudo mv /etc/grub.d/30_os-prober /etc/grub.d/09_os-prober
        sudo update-grub

        # Steam
        sudo dpkg --add-architecture i386
        sudo apt-get update
        apt_install steam-installer
    fi
fi

# 9. Hostname & Cleanup
sudo hostnamectl set-hostname "${host:-wsl}"
sudo apt-get purge -y snapd
sudo apt-get autoremove -y
sudo systemctl restart ssh
rm -rf "$INIT_DIR"/*.deb

# --- FINAL SUMMARY ---
echo ""
echo "################################################"
echo "   SETUP COMPLETE!                              "
echo "################################################"
echo " Hostname:    $(hostname)"
echo " Setup Log:   $LOG_FILE"
echo ""
if [[ $hypervisor == *'KVM'* ]]; then
    PUBLIC_IP=$(curl -s https://ifconfig.me)
    echo " VPS ACCESS DETAILS:"
    echo " IP Address:  $PUBLIC_IP"
    echo " SSH Port:    ${vps_port:-$default_port}"
    echo " Connection:  ssh $user@$PUBLIC_IP -p ${vps_port:-$default_port}"
    echo ""
    echo " ALERT: Test SSH in a NEW terminal before closing!"
else
    echo " LOCAL ENVIRONMENT READY"
    echo " Snap has been purged and replaced with DEB repos."
    echo " SSH Config updated for VPS at: ${vps_ip:-$default_ip}"
fi
echo "################################################"
