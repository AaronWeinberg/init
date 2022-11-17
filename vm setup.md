# new vm setup

## connect to box

```
# with default port 22
ssh ubuntu@135.148.44.125

# with SSH port changed to 2222
ssh ubuntu@135.148.44.125 -p 2222

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

## run local web server

```
# cd myProj
# example webservers
sudo python3 -m http.server 80 #python3
sudo busybox httpd -fv -p 80 # busybox
# nodejs webserver https://www.npmjs.com/package/http-server
sudo http-server . -p 80 # default is localhost:8080
```

## setup your own shiny heroku

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

## set upcertbot
```
# update snapd
sudo snap install core; sudo snap refresh core;

# remove existant certbot versions
sudo apt-get remove certbot;

# install certbot
sudo snap install --classic certbot;

# prepare certbot commands
sudo ln -s /snap/bin/certbot /usr/bin/certbot;

# run certbot
sudo certbot --nginx;

# automatic renewal
sudo certbot renew --dry-run;
```
