# new vm setup

## connect to box

```
# with default port 22
ssh ubuntu@135.148.44.125

# with SSH port changed to 2222
ssh ubuntu@135.148.44.125 -p 2222

```

## update box

```
sudo apt update
sudo apt dist-upgrade
```

## change hostname

```
sudo vi /etc/hostname
```

## update .bashrc

```
vi ~/.bashrc
```

## enable byobu

```
byobu-enable
```

## add your ssh key, disable password login

```
# add your key to ~/.ssh/authorized_keys

# /etc/ssh/sshd_config
Port 2222
PasswordAuthentication no
```

## install node

```
# https://github.com/nodesource/distributions
sudo -i
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
```

## setup node to work without sudo

```
# tell npm to install global modules within your home dir
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
# npm config set save-prefix='~'
# npm config set send-metrics=false

# add to your ~/.bashrc to tell linux to look for npm binaries here
export PATH="${HOME}/.npm-global/bin:$PATH"

```

## install deps

```
sudo apt install fail2ban build-essential
```

## setup and enable firewall

```
sudo ufw status

sudo ufw default deny incoming
sudo ufw default allow outgoing

# sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 2222/tcp
sudo ufw enable

```

## run local web server

```
mkdir www
cd www
touch index.html
# add stuff to index.html

# serve with a webserver
sudo python3 -m http.server 80
sudo busybox httpd -fv -p 80
# nodejs webserver https://www.npmjs.com/package/http-server
```

## setup your own shiny heroku

```
mkdir /home/ubuntu/Development/myProj.git
cd /home/ubuntu/Development/myProj.git

# start a bare repo
git init --bare

# add a listener to listen to `git push`
cd /home/ubuntu/Development/myProj.git/hooks

# create listener
touch post-receive

# give it user-exec permissions
chmod u+x post-receive

# enter script content into post-receive
  set -eu
  proj=/home/ubuntu/Development/myProj
  #rm -rf ${proj}
  #mkdir -p ${proj}
  echo "checkout to $proj"
  git --work-tree=${proj} checkout -f
  #sudo chown -R www-data:www-data $proj
  echo "prod installed"

# add a remote to your local git folder
git remote add prod box1:myProj.git

# change/commit code

# push to prod, runs your post-receive hook
git push prod HEAD:master
```
