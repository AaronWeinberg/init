### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###


### Variables ###
CRON='0 * * * * sudo apt update && sudo apt -y upgrade && rm -rf ~/.local/share/Trash/*';
DEVPATH=~/Development;
EMAIL='aaron.weinberg@gmail.com'
NAME='Aaron Weinberg';

sudo apt update; # download updates
sudo apt -y upgrade; # install updates without y/n prompt


### Apps ###
# Node #
sudo apt-get install curl python-software-properties
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

sudo apt install -y
  byobu
  chrome-gnome-shell
  curl
  git
  gnome-tweaks
  google-chrome-stable
  gparted
  htop
  nodejs
  powertop
  steam-installer
  ttf-mscorefonts-installer
  vim;

sudo apt purge -y
  apport
  kerneloops
  popularity-contest
  ubuntu-report
  whoopsie;

#sudo snap install
#  code --classic;
  
# Balena Etcher #
sudo apt install -y libfprint-2-tod1 apt-transport-https
curl -1sLf \
  'https://dl.cloudsmith.io/public/balena/etcher/setup.deb.sh' \
  | sudo -E bash
sudo apt update
sudo apt install -y balena-etcher-electron
  
# Chrome #
#if ! dpkg -l | grep google-chrome-stable; then
#  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;
#  sudo dpkg -i google-chrome-stable_current_amd64.deb;
#fi


### Terminal Setup ###
if [ ! -f ~/.inputrc ]; then
  touch ~/.inputrc;
  echo 'set completion-ignore-case On' >> ~/.inputrc;
  echo 'set bell-style none' >> ~/.inputrc;
fi

if [ ! -d $DEVPATH ]; then echo -e "\ncd $DEVPATH # Set default path" >> ~/.bashrc; fi # set dev path
mkdir -p $DEVPATH; # make dev path

byobu-enable; # set Byobu as default terminal


### VIM ###
if [ ! -f ~/.vimrc ]; then 
  touch ~/.vimrc;
  echo 'set belloff=all' >> ~/.vimrc;
  echo 'set number' >> ~/.vimrc;
fi


### Cron Jobs ###
if ! pgrep cron; then sudo cron start; fi # start Cron if stopped
crontab -l > mycron; # write out current crontab
if ! grep -q $CRON mycron; then
  echo $CRON >> mycron; # echo new cron into cron file
  sudo crontab mycron; # install new cron file
fi
rm mycron;


### Git ###
git config --global user.name $NAME;
git config --global user.email $EMAIL;


### SSH ###
mkdir ~/.ssh;
touch ~/.ssh/id_ed25519;
touch ~/.ssh/id_ed25519.pub;


### Global Packages ###
npm i -g npm-check-updates;


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

exec bash; # refresh shell ### WARN ### No command can follow this
