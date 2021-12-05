### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###


### Variables ###
CRON='0 * * * * sudo apt update && sudo apt -y upgrade && rm -rf ~/.local/share/Trash/*';
SUDOCRON='0 * * * * nvm install-latest-npm && nvm install --lts';
DEVPATH=~/Development;
EMAIL='aaron.weinberg@gmail.com'
NAME='Aaron Weinberg';

sudo apt update; # download updates
sudo apt -y upgrade; # install updates without y/n prompt


### Apps ###
sudo apt install -y
  byobu
  chrome-gnome-shell
  curl
  git
  gnome-tweaks
  gparted
  htop
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

sudo snap install
  code --classic;
  
# Balena Etcher #
sudo apt install -y libfprint-2-tod1 apt-transport-https
curl -1sLf \
   'https://dl.cloudsmith.io/public/balena/etcher/setup.deb.sh' \
   | sudo -E bash
  
# Chrome #
if ! dpkg -l | grep google-chrome-stable; then
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;
  sudo dpkg -i google-chrome-stable_current_amd64.deb;
fi


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
# Cron #
if ! pgrep cron; then sudo cron start; fi # start Cron if stopped
crontab -l > mycron; # write out current crontab
if ! grep -q $CRON mycron; then
  echo $CRON >> mycron; # echo new cron into cron file
  sudo crontab mycron; # install new cron file
fi
rm mycron;

# sudo Cron #
sudo crontab -l > mycron;
if ! grep -q $SUDOCRON mycron; then
  echo $SUDOCRON >> mycron;
  sudo crontab mycron;
fi
rm mycron;


### Git ###
git config --global user.name $NAME;
git config --global user.email $EMAIL;



### NVM + NPM + Node ###
if [ ! -d ~/.nvm ]; then
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash; # download + install nvm
  export NVM_DIR='~/.nvm';
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; # loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"; # loads nvm bash_completion
  source ~/.profile;
  nvm install --lts;
  nvm install-latest-npm;
  npm update -g;
fi


### Global Packages ###
npm i -g npm-check-updates;
npm i -g eslint;


### Settings ###
gsettings set org.gnome.shell.extensions.desktop-icons show-home false # hide home folder
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false # hide trash icon

exec bash; # refresh shell ### WARN ### No command can follow this
