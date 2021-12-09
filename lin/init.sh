### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###


### Variables ###
CRONTIME='0 0 * * * ';
UPDATE='sudo apt update && sudo apt -y upgrade && sudo apt autoremove -y && sudo npm update -g && rm -rf /home/aaron/.local/share/Trash/*';
TCASE='set completion-ignore-case On';
TBELL='set bell-style none';
VBELL='set belloff=all';
VNUM='set number';
PS1='\033[1;37m\W\033[0m$(__git_ps1 "|\033[0;33m%s\033[0m")\\n > '
DEVPATH=~/Development;


### Apps ###
sudo apt install -y curl

# Balena Etcher #
sudo apt install -y libfprint-2-tod1 apt-transport-https;
curl -1sLf \
  'https://dl.cloudsmith.io/public/balena/etcher/setup.deb.sh' \
  | sudo -E bash;

# Chrome #
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;
sudo dpkg -i google-chrome-stable_current_amd64.deb;

# Node #
curl -fsSL \
  'https://deb.nodesource.com/setup_lts.x' \
  | sudo -E bash;

sudo apt update; # download updates
sudo apt upgrade -y; # install updates without y/n prompt

# apt #
sudo apt install -y balena-etcher-electron;
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
sudo apt install -y steam-installer;
sudo apt install -y ttf-mscorefonts-installer;
sudo apt install -y vim;

# snap #
sudo snap install code --classic;

# npm #
sudo npm install -g npm-check-updates;

# remove #
sudo apt purge -y apport;
sudo apt purge -y kerneloops;
sudo apt purge -y popularity-contest;
sudo apt purge -y ubuntu-report;
sudo apt purge -y whoopsie;
sudo apt autoremove -y;


### Terminal Setup ###
# .inputrc #
touch ~/.inputrc
if ! grep -q "$TCASE" ~/.inputrc; then echo -e "\n$TCASE" >> ~/.inputrc; fi
if ! grep -q "$TBELL" ~/.inputrc; then echo -e "\n$TBELL" >> ~/.inputrc; fi

# .bashrc #
mkdir -p $DEVPATH; # make dev path
if ! grep -q "cd $DEVPATH" ~/.bashrc; then echo -e "\ncd $DEVPATH\n" >> ~/.bashrc; fi # set dev path
if ! grep -q "PS1='$PS1'" ~/.bashrc; then echo -e "PS1='$PS1'\n" >> ~/.bashrc; fi # new prompt
if ! grep -q 'update(){' ~/.bashrc; then echo -e "update(){
  $UPDATE
}\n" >> ~/.bashrc; fi # custom update function

# .vimrc #
touch ~/.vimrc
if ! grep -q "$VBELL" ~/.vimrc; then echo -e "\n$VBELL" >> ~/.vimrc; fi
if ! grep -q "$VNUM" ~/.vimrc; then echo -e "\n$VNUM" >> ~/.vimrc; fi

# byobu #
byobu-enable; # set Byobu as default terminal
byobu-enable-prompt # color theme for prompt

# git #
git config --global user.name "Aaron Weinberg";
git config --global user.email "aaron.weinberg@gmail.com";

# ssh ##
rm -rf ~/.ssh;
mkdir -p ~/.ssh;
touch ~/.ssh/id_ed25519 && touch ~/.ssh/id_ed25519.pub;
sudo chmod 600 ~/.ssh/id_ed25519 && sudo chmod 600 ~/.ssh/id_ed25519.pub;


### Settings ###
gsettings set org.gnome.system.location enabled true # turn on location services
gsettings set org.gnome.desktop.datetime automatic-timezone true # turn on automatic timezone setting
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/Milky_Way_by_Paulo_Jos%C3%A9_Oliveira_Amaro.jpg'
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/Milky_Way_by_Paulo_Jos%C3%A9_Oliveira_Amaro.jpg'
gsettings set org.gnome.desktop.input-sources xkb-options ['caps:ctrl_modifier'] # caps -> ctrl
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true # autohide
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 38
gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true # display on all monitors
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize' # minimize on click
gsettings set org.gnome.shell.extensions.desktop-icons show-home false # hide home folder
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false # hide trash icon


# cron #
if ! pgrep cron; then sudo cron start; fi # start Cron if stopped
sudo -i
sudo crontab -l > mycron; # write out current sudo crontab
if ! grep -q "$UPDATE" mycron; then
  echo "$CRONTIME$UPDATE" >> mycron; # echo new cron into cron file
  sudo crontab mycron; # install new cron file
fi
rm mycron
