### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

sudo apt --fix-broken install -y;
sudo apt update;
sudo apt upgrade -y;


### Directories ###
mkdir -p ~/development; # dev path
mkdir -p ~/.npm-global;
mkdir -p ~/.ssh;


### Dotfiles ###
rm -f .bashrc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.bashrc;
rm -f .dconf && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.dconf;
rm -f .gitconfig && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.gitconfig;
rm -f .inputrc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.inputrc;
rm -f .nanorc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.nanorc;
rm -f .npmrc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.npmrc;
rm -f ~/.byobu/.tmux.conf && wget -P ~/.byobu https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.tmux.conf;
rm -f /usr/share/byobu/keybindings/f-keys.tmux && wget -P /usr/share/byobu/keybindings https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/f-keys.tmux;
rm -f ~/.ssh/config && wget -P ~/.ssh https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/config;
rm -f /etc/default/grub && wget -P /etc/defaults https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/grub;


### Settings ###
byobu-enable; # set Byobu as default terminal
#dconf dump / > .dconf; # export all manually changed settings to .dconf >> replace in dotfiles
dconf load / < ~/.dconf; rm ~/.dconf; # load dconf settings
sudo crontab ~/.crontab; rm ~/.crontab;
sudo timedatectl set-local-rtc 1 # fix Windows wrong clock after dual booting
update-grub;

## ssh
touch ~/.ssh/id_ed25519 && touch ~/.ssh/id_ed25519.pub;
sudo chmod 600 ~/.ssh/id_ed25519 && sudo chmod 600 ~/.ssh/id_ed25519.pub;

## ufw
sudo ufw default deny incoming;
sudo ufw default allow outgoing;
sudo ufw allow http;
sudo ufw allow https;
sudo ufw allow 2222/tcp;


### Apps ###
## Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb;

## Edge
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
sudo rm microsoft.gpg
sudo apt update && sudo apt install microsoft-edge-stable

## Node
curl -fsSL 'https://deb.nodesource.com/setup_20.x' | sudo -E bash -; # node ppa
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash # nvm

## apt
sudo apt install -y build-essential;
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

## npm
npm i -g eslint;
npm i -g eslint-config-prettier;
npm i -g pnpm
npm i -g prettier;
npm i -g typescript;

## snap
sudo snap install code --classic;
sudo snap install gimp;
sudo snap install steam --beta

## remove
sudo apt purge -y apport;
sudo apt purge -y kerneloops;
sudo apt purge -y popularity-contest;
sudo apt purge -y ubuntu-report;
sudo apt purge -y whoopsie;

sudo apt autoremove -y; # remove superfluous packages

rm -rf ~/Documents
rm -rf ~/Music
rm -rf ~/Pictures
rm -rf ~/Templates
rm -rf ~/Videos