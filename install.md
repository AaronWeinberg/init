### ### ### ### ### ### ### ### ### ### ### ### ###
#                   Linux                         #

## init
touch ~/init.sh \
vi ~/init.sh -> copy from init.sh in repo \
sudo chmod +x ~/init.sh \
./init.sh

## dconf
touch ~/settings.dconf \
vim ~/settings.dconf -> copy from settings.dconf in repo \
dconf load / < ~/settings.dconf


### ### ### ### ### ### ### ### ### ### ### ### ###
#                    Windows                      #

Windows updates (several restarts) \
Microsoft Store -> update all apps \
File Explorer Options -> View -> Check 'Show hidden files' +++ Uncheck 'Hide extensions for known file types' \
From elevated Powershell -> Set-Execution-Policy Unrestricted \
Download \PowerShell into C:\Users\aaron\Documents\ \
.C:\Users\aaron\PowerShell\Scripts\init.ps1 \
Task Scheduler → import update.xml \
Download Ctrl2Cap -> extract -> Open elevated cmd prompt -> navigate to extracted folder -> run 'ctrl2cap /install'
