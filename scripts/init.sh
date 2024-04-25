#!/bin/bash

### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

baseUrl='https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles';

sudo apt-get --fix-broken install -y;
sudo apt-get update;
sudo apt-get upgrade -y;


# Directories #
mkdir -p ~/development; # dev path
mkdir -p ~/.npm-global;


# Apps #
## apt
sudo apt-get install -y byobu;
sudo apt-get install -y curl;
sudo apt-get install -y git;
sudo apt-get install -y npm;

## snap
sudo snap install helix --classic

## nvm + node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash 
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # loads nvm 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # loads nvm bash_completion
nvm install node; # installs LTS version of node

## npm
npm i -g eslint;
npm i -g eslint-config-prettier;
npm i -g pnpm
npm i -g prettier;
npm i -g typescript;


# Settings #
byobu-enable; # set Byobu as default terminal


## Dotfiles ##
wget -N -P ~ ${baseUrl}/.bashrc;
wget -N -P ~ ${baseUrl}/.gitconfig;
wget -N -P ~ ${baseUrl}/.inputrc;
wget -N -P ~ ${baseUrl}/.nanorc;
wget -N -P ~/.byobu ${baseUrl}/.tmux.conf;
wget -N -P ~/.config/helix

## ssh ##
sshDir=~/.ssh;
mkdir -p ${sshDir};
wget -N -P ${sshDir} ${baseUrl}/id_ed25519.pub;
wget -N -nc -P ${sshDir} ${baseUrl}/config;
touch ${sshDir}/id_ed25519;
sudo chmod 600 ${sshDir}/id_ed25519 && sudo chmod 600 ${sshDir}/id_ed25519.pub;


# Host-Specific #
output=$(sudo dmidecode -s system-manufacturer)

if [[ $output == *"OpenStack Foundation"* ]]; then
  echo "VPS script";

  ## change hostname to "box1"
  echo "box1" | sudo tee /etc/hostname;

  ## enable ufw
  sudo ufw enable;

  ## add ssh key
  wget -N -P ~/.ssh ${baseUrl}/authorized_keys;

  ## add ssh config
  wget -N -P /etc/ssh ${baseUrl}/sshd_config;

  ## Caddy webserver
  sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https;
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg;
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list;
  sudo apt-get update;
  sudo apt-get install caddy;
  wget -N -P /etc/caddy ${baseUrl}/Caddyfile;
  sudo systemctl restart caddy;
else
  if grep -qi Microsoft /proc/version; then
    echo "WSL script";
    
    sudo ntpdate time.windows.com; # sync system clock with NTP server
  else
    echo "desktop Linux script";


    ## Apps ###
    ### Chrome ###
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;
    sudo dpkg -i google-chrome-stable_current_amd64.deb;
    rm google-chrome-stable_current_amd64.deb;

    ### Edge ###
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg;
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/;
    if ! grep -q "^deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" /etc/apt/sources.list.d/microsoft-edge.list; then
      echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null;
    fi
    sudo rm microsoft.gpg;
    sudo apt-get update && sudo apt-get install microsoft-edge-stable;

    ### apt ###
    sudo apt-get install -y build-essential;
    sudo apt-get install -y chrome-gnome-shell;
    sudo apt-get install -y dconf-cli;
    sudo apt-get install -y dconf-editor;
    sudo apt-get install -y fail2ban;
    sudo apt-get install -y fonts-firacode;
    sudo apt-get install -y gnome-tweaks;
    sudo apt-get install -y gparted;
    sudo apt-get install -y htop;
    sudo apt-get install -y nodejs;
    sudo apt-get install -y powertop;
    sudo apt-get install -y ttf-mscorefonts-installer;

    ### snap ###
    sudo snap install code --classic;
    sudo snap install gimp;
    #sudo snap install steam --beta;


    ## Settings ##
    ### dconf ###
    wget -N -P ~ ${baseUrl}/.dconf;
    dconf load / < ~/.dconf; rm ~/.dconf; # load dconf settings
    
    ### grub ###
    sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub;
    sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub;
    sudo sed -i 's/^#GRUB_TERMINAL=console/GRUB_TERMINAL=console/' /etc/default/grub
    if ! grep -q "^GRUB_SAVEDEFAULT=true" /etc/default/grub; then
      echo 'GRUB_SAVEDEFAULT=true' | sudo tee -a /etc/default/grub
    fi
    sudo mv /etc/grub.d/30_os-prober /etc/grub.d/09_os-prober;
    sudo update-grub;

    ### ufw ###
    sudo ufw enable
    sudo ufw default deny incoming;
    sudo ufw default allow outgoing;
    sudo ufw allow http;
    sudo ufw allow https;
    sudo ufw allow 2222/tcp;

    ### Cleanup ###
    rm -rf ~/Documents
    rm -rf ~/Music
    rm -rf ~/Pictures
    rm -rf ~/Templates
    rm -rf ~/Videos
  fi
fi


# Cleanup #
sudo apt-get purge -y apport;
sudo apt-get purge -y kerneloops;
sudo apt-get purge -y popularity-contest;
sudo apt-get purge -y ubuntu-report;
sudo apt-get purge -y whoopsie;

sudo apt-get autoremove -y; # remove superfluous packages
