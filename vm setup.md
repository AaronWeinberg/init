# new vm setup

## connect to box

```
# with default port 22
ssh ubuntu@<vm ip>

# with SSH port changed to 2222
ssh ubuntu@<vm ip> -p 2222

```

## change hostname to 'box1'

```
echo "box1" | sudo tee /etc/hostname
```

## enable ufw
```
sudo ufw enable
```

## add your ssh key, disable password login

```
rm -f ~/.ssh/authorized_keys && wget -P ~/.ssh https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/authorized_keys;
rm -f /etc/ssh/sshd_config && wget -P /etc/ssh https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/sshd_config;
```

## run Caddy web server

```
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
rm -f /etc/caddy/Caddyfile && wget -P /etc/caddy https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/Caddyfile;
sudo systemctl restart caddy
```

## setup your own heroku

```
mkdir ~/Development/myProj.git
cd ~/Development/myProj.git

# start a bare repo
git init --bare

# add a listener to listen to `git push`
cd ~/Development/myProj.git/hooks

# create listener
touch post-receive

# give it user-exec permissions
chmod u+x post-receive

# enter script content into post-receive
  set -eu
  proj=~/Development/myProj
  rm -rf ${proj}
  mkdir -p ${proj}
  echo "checkout to $proj"
  git --work-tree=${proj} checkout -f
  echo "prod installed"

# add a remote to your local git folder
git remote add prod box1:~/Development/myProj.git

# change/commit code

# push to prod, runs your post-receive hook
git push prod
```
