### ### ### ### ### ### ###
### Initial Linux Setup ###
### ### ### ### ### ### ###


### Variables ###
DEVPATH=$HOME/Development;
WINPATH=/mnt/c;
EMAIL='aaron.weinberg@gmail.com'
NAME='Aaron Weinberg';


### Terminal Setup ###
if [ ! -d $HOME/.vscode-server ]; then # if first time init.sh is being run (VS Code isn't installed), update Linux
  if [ -d $WINPATH ]; then sudo hwclock --hctosys; fi # if on WSL, set Linux clock to system clock
  sudo apt update; # download updates
  sudo apt -y upgrade; # install updates without y/n prompt
fi

if [ ! grep -q 'set completion-ignore-case On' $HOME/.inputrc ]; then echo 'set completion-ignore-case On' >> $HOME/.inputrc; fi # ignore case-sensitive autocomplete
if [ ! grep -q 'set bell-style none' $HOME/.inputrc ]; then echo 'set bell-style none' >> $HOME/.inputrc; fi # turn off bell

if [ ! grep -q "cd $DEVPATH" $HOME/.bashrc ]; then echo -e "\ncd $DEVPATH # Set default path" >> $HOME/.bashrc; fi
mkdir -p $DEVPATH; # make dev path

if [ ! grep -q 'update(){' $HOME/.bashrc ]; then
  echo -e "\nupdate(){
  if [ -d $WINPATH ]; then sudo hwclock --hctosys; fi # if on WSL, set Linux clock to system clock
  sudo apt update; # download updates
  sudo apt -y upgrade; # install updates without y/n prompt
  ncu -g -u # update global packages
  nvm install --lts; # download and switch to lts node version
}" >> $HOME/.bashrc;
fi # if update() function not in .bashrc, add it

if [ ! grep -q '_byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true' $HOME/.profile ]; then byobu-enable; fi # set Byobu as default terminal


### VIM ###
if [ ! -a $HOME/.vimrc ]; then
  if [ ! grep -q 'set visualbell' $HOME/.vimrc ]; then echo 'set visualbell' >> $HOME/.vimrc; fi # turn off bell
  if [ ! grep -q 'set number' $HOME/.vimrc ]; then echo 'set number' >> $HOME/.vimrc; fi # show line numbers
fi


### Cron (Native Linux Only) ###
if ! pgrep cron; then sudo cron start; fi # start Cron if stopped
sudo crontab -l > mycron # write out current crontab
if ! grep -q '00 00 * * * update' mycron; then
  echo '00 00 * * * update' >> mycron # echo new cron into cron file
  sudo crontab mycron # install new cron file
fi
rm mycron


### SSH ###
if ! -f $HOME/.ssh/id_ed25519.pub; then ssh-keygen -t ed25519 -C $EMAIL; fi # create SSH keys if not already created


### Git ###
git config --global user.name $NAME;
git config --global user.email $EMAIL;


### Global Packages ###
npm i -g npm-check-updates;
npm i -g eslint;


### Linux / Windows apps + settings ###
if [ ! -d $WINPATH ]; then

  ### Linux Apps
  sudo apt install gnome-tweak-tool npm powertop;
  sudo snap install chromium code heroku;
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb;

  ### Linux Settings
  settings set org.gnome.shell.extensions.desktop-icons show-home false;
  settings set org.gnome.shell.extensions.desktop-icons show-trash false;

fi

### On any Linux distro ###
if [ ! -d $HOME/.nvm ]; then
  curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash; # install nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; # loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"; # loads nvm bash_completion
  source $HOME/.profile;
  npm update -g;
  nvm install node;
fi

if [ ! -d $HOME/.vscode-server; then code . ]; fi # if uninstalled, install and run VS Code

exec bash; # refresh shell ### WARN ### No command can follow this
