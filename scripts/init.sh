#!/bin/bash

### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

baseUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles'

# Prompt for the SSH port number
read -p 'Enter the port number you want to use for ssh: ' port

sudo apt --fix-broken install -y
sudo apt update
sudo apt upgrade -y

# Directories
mkdir -p \
  ~/dev \
  ~/.npm-global

# Apt
sudo apt install -y \
  byobu \
  chrome-gnome-shell \
  dconf-cli \
  dconf-editor \
  dos2unix \
  fail2ban \
  fonts-firacode \
  gnome-tweaks \
  gparted \
  htop \
  npm \
  powertop \
  wireguard

# Snap
sudo snap install code --classic
sudo snap install gimp

# NVM + Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash # Install NVM
export NVM_DIR="$HOME/.nvm" # Load NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # loads nvm 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # loads nvm bash_completion
nvm install --lts # Install the latest LTS version of Node.js

# NPM Packages
sudo npm i -g \
  eslint \
  eslint-config-prettier \
  pnpm \
  prettier \
  typescript

# Dotfiles
wget -P ~ ${baseUrl}/.bashrc
wget -P ~ ${baseUrl}/.gitconfig
wget -P ~ ${baseUrl}/.inputrc
wget -P ~ ${baseUrl}/.nanorc

# SSH
sshDir='~/.ssh'
mkdir -p ${sshDir}
chmod 700 ${sshDir}

# Helix
sudo snap install helix --classic
wget -P ~/.config/helix ${baseUrl}/config.toml

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm -rf google-chrome-stable_current_amd64.deb

# Edge
wget https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_current_amd64.deb
sudo dpkg -i microsoft-edge-stable_current_amd64.deb
rm -rf microsoft-edge-stable_current_amd64.deb

# Dconf
wget -P ~ ${baseUrl}/.dconf
dconf load / < ~/.dconf
rm ~/.dconf

# Byobu
byobu-enable # set Byobu as default terminal
wget -P ~/.byobu ${baseUrl}/.tmux.conf

# UFW
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Host-Specific
output=$(sudo dmidecode -s system-manufacturer)

if [[ $output == *'OpenStack Foundation'* ]]; then
  echo 'VPS SCRIPT'

  host='vps1'

  # Allow HTTP, HTTPS, and SSH
  sudo ufw allow http
  sudo ufw allow https
  sudo ufw allow ${port}/tcp

  # SSH Config
  wget -nc -P ${sshDir} ${baseUrl}/authorized_keys
  chmod 600 ${sshDir}/authorized_keys

  # SSHD Config
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak # Backup the original sshd_config file
  wget -N -P /etc/ssh ${baseUrl}/sshd_config # Fetch new sshd_config file
  sudo sed -i "/^#Port /c\Port ${port}" /etc/ssh/sshd_config # Add or update the Port line in sshd_config

  # Caddy Webserver
  wget https://caddyserver.com/download/latest/caddy_amd64.deb
  sudo dpkg -i caddy_amd64.deb
  rm -rf caddy_amd64.deb
  wget -N -P /etc/caddy ${baseUrl}/Caddyfile # Use my Caddyfile
  sudo systemctl restart caddy

else
  echo 'LOCAL MACHINE SCRIPT'
  
  # SSH Config
  wget -nc -P ${sshDir} ${baseUrl}/config
  wget -nc -P ${sshDir} ${baseUrl}/id_ed25519.pub
  touch ${sshDir}/id_ed25519
  touch ${sshDir}/known_hosts
  chmod 600 ${sshDir}/id_ed25519
  chmod 644 ${sshDir}/id_ed25519.pub
  chmod 644 ${sshDir}/known_hosts

  # Desktop Linux Config
  if ! grep -qi Microsoft /proc/version; then
    host='ubuntu'

    # Grub
    if ! grep -qi Microsoft /proc/version; then
      wget -P /etc/default ${baseUrl}/grub
      sudo mv /etc/grub.d/30_os-prober /etc/grub.d/09_os-prober
      sudo update-grub
    fi
  fi
fi

host=${host:-wsl} # Set host to 'wsl' if it was not set above
sudo hostnamectl set-hostname ${host} # Change to host-specific hostname

# Cleanup
rm -rf \
  ~/Documents \
  ~/Music \
  ~/Pictures \
  ~/Templates \
  ~/Videos

sudo apt purge -y \
  apport \
  kerneloops \
  ubuntu-report \
  whoopsie

sudo apt autoremove -y # Remove superfluous packages

source ~/.bashrc # Reload .bashrc file
