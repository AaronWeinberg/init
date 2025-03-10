#                   Linux                         #
Before clean install, save current settings -> override in dotfiles
```sh
dconf dump / > .dconf;
```
### INIT SCRIPT (bash)
```sh
wget https://raw.githubusercontent.com/AaronWeinberg/init/master/scripts/init.sh && sudo chmod +x init.sh && command="./init.sh"; echo $command; eval $command 2>&1 | tee init.log && rm init.sh
```
# New Desktop Setup
## Install GNOME Shell Integration extensions:
  - App Icons Taskbar
  - Autohide Battery
  - Autohide Volume
  - DDTERM
  - Emoji Copy
  - Hide Network Icon
  - Just Perfection

# New VPS Setup

## Change username
```
sudo groupadd new_username # Create the new group
sudo usermod -l new_username old_username # Change the username
sudo mv /home/old_username /home/new_username # Rename the home directory
sudo usermod -d /home/new_username new_username # Update the home directory path
sudo chown -R new_username:new_username /home/new_username # Change the ownership of the home directory
```

## Change domains in Caddyfile

## Setup your own heroku

```sh
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

#                    Windows                      #
* Windows updates (several restarts)
* Microsoft Store -> update all apps
 
 ### INIT SCRIPT (Powershell as admin)

```powershell
$command = 'Set-ExecutionPolicy Unrestricted; (Invoke-webrequest -URI "https://raw.githubusercontent.com/AaronWeinberg/init/master/scripts/init.ps1").Content | out-file -filepath init.ps1; .\init.ps1; rm C:\Users\aaron\init.ps1'; echo $command | Tee-Object -FilePath init.log; Invoke-Expression $command | Tee-Object -FilePath init.log -Append
```
 
## Settings App:
### System:
* Display: Night light: on
* Notifications:
  * Notifications: disable
  * Additional Settings: disable all
* Multitasking:
  * Show tabs from apps...: "Don't show tabs"
### Bluetooth and Devices:
* Add device:
  * keyboard
  * mouse
  * controller
### Personalization:
* Themes:
  * Theme: dark
  * Desktop Icon Settings: Recycle Bin: disable
* Background:
  * Personalize your background: slideshow: C:\Users\aaron\OneDrive\Backgrounds
  * change picture every: 1 minute
  * shuffle the picture order: on
* Lock Screen:
  * Personalize your lockscreen: slideshow: C:\Users\aaron\OneDrive\Backgrounds
  * Get fun facts, tips tricks and more on your lock screen: uncheck
* Start:
  * Show recently added apps: disable
  * Show recently opened items: disable
  * Show tips: disable
* Taskbar:
  * Taskbar Apps: Disable search/taskview/widgets/chat
### Apps:
* Startup: disable all
### Accounts:
* Sign-in options:
  * Facial Recognition
  * Fingerprint
### Time & Language:
* Date & Time:
  * Set time zone automatically
* Language & Region: Regional Format: change all to yyyy-mm-dd + 24-hour time
### Privacy & Security:
* For Developers:
  * File Explorer:
    * Show file extensions: on
    * Show hidden and system files: on
    * Show full path in title bar: on
### Windows Update:
* Get the latest updates as soon as they're available: on
* Advanced Options
  * Receive updates for other Microsoft products
  * Optional updates

## Other Settings
* OneDrive -> Backgrounds -> Always keep on this device
* Dell Command Update -> updates
* Explorer:
  * Remove from Quick Access:
    * Pictures
    * Music
    * Videos
* Unpin all apps from taskbar + start menu

#               Common Settings                 #
* Printer drivers:
  * Linux:
    * https://support.brother.com/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2690dw_us&os=128&dlid=dlf006893_000&flang=4&type3=625
  * Windows:
    * https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=mfcl2690dw_us
* Setup extensions + settings on Edge, Firefox, and Google
* Create WireGuard tunnel from .conf file
