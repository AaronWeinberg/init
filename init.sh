### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

sudo apt update; # download updates
sudo apt upgrade -y; # install updates without y/n prompt


### Directories ###
mkdir -p ~/Development # dev path
mkdir -p ~/.npm-global # global npm
mkdir -p ~/.ssh; # ssh


### Settings ###
byobu-enable; # set Byobu as default terminal
#dconf dump / > .dconf; # export all manually changed settings to .dconf
dconf load / < ~/.dconf; rm ~/.dconf # load dconf settings
sudo crontab ~/.crontab; rm ~/.crontab; #cron
npm config set prefix '~/.npm-global'; # tell npm to install global modules within your home dir

# ssh #
touch ~/.ssh/id_ed25519 && touch ~/.ssh/id_ed25519.pub;
sudo chmod 600 ~/.ssh/id_ed25519 && sudo chmod 600 ~/.ssh/id_ed25519.pub;

if hostname | grep -P 'box'; then
  #configure firewall
  sudo ufw default deny incoming;
  sudo ufw default allow outgoing;

  # sudo ufw allow ssh;
  sudo ufw allow http;
  sudo ufw allow https;
  sudo ufw allow 2222/tcp;
  sudo ufw enable;
fi


### Dotfiles ###
cd ~/.ssh/;
rm -f config && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/config;
cd ~/.byobu/;
rm -f .tmux.conf && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.tmux.conf
cd ~/;
rm -f .bashrc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.bashrc
rm -f .crontab && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.crontab
rm -f .dconf && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.dconf;
rm -f .gitconfig && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.gitconfig
rm -f .inputrc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.inputrc
rm -f .npmrc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.npmrc
rm -f .nanorc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.nanorc


### Apps ###
# Chrome #
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb;

# fingerprint #
sudo apt install libfprint-2-tod1;
wget http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-goodix/libfprint-2-tod1-goodix_0.0.6-0ubuntu1~somerville1_amd64.deb;
sudo dpkg -i libfprint-2-tod1-goodix_0.0.6-0ubuntu1~somerville1_amd64.deb;
sudo pam-auth-update;
rm libfprint-2-tod1-goodix_0.0.6-0ubuntu1~somerville1_amd64.deb;

# Node #
sudo apt install -y curl;
# curl -fsSL 'https://deb.nodesource.com/setup_lts.x' | sudo -E bash; # lts
curl -fsSL 'https://deb.nodesource.com/setup_18.x' | sudo -E bash -;

# apt #
sudo apt install -y build-essential;
sudo apt install -y byobu;
sudo apt install -y chrome-gnome-shell;
sudo apt install -y dconf-cli;
sudo apt install -y dconf-editor;
sudo apt install -y fail2ban;
sudo apt install -y fonts-firacode;
sudo apt install -y git;
sudo apt install -y gnome-tweaks;
sudo apt install -y gparted;
sudo apt install -y htop;
sudo apt install -y nodejs;
sudo apt install -y powertop;
sudo apt install -y ttf-mscorefonts-installer;

# npm #
npm install -g npm-check-updates;
npm install -g eslint;
npm install -g eslint-config-prettier;
npm install -g prettier;
npm install -g typescript;

# snap #
sudo snap install code --classic;

# remove #
sudo apt purge -y apport;
sudo apt purge -y kerneloops;
sudo apt purge -y popularity-contest;
sudo apt purge -y ubuntu-report;
sudo apt purge -y whoopsie;
sudo apt autoremove -y;
