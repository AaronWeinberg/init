### ### ### ### ### ### ###
#   Initial Linux Setup   #
### ### ### ### ### ### ###

sudo apt --fix-broken install -y;
sudo apt update;
sudo apt upgrade -y;

### DIRECTORIES ###
mkdir -p ~/development; # dev path
mkdir -p ~/.ssh;

### SETTINGS ###
sudo byobu-enable; # set Byobu as default terminal
### Dotfiles ###
rm -f .bashrc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.bashrc;
rm -f .gitconfig && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.gitconfig;
rm -f .inputrc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.inputrc;
rm -f .nanorc && wget https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.nanorc;
rm -f ~/.byobu/.tmux.conf && wget -P ~/.byobu https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.tmux.conf;
rm -f ~/.ssh/config && wget -P ~/.ssh https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/config;
## ssh
touch ~/.ssh/id_ed25519 && touch ~/.ssh/id_ed25519.pub;
sudo chmod 600 ~/.ssh/id_ed25519 && sudo chmod 600 ~/.ssh/id_ed25519.pub;

### APPS ###
## apt
sudo apt install -y git
## npm
npm i -g eslint;
npm i -g eslint-config-prettier;
npm i -g pnpm
npm i -g prettier;
npm i -g typescript;