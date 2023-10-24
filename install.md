#                   Linux                         #
Before clean install, save current settings -> override in dotfiles
```
dconf dump / > .dconf;
```
### INIT SCRIPT (bash)
```
wget https://raw.githubusercontent.com/AaronWeinberg/init/master/init.sh && sudo chmod +x init.sh && command="./init.sh"; echo $command | tee init.log; eval $command | tee -a init.log && rm init.sh
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
 
 ### INIT SCRIPT (Powershell as admin)

```
$command = 'Set-ExecutionPolicy Unrestricted; (Invoke-webrequest -URI "https://raw.githubusercontent.com/AaronWeinberg/init/master/init.ps1").Content | out-file -filepath init.ps1; .\init.ps1; rm C:\Users\aaron\init.ps1'; echo $command | Tee-Object -FilePath init.log; Invoke-Expression $command | Tee-Object -FilePath init.log -Append
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
* Printers: add printer
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
    * Documents
    * Music
    * Videos
* https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=mfcl2690dw_us
* Unpin all apps from taskbar + start menu
* In Nvidia Control Panel --> Desktop:
  * Add Desktop Context Menu: uncheck
  * Show Notification Tray Icon: uncheck
* Fix Window clock
  * In Registry Editor navigate to: Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
  * Create new DWORD: RealTimeIsUniversal
  * Change value from 0 to 1
