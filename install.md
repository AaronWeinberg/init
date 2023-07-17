#                   Linux                         #
Before clean install, save current settings -> override in dotfiles
```
dconf dump / > .dconf;
```
### INIT SCRIPT (bash)
```
wget https://raw.githubusercontent.com/AaronWeinberg/init/master/init.sh && sudo chmod +x init.sh && ./init.sh && rm init.sh
```
- In ~/.ssh/config --> replace <box1 ip> with VPS ip
- In ~/.ssh/id_ed25519 --> add private ssh key
- On VPS: change domains in Caddyfile
- On Ubuntu Desktop -> GNOME Shell Integration extensions:
  - App Icons Taskbar
  - Autohide Battery
  - Autohide Volume
  - DDTERM
  - Just Perfection

#                    Windows                      #
* Windows updates (several restarts)
* Microsoft Store -> update all apps
 
 ### INIT SCRIPT (Powershell)

```

Set-ExecutionPolicy Unrestricted; (Invoke-webrequest -URI "https://raw.githubusercontent.com/AaronWeinberg/init/master/init.ps1").Content | out-file -filepath init.ps1; .\init.ps1; rm C:\Users\aaron\init.ps1

```
 
## Settings App:
### System:
* Display: Night light: on
* Notifications:
  * Notifications: disable
  * Additional Settings: disable all
* Bluetooth and Devices: Devices: Connect Keyboard, mouse, controller
* Personalization:
  * Themes:
    * Theme: dark
    * Desktop Icon Settings: Recycle Bin: disable
  * Lock Screen:
    * Switch from Windows Spotlight --> Picture
    * Get fun facts, tips tricks and more on your lock screen: uncheck
  * Start:
    * Show recently added apps: disable
    * Show recently opened items: disable
    * Show tips: disable
  * Taskbar:
    * Taskbar Apps: Disable search/taskview/widgets/chat
    * Other System Tray Icons:
      * Hidden icon menu: disable
  * Apps:
    * Startup: disable all
* Accounts:
  * Sign-in options:
    * Facial Recognition (must be on laptop)
    * Fingerprint (must be on laptop)
* Time & Language:
  * Date & Time:
    * Set time zone automatically
  * Language & Region: Regional Format: change all to yyyy-mm-dd + 24-hour time
* Privacy & Security: For Developers: Show extensions & hidden files
  * Windows Update:
    * Advanced Options: Notify when restart is required
    * Windows insider program: Join - beta channel

## Other Settings
* https://superuser.com/questions/1680130/windows-11-taskbar-corner-overflow-show-all-tray-icons
* delete ShellNew registry keys for .bmp and .zip
* unpin all apps from taskbar + start menu
* in Nvidia Control Panel --> Desktop:
  * Add Desktop Context Menu: uncheck
  * Show Notification Tray Icon: uncheck
* Fix Window clock
  * In Registry Editor navigate to the following location:
  * Create new DWORD: RealTimeIsUniversal
  * Change value from 0 to 1
```
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
```
