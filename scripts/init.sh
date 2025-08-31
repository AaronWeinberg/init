#!/bin/bash

### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

# Variable declarations and user input
baseUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles' # location of dotfiles and other config files on github
hypervisor=$(lscpu | grep -i 'hypervisor vendor' | awk -F ': ' '{print $2}') # host of linux installation
sshDir='~/.ssh' # SSH directory
user='debian'
default_ip='192.168.1.100' # Default IP for VPS
default_port='22' # Default SSH port

# Update
sudo apt-get install --fix-broken -y
sudo apt-get update
sudo apt-get upgrade -y

# Directories
mkdir -p \
  ~/dev \
  ~/.npm-global \
  ${sshDir}
chmod 700 ${sshDir}

# apt-get (base tools)
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  bash-completion \
  byobu \
  dconf-cli \
  dconf-editor \
  dos2unix \
  fail2ban \
  fonts-firacode \
  gnome-tweaks \
  gparted \
  htop \
  powertop \
  snapd \
  ufw \
  wireguard \
  xclip

# UFW
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Host-Specific Config
echo '>>> START HOST-SPECIFIC SCRIPTS <<<'
if [[ $hypervisor == *'KVM'* ]]; then
  echo '>>> VPS SCRIPT <<<'

  host='vps1'

  read -p "Enter the port number you want to use for ssh, or hit enter to accept the default [Port ${default_port}]: " port # Prompt for the SSH port number

  # Allow HTTP, HTTPS, and SSH
  sudo ufw allow http
  sudo ufw allow https
  sudo ufw allow ${port}/tcp
  sudo ufw reload

  # SSH Config
  wget -nc -P ${sshDir} ${baseUrl}/authorized_keys
  chmod 600 ${sshDir}/authorized_keys

  # SSHD Config
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak # Backup the original sshd_config file
  sudo wget -N -P /etc/ssh ${baseUrl}/sshd_config -o /dev/null # Fetch new sshd_config file
  sudo sed -i "s/^# Port .*/Port ${port}/" /etc/ssh/sshd_config # Add or update the Port line in sshd_config

  # Caddy Webserver (no snap version, keep deb)
  wget https://caddyserver.com/download/latest/caddy_amd64.deb
  sudo dpkg -i caddy_amd64.deb
  rm -rf caddy_amd64.deb
  sudo systemctl restart caddy

  # Disable Password Login
  sudo rm /etc/ssh/sshd_config.d/50-cloud-init.conf

else
  echo '>>> LOCAL MACHINE SCRIPT <<<'

  read -p "If on a local machine, enter the IP of your VPS, or hit enter to accept the default [${default_ip}]: " vps_ip # Prompt for the VPS IP
  
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
  sudo sed -i "s/<SSH_USER>/${user}/g" ${sshDir}/config # Fill in the user

  # Desktop Linux Config
  if ! grep -qi Microsoft /proc/version; then
    host='desktop'

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y chrome-gnome-shell

    # NVIDIA Drivers (via Debian repos)
    # Adds contrib + non-free repos, installs NVIDIA drivers
    # Future updates come automatically with apt upgrade
    echo "deb http://deb.debian.org/debian $(lsb_release -cs) main contrib non-free non-free-firmware" | \
      sudo tee /etc/apt/sources.list.d/nonfree.list
    # (Optional: enable backports for newer GPUs)
    echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main contrib non-free non-free-firmware" | \
      sudo tee /etc/apt/sources.list.d/backports.list

    # apt-get (base tools)
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
      firmware-misc-nonfree \
      nvidia-driver
    
    # Grub
    wget -O /etc/default/grub ${baseUrl}/grub
    sudo mv /etc/grub.d/30_os-prober /etc/grub.d/09_os-prober
    sudo update-grub

    sudo snap install steam # Steam
  fi
fi
echo '>>> END HOST-SPECIFIC SCRIPTS <<<'

# Change hostname
host=${host:-wsl} # Set host to 'wsl' if it was not set above
sudo hostnamectl set-hostname ${host} # Change to host-specific hostname

# Browsers
  ### Chrome
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb
  rm -rf google-chrome-stable_current_amd64.deb

  sudo snap install edge # Edge
  sudo snap install firefox # Firefox

# Text Editors
sudo snap install helix --classic # Helix
sudo snap install code --classic  # VSCode

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
sudo wget -O /usr/share/byobu/keybindings/f-keys.tmux ${baseUrl}/f-keys.tmux
sudo wget -N -P /etc/caddy ${baseUrl}/Caddyfile -o /dev/null
wget -O ~/.dconf ${baseUrl}/.dconf
wget -O ~/.gitconfig ${baseUrl}/.gitconfig
wget -O ~/.config/helix/config.toml ${baseUrl}/config.toml
wget -O ~/.inputrc ${baseUrl}/.inputrc
wget -O ~/.npmrc ${baseUrl}/.npmrc

# Dconf  
dconf load / < ~/.dconf
rm ~/.dconf

byobu-enable # set Byobu as default terminal
sudo apt --fix-broken install -y
sudo systemctl restart ssh # restart ssh client to apply changes
