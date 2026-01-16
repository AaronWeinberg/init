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

# 4. Core Packages & Dotfiles
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

# 5. Node & NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
mkdir -p ~/.npm-global
wget -O ~/.npmrc "${baseUrl}/.npmrc"
npm i -g eslint eslint-config-prettier pnpm prettier typescript

# 6. Shared SSH Keys (Private key needs manual paste later)
mkdir -p "$sshDir"
chmod 700 "$sshDir"

# 7. Host-specific Logic
if [[ $hypervisor == *'KVM'* ]]; then 
    echo "--- Configuring VPS Environment ---"
    host='vps1'

    # Caddy Repo
    curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    
    sudo apt-get update
    apt_install caddy fail2ban libnss3-tools ufw

    # SSH & SSHD
    wget -N -P "$sshDir" "${baseUrl}/authorized_keys"
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

    # Restart SSHD after config & firewall changes
    sudo systemctl restart ssh

else 
    echo "--- Configuring Desktop/WSL (Snap-Free/Repo-First) ---"
    
    # Add Microsoft (Code/Edge) and Google (Chrome) Keys/Repos
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

    sudo apt-get update
    apt_install code google-chrome-stable microsoft-edge-stable wireguard xclip

    # Local SSH Config
    config="$sshDir/config"
    pub="$sshDir/id_ed25519.pub"
    wget -N -P "$sshDir" "${baseUrl}/id_ed25519.pub"
    wget -N -P "$sshDir" "${baseUrl}/config"
    chmod 644 "$pub"
    chmod 600 "$config"
    sed -i "s/<VPS1_IP>/${vps_ip:-${default_ip}}/g" "$config"
    sed -i "s/<SSH_PORT>/${vps_port:-${default_port}}/g" "$config"
    sed -i "s/<SSH_USER>/${user}/g" "$config"

    if ! grep -qi Microsoft /proc/version; then 
        # --- Configuring Physical Desktop Tweaks ---
        host='desktop'

        apt_install fonts-firacode gnome-tweaks gparted powertop dconf-cli dconf-editor jq unzip

        # Dconf Load (Wrapped in DBus session)
        # 1. Load your previous Dconf settings
        wget -O "$INIT_DIR/.dconf" "${baseUrl}/.dconf"
        if [ -f "$INIT_DIR/.dconf" ]; then
            dbus-run-session -- dconf load / < "$INIT_DIR/.dconf"
        fi
        
        # 2. Reinstall Extensions based on the Dconf we just loaded
        if command -v gnome-shell &> /dev/null; then
            echo "--- Synchronizing GNOME Extensions from Dconf ---"
            
            # Extract list and turn into a clean bash-iterable list
            EXT_LIST=$(dbus-run-session -- gsettings get org.gnome.shell enabled-extensions | tr -d "[]'," | tr ' ' '\n')
        
            GNOME_VER=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)
            EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
            mkdir -p "$EXT_DIR"
        
            for uuid in $EXT_LIST; do
                [ -z "$uuid" ] && continue
                
                # Skip system-level extensions
                [[ "$uuid" == *"ubuntu.com"* || "$uuid" == *"fedora"* ]] && continue
        
                if [ ! -d "$EXT_DIR/$uuid" ]; then
                    echo "Attempting to sync: $uuid"
                    
                    # Query API: Try current version, fallback to N-1, then N-2 (GNOME 46)
                    # Many older extensions work fine on 48 if we grab the v46/47 build
                    PK=$(curl -s "https://extensions.gnome.org/extension-query/?search=$uuid" | \
                         jq -r ".extensions[] | select(.uuid==\"$uuid\") | 
                         (.shell_version_map[\"$GNOME_VER\"].pk // 
                          .shell_version_map[\"$((GNOME_VER-1))\"].pk // 
                          .shell_version_map[\"$((GNOME_VER-2))\"].pk)")
                    
                    if [ "$PK" != "null" ] && [ -n "$PK" ]; then
                        DL_URL="https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_pk=$PK"
                        
                        # User-Agent is required to prevent 403 Forbidden/Empty zip errors
                        wget -q --user-agent="Mozilla/5.0" -O "/tmp/$uuid.zip" "$DL_URL"
                        
                        # Check if it's a valid zip before extraction
                        if file "/tmp/$uuid.zip" | grep -q "Zip archive data"; then
                            mkdir -p "$EXT_DIR/$uuid"
                            unzip -o "/tmp/$uuid.zip" -d "$EXT_DIR/$uuid" > /dev/null
                            echo " [+] Installed $uuid"
                        else
                            echo " [!] Failed: $uuid (Downloaded file was not a valid ZIP)"
                        fi
                        rm -f "/tmp/$uuid.zip"
                    else
                        echo " [-] Skipped: $uuid (No compatible version found for GNOME $GNOME_VER, 47, or 46)"
                    fi
                fi
            done
        
            # 3. FORCE COMPATIBILITY
            # This disables version checking so extensions that "think" they only work on 47 will run on 48
            dbus-run-session -- gsettings set org.gnome.shell disable-extension-version-validation true
            echo "--- Extension sync complete. Version validation disabled. ---"
        fi

        # --- Firmware & Nvidia Repo Setup ---
        echo "--- Cleaning up APT sources and enabling Non-Free ---"
        
        # 1. Fix the main sources.list to include contrib, non-free, and non-free-firmware
        # This handles the Trixie 'main non-free-firmware' default correctly
        sudo sed -i '/^deb/ s/\(main\b\)/\1 contrib non-free/g' /etc/apt/sources.list
        
        # 2. Delete the duplicate file that was causing errors
        if [ -f /etc/apt/sources.list.d/nonfree.list ]; then
            sudo rm /etc/apt/sources.list.d/nonfree.list
        fi

        sudo apt-get update

        # 3. Install the packages (using the new name for the chrome-gnome-shell connector)
        echo "--- Installing Drivers and GNOME Connector ---"
        apt_install gnome-browser-connector firmware-misc-nonfree nvidia-driver

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

# 8. Hostname & Cleanup
sudo hostnamectl set-hostname "${host:-wsl}"
sudo apt-get purge -y snapd
sudo apt-get autoremove -y
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
