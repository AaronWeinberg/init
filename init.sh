### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

sudo apt update; # download updates
sudo apt upgrade -y; # install updates without y/n prompt

### Variables ###
CRONTIME='0 0 * * * ';
MOUSE='set-option -g mouse on'; # enables mouse scrolling in Byobu by default

# dotfiles #
rm -f ~/.bashrc && wget ~/ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.bashrc
rm -f ~/.gitconfig && wget ~/ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.gitconfig
rm -f ~/.inputrc && wget ~/ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.inputrc
rm -f ~/.npmrc && wget ~/ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.npmrc
rm -f ~/.vimrc && wget ~/ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.nanorc

### Apps ###

  # Chrome #
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;
  sudo dpkg -i google-chrome-stable_current_amd64.deb;
  rm google-chrome-stable_current_amd64.deb;

  # fingerprint #
  sudo apt install libfprint-2-tod1;
  wget http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-goodix/libfprint-2-tod1-goodix_0.0.6-0ubuntu1~somerville1_amd64.deb
  sudo dpkg -i ~/Downloads/libfprint-2-tod1-goodix_0.0.6-0ubuntu1~somerville1_amd64.deb;
  sudo pam-auth-update;
fi;

sudo apt install -y curl;

# Node #
# curl -fsSL 'https://deb.nodesource.com/setup_lts.x' | sudo -E bash; # lts
curl -fsSL 'https://deb.nodesource.com/setup_17.x' | sudo -E bash; # latest

# apt #
sudo apt install -y byobu;
sudo apt install -y chrome-gnome-shell;
sudo apt install -y dconf-cli;
sudo apt install -y dconf-editor;
sudo apt install -y fonts-firacode;
sudo apt install -y git;
sudo apt install -y gnome-tweaks;
sudo apt install -y gparted;
sudo apt install -y htop;
sudo apt install -y nodejs;
sudo apt install -y powertop;
sudo apt install -y ttf-mscorefonts-installer;

# snap #
sudo snap install code --classic;

# npm #
sudo npm install -g npm-check-updates;
sudo npm install -g eslint;
sudo npm install -g eslint-config-prettier;
sudo npm install -g prettier;
sudo npm install -g typescript;

# remove #
sudo apt purge -y apport;
sudo apt purge -y kerneloops;
sudo apt purge -y popularity-contest;
sudo apt purge -y ubuntu-report;
sudo apt purge -y whoopsie;
sudo apt autoremove -y;


### Settings ###

# byobu #
byobu-enable; # set Byobu as default terminal
if ! grep -q "$MOUSE" ~/.byobu/.tmux.conf; then echo -e "\n$MOUSE" >> ~/.byobu/.tmux.conf; fi

# dconf #
rm -f ~/.dconf
wget ~/ https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.dconf;
dconf load / < ~/.dconf;
rm -f ~/.dconf

# ssh ##
rm -rf ~/.ssh;
mkdir -p ~/.ssh;
touch ~/.ssh/id_ed25519 && touch ~/.ssh/id_ed25519.pub;
sudo chmod 600 ~/.ssh/id_ed25519 && sudo chmod 600 ~/.ssh/id_ed25519.pub;

# cron #
if ! pgrep cron; then sudo cron start; fi # start Cron if stopped
sudo -i
sudo crontab -l > mycron; # write out current sudo crontab
if ! grep -q "$UPDATE" mycron; then
  echo "$CRONTIME$UPDATE" >> mycron; # echo new cron into cron file
  sudo crontab mycron; # install new cron file
fi
rm mycron
