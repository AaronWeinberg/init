# new vm setup

## connect to box

```
# with default port 22
ssh ubuntu@<vm ip>

# with SSH port changed to 2222
ssh ubuntu@<vm ip> -p 2222

```

## change hostname

```
sudo vi /etc/hostname
```

## enable ufw
```
sudo ufw enable
```

## add your ssh key, disable password login

```
# add your key to ~/.ssh/authorized_keys

# /etc/ssh/sshd_config
Port 2222
PasswordAuthentication no
```

## run Caddy web server

```
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
# add Caddyfile from dotfiles to /etc/caddy/
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
