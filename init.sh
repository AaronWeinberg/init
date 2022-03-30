### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

sudo apt update; # download updates
sudo apt upgrade -y; # install updates without y/n prompt

### Variables ###
CRONTIME='0 0 * * * ';
UPDATE='sudo apt update && sudo apt -y upgrade && sudo npm update -g && sudo npm i -g npm@latest && sudo apt autoremove -y && rm -rf /home/aaron/.local/share/Trash/*';
MOUSE='set-option -g mouse on'; # enables mouse scrolling in Byobu by default
TCASE='set completion-ignore-case On'; # ignore case in path
TBELL='set bell-style none'; # disable audible bell
VNUM='set linenumbers'; # puts number next to each line in NANO
DEVPATH=~/Development;


### Apps ###

# Ubuntu-only apps + config#
if [ -d "/mnt/c" ]; then
  sudo hwclock -s # sync wsl clock to Windows clock

  # No clue why PS1 is different on wsl vs desktop ubuntu. 20.04 vs 21.10??
  PROMPT='\e[0;32m\w\e[m $(__git_ps1 "| \033[0;33m%s\033[0m")\n > '; # WSL Prompt
else
  PROMPT='^[[0;32m\W^[[0m$(__git_ps1 "|^[[0;33m%s^[[0m")\n > '; # Desktop Ubuntu Prompt
  
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

# .bashrc #
mkdir -p $DEVPATH; # make dev path
if ! grep -q "cd $DEVPATH" ~/.bashrc; then echo -e "\ncd $DEVPATH\n" >> ~/.bashrc; fi # set dev path
if ! grep -q "PS1=$PROMPT" ~/.bashrc; then echo -e "PS1='$PROMPT'\n" >> ~/.bashrc; fi # new prompt
if ! grep -q 'update(){' ~/.bashrc; then echo -e "update(){
  $UPDATE
}\n" >> ~/.bashrc; fi # custom update function

# .inputrc #
touch ~/.inputrc
if ! grep -q "$TCASE" ~/.inputrc; then echo -e "\n$TCASE" >> ~/.inputrc; fi
if ! grep -q "$TBELL" ~/.inputrc; then echo -e "\n$TBELL" >> ~/.inputrc; fi

# .nanorc #
touch ~/.nanorc
if ! grep -q "$VNUM" ~/.nanorc; then echo -e "\n$VNUM" >> ~/.nanorc; fi

# byobu #
byobu-enable; # set Byobu as default terminal
if ! grep -q "$MOUSE" ~/.byobu/.tmux.conf; then echo -e "\n$MOUSE" >> ~/.byobu/.tmux.conf; fi

# dconf #
wget https://raw.githubusercontent.com/AaronWeinberg/init/master/config/settings.dconf;
dconf load / < settings.dconf;
rm settings.dconf

# git #
git config --global user.name "Aaron Weinberg";
git config --global user.email "aaron.weinberg@gmail.com";

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
