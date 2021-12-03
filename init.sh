### ### ### ### ### ### ###
### Initial Linux Setup ###
### ### ### ### ### ### ###


### Variables ###
CRON='0 * * * * sudo apt update && sudo apt -y upgrade && nvm install-latest-npm && nvm install --lts';
DEVPATH=~/Development;
EMAIL='aaron.weinberg@gmail.com'
NAME='Aaron Weinberg';

sudo apt update; # download updates
sudo apt -y upgrade; # install updates without y/n prompt


### Apps ###
sudo apt -y i
  byobu
  gnome-tweaks
  powertop;
sudo snap install
  code --classic
  
# Chrome #
if ! dpkg -l | grep google-chrome-stable; then
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; # download chrome
  sudo dpkg -i google-chrome-stable_current_amd64.deb; # install chrome
fi


### Terminal Setup ###
if [ ! -f ~/.inputrc ]; then
  touch ~/.inputrc; # create .inputrc
  echo 'set completion-ignore-case On' >> ~/.inputrc; # ignore case-sensitive autocomplete for terminal
  echo 'set bell-style none' >> ~/.inputrc; # turn off bell for terminal
fi

if [ ! -d $DEVPATH ]; then echo -e "\ncd $DEVPATH # Set default path" >> ~/.bashrc; fi # set dev path
mkdir -p $DEVPATH; # make dev path

byobu-enable; # set Byobu as default terminal


### VIM ###
if [ ! -a ~/.vimrc ]; then 
  touch ~/.vimrc; # create .vimrc
  echo 'set belloff=all' >> ~/.vimrc; # turn off bell
  echo 'set number' >> ~/.vimrc; # show line numbers
fi


### Cron ###
if ! pgrep cron; then sudo cron start; fi # start Cron if stopped
sudo crontab -l > mycron; # write out current crontab
if ! grep -q $CRON mycron; then
  echo $CRON >> mycron; # echo new cron into cron file
  sudo crontab mycron; # install new cron file
fi
rm mycron;


### Git ###
git config --global user.name $NAME;
git config --global user.email $EMAIL;


### Global Packages ###
npm i -g npm-check-updates;
npm i -g eslint;


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

exec bash; # refresh shell ### WARN ### No command can follow this
