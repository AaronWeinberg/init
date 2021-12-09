### ### ### ### ### ### ### ### ### ### ### ### ###
#                   Linux                         #

# init
touch ~/init.sh
vi ~/init.sh -> copy from init.sh in repo
sudo chmod +x ~/init.sh
./init.sh

# dconf
touch ~/settings.dconf
vim ~/settings.dconf -> copy from settings.dconf in repo
dconf load / < ~/settings.dconf


### ### ### ### ### ### ### ### ### ### ### ### ###
#                    Windows                      #

Windows updates (several restarts)
Microsoft Store -> update all apps
File Explorer Options -> View -> Check "Show hidden files" +++ Uncheck "Hide extensions for known file types"
From elevated Powershell -> Set-Execution-Policy Unrestricted
.\init.ps1
Save update.ps1 to C:\Users\aaron\Documents\
Task Scheduler → import update.xml
Download fonts -> extract -> drag + drop onto Settings / Personalization / Fonts
Download Ctrl2Cap -> extract -> Open elevated cmd prompt -> navigate to extracted folder -> run 'ctrl2cap /install'
