#!/bin/bash

### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

# Create init directory and handle paths
INIT_DIR="$HOME/init"
mkdir -p "$INIT_DIR"
# Define log file path early to capture all output
LOG_FILE="$INIT_DIR/init.log"

# Variable declarations and user input
baseUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles'
hypervisor=$(lscpu | grep -i 'hypervisor vendor' | awk -F ': ' '{print $2}')
sshDir="$HOME/.ssh"
user='debian'
default_ip='192.168.1.100'
default_port='22'

# Start logging everything to the init folder
exec > >(tee -a "$LOG_FILE") 2>&1

echo ">>> Initializing setup in $INIT_DIR <<<"

# Update
sudo apt-get install --fix-broken -y
sudo apt-get update
sudo apt-get upgrade -y

# Directories
mkdir -p \
  ~/dev \
  ~/.npm-global \
  "$sshDir"
chmod 700 "$sshDir"

# apt-get (base tools)
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  bash-completion \
  byobu \
  dconf-cli \
  dconf-editor \
  dos2unix \
  fail2ban \
  fonts-firacode \
  git \
  gnome-tweaks \
  gparted \
  htop \
  jq \
  powertop \
  snapd \
  ufw \
  unzip \
  wireguard \
  xclip

# UFW
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Host-Specific Config
if [[ $hypervisor == *'KVM'* ]]; then
  host='vps1'
  read -p "Enter the port number [Port ${default_port}]: " port
  sudo ufw allow http
  sudo ufw allow https
  sudo ufw allow "${port:-$default_port}/tcp"
  sudo ufw reload

  wget -nc -P "$sshDir" "${baseUrl}/authorized_keys"
  chmod 600 "$sshDir/authorized_keys"

  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
  sudo wget -N -P /etc/ssh "${baseUrl}/sshd_config" -o /dev/null
  sudo sed -i "s/^# Port .*/Port ${port:-$default_port}/" /etc/ssh/sshd_config

  # Caddy (downloaded to init folder)
  wget -P "$INIT_DIR" https://caddyserver.com/download/latest/caddy_amd64.deb
  sudo dpkg -i "$INIT_DIR/caddy_amd64.deb"
  sudo systemctl restart caddy

else
  read -p "Enter VPS IP [${default_ip}]: " vps_ip
  
  wget -nc -P "$sshDir" "${baseUrl}/config"
  wget -nc -P "$sshDir" "${baseUrl}/id_ed25519.pub"
  touch "$sshDir/id_ed25519" "$sshDir/known_hosts"
  chmod 600 "$sshDir/config" "$sshDir/id_ed25519"
  chmod 644 "$sshDir/id_ed25519.pub" "$sshDir/known_hosts"
  
  sudo sed -i "s/<VPS1_IP>/${vps_ip:-${default_ip}}/g" "$sshDir/config"
  sudo sed -i "s/<SSH_PORT>/${port:-${default_port}}/g" "$sshDir/config"
  sudo sed -i "s/<SSH_USER>/${user}/g" "$sshDir/config"

  if ! grep -qi Microsoft /proc/version; then
    host='desktop'
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y chrome-gnome-shell
    echo "deb http://deb.debian.org/debian $(lsb_release -cs) main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/nonfree.list
    
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y firmware-misc-nonfree nvidia-driver
    wget -O "$INIT_DIR/grub" "${baseUrl}/grub"
    sudo cp "$INIT_DIR/grub" /etc/default/grub
    sudo mv /etc/grub.d/30_os-prober /etc/grub.d/09_os-prober
    sudo update-grub

    sudo systemctl enable --now snapd.socket
    sudo snap install steam
  fi
fi

# Change hostname
sudo hostnamectl set-hostname "${host:-wsl}"

# Browsers (Artifacts moved to init folder)
wget -P "$INIT_DIR" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i "$INIT_DIR/google-chrome-stable_current_amd64.deb"

sudo systemctl enable --now snapd.socket
sudo snap install edge

# Text Editors
sudo add-apt-repository ppa:maveonair/helix-editor && sudo apt update && sudo apt install helix
sudo snap install code --classic

# Etcher (Artifacts moved to init folder)
curl -s https://api.github.com/repos/balena-io/etcher/releases/latest | grep -oP '"browser_download_url": "\K[^"]+amd64[^"]*\.deb(?=")' | xargs wget -P "$INIT_DIR"
sudo apt install "$INIT_DIR"/balena-etcher*.deb -y

# NVM + Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts

# NPM global
npm i -g eslint eslint-config-prettier pnpm prettier typescript

# Dotfiles & Config
wget -O ~/.bashrc "${baseUrl}/.bashrc"
wget -O ~/.byobu/.tmux.conf "${baseUrl}/.tmux.conf"
sudo wget -O /usr/share/byobu/keybindings/f-keys.tmux "${baseUrl}/f-keys.tmux"
sudo wget -N -P /etc/caddy "${baseUrl}/Caddyfile" -o /dev/null
wget -O "$INIT_DIR/.dconf" "${baseUrl}/.dconf"
wget -O ~/.gitconfig "${baseUrl}/.gitconfig"
mkdir -p ~/.config/helix && wget -O ~/.config/helix/config.toml "${baseUrl}/config.toml"
wget -O ~/.inputrc "${baseUrl}/.inputrc"
wget -O ~/.npmrc "${baseUrl}/.npmrc"

# Dconf & Extension Sync
dconf load / < "$INIT_DIR/.dconf"

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

# Cleanup artifacts but keep logs and essential configs in init/
rm -f "$INIT_DIR"/*.deb
byobu-enable
sudo apt --fix-broken install -y
sudo systemctl restart ssh
echo ">>> Setup Complete. Logs available in $LOG_FILE <<<"
