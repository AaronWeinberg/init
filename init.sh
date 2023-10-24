#!/bin/bash

### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

sudo apt-get --fix-broken install -y;
sudo apt-get update;
sudo apt-get upgrade -y;


### Directories ###
mkdir -p ~/development; # dev path
mkdir -p ~/.npm-global;
mkdir -p ~/.ssh;


### Apps ###
## apt
sudo apt-get install -y git;
sudo apt-get install -y byobu;
sudo apt-get install -y npm;

## snap
sudo snap install curl;

# nvm
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


### SETTINGS ###
byobu-enable; # set Byobu as default terminal

## ssh
touch ~/.ssh/id_ed25519 && touch ~/.ssh/id_ed25519.pub;
sudo chmod 600 ~/.ssh/id_ed25519 && sudo chmod 600 ~/.ssh/id_ed25519.pub;


### Dotfiles ###
rm -f ~/.bashrc && wget -P ~ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.bashrc;
rm -f ~/.gitconfig && wget -P ~ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.gitconfig;
rm -f ~/.inputrc && wget -P ~ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.inputrc;
rm -f ~/.nanorc && wget -P ~ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.nanorc;
rm -f ~/.byobu/.tmux.conf && wget -P ~/.byobu https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.tmux.conf;
rm -f ~/.ssh/id_ed25519.pub && wget -P ~/.ssh https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/id_ed25519.pub;
rm -f ~/.ssh/config && wget -P ~/.ssh https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/config;


### Host-Specific ###
output=$(sudo dmidecode -s system-manufacturer)

if [[ $output == *"OpenStack Foundation"* ]]; then
  echo "VPS script";

  ## change hostname to "box1"
  echo "box1" | sudo tee /etc/hostname;

  ## enable ufw
  sudo ufw enable;

  ## add ssh key
  rm -f ~/.ssh/authorized_keys && wget -P ~/.ssh https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/authorized_keys;

  ## add ssh config
  rm -f /etc/ssh/sshd_config && wget -P /etc/ssh https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/sshd_config;

  ## Caddy webserver
  sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https;
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg;
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list;
  sudo apt-get update;
  sudo apt-get install caddy;
  rm -f /etc/caddy/Caddyfile && wget -P /etc/caddy https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/Caddyfile;
  sudo systemctl restart caddy;
else
  if grep -qi Microsoft /proc/version; then
    echo "WSL script";

    sudo timedatectl set-local-rtc 1; # fix Windows wrong clock after dual booting
    # sync system clock with NTP server
    sudo apt-get install -y ntpdate;
    sudo ntpdate ntp.ubuntu.com;
  else
    echo "desktop Linux script";


    ### Dotfiles ###
    rm -f .dconf && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.dconf;


    ### Apps ####
    ## Chrome
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;
    sudo dpkg -i google-chrome-stable_current_amd64.deb;
    rm google-chrome-stable_current_amd64.deb;

    ## Edge
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg;
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/;
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list';
    sudo rm microsoft.gpg;
    sudo apt-get update && sudo apt-get install microsoft-edge-stable;

    ## apt
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

    ## snap
    sudo snap install code --classic;
    sudo snap install gimp;
    sudo snap install steam --beta;


    ### Settings ###
    dconf load / < ~/.dconf; rm ~/.dconf; # load dconf settings
    
    ## grub
    sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub;
    sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub;
    echo 'GRUB_SAVEDEFAULT=true' | sudo tee -a /etc/default/grub;
    sudo update-grub;

    ## ufw
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


### Cleanup ####
sudo apt-get purge -y apport;
sudo apt-get purge -y kerneloops;
sudo apt-get purge -y popularity-contest;
sudo apt-get purge -y ubuntu-report;
sudo apt-get purge -y whoopsie;

sudo apt-get autoremove -y; # remove superfluous packages
