#!/bin/bash

### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

# Variable declarations and user input
baseUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles' # location of dotfiles and other config files on github
output=$(sudo dmidecode -s system-manufacturer) # Get the system manufacturer
sshDir='~/.ssh' # SSH directory
default_ip='192.168.1.100' # Default IP for VPS
default_port='22' # Default SSH port
read -p "Enter the port number you want to use for ssh, or hit enter to accept the default [Port ${default_port}]: " port # Prompt for the SSH port number
read -p "If on a local machine, enter the IP of your VPS, or hit enter to accept the default [${default_ip}]: " vps_ip # Prompt for the VPS IP
read -p "If on a local machine, enter your private SSH key, or hit enter to leave empty: " private_ssh_key # Prompt for the private SSH key

# Update
sudo apt --fix-broken install -y
sudo apt update
sudo apt upgrade -y

# Directories
mkdir -p \
  ~/dev \
  ~/.npm-global
  mkdir -p ${sshDir}
  chmod 700 ${sshDir}

# UFW
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Host-Specific Config
if [[ $output == *'OpenStack Foundation'* ]]; then
  echo 'VPS SCRIPT'

  host='VPS1'

  # Allow HTTP, HTTPS, and SSH
  sudo ufw allow http
  sudo ufw allow https
  sudo ufw allow ${port}/tcp

  # SSH Config
  wget -nc -P ${sshDir} ${baseUrl}/authorized_keys
  chmod 600 ${sshDir}/authorized_keys

  # SSHD Config
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak # Backup the original sshd_config file
  sudo wget -N -P /etc/ssh ${baseUrl}/sshd_config -o /dev/null # Fetch new sshd_config file
  sudo sed -i "s/^# Port .*/Port ${port}/" /etc/ssh/sshd_config # Add or update the Port line in sshd_config

  # Caddy Webserver
  wget https://caddyserver.com/download/latest/caddy_amd64.deb
  sudo dpkg -i caddy_amd64.deb
  rm -rf caddy_amd64.deb
  sudo systemctl restart caddy

else
  echo 'LOCAL MACHINE SCRIPT'
  
  # SSH Config
  wget -nc -P ${sshDir} ${baseUrl}/config
  wget -nc -P ${sshDir} ${baseUrl}/id_ed25519.pub
  touch ${sshDir}/id_ed25519
  touch ${sshDir}/known_hosts
  chmod 600 ${sshDir}/config
  chmod 600 ${sshDir}/id_ed25519
  chmod 644 ${sshDir}/id_ed25519.pub
  chmod 644 ${sshDir}/known_hosts
  sudo sed -i "s/<VPS1_IP>/${vps_ip:-${default_ip}}/g" ${sshDir}/config # Fill in the VPS's IP
  sudo sed -i "s/<SSH_PORT>/${port:-${default_port}}/g" ${sshDir}/config # Fill in the SSH port
  sudo sed -i "s/<SSH_PORT>/${private_ssh_key}/g" ${sshDir}/id_ed25519 # Fill in private SSH key

  # Desktop Linux Config
  if ! grep -qi Microsoft /proc/version; then
    host='Desktop'

    # Grub
    wget -O /etc/default/grub ${baseUrl}/grub
    sudo mv /etc/grub.d/30_os-prober /etc/grub.d/09_os-prober
    sudo update-grub

    # Steam
    wget https://cdn.akamai.steamstatic.com/client/installer/steam.deb
    sudo dpkg -i steam.deb
    sudo apt --fix-broken install
    sudo rm -rf steam.deb
  fi
fi

echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections # Microsoft Fonts
sudo add-apt-repository ppa:maveonair/helix-editor

# Change hostname
host=${host:-WSL} # Set host to 'WSL' if it was not set above
sudo hostnamectl set-hostname ${host} # Change to host-specific hostname

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm -rf google-chrome-stable_current_amd64.deb

# Edge
wget https://packages.microsoft.com/keys/microsoft.asc
wget https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_current_amd64.deb
gpg --dearmor < microsoft.asc | sudo tee /usr/share/keyrings/microsoft-edge.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list

# Apt
sudo apt install -y \
  chrome-gnome-shell \
  byobu \
  dconf-cli \
  dconf-editor \
  dos2unix \
  ./microsoft-edge-stable_current_amd64.deb \
  fail2ban \
  fonts-firacode \
  gnome-tweaks \
  gparted \
  helix \
  htop \
  powertop \
  ttf-mscorefonts-installer \
  wireguard \
  xclip

# NVM + Node + NPM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
nvm install --lts # Install the latest LTS version of Node.js

# NPM global packages
npm i -g \
  eslint \
  eslint-config-prettier \
  pnpm \
  prettier \
  typescript

# Dotfiles
wget -O ~/.bashrc ${baseUrl}/.bashrc
wget -O ~/.byobu/.tmux.conf ${baseUrl}/.tmux.conf
sudo wget -O /usr/share/boybu/keybindings/f-keys.tmux ${baseUrl}/f-keys.tmux
sudo wget -N -P /etc/caddy ${baseUrl}/Caddyfile -o /dev/null # Use my Caddyfile
wget -O ~/.dconf ${baseUrl}/.dconf
wget -O ~/.gitconfig ${baseUrl}/.gitconfig
wget -O ~/.config/helix/config.toml ${baseUrl}/config.toml
wget -O ~/.inputrc ${baseUrl}/.inputrc
wget -O ~/.npmrc ${baseUrl}/.npmrc

# Dconf  
dconf load / < ~/.dconf
rm ~/.dconf

byobu-enable # set Byobu as default terminal
