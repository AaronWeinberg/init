#                   Linux                         #
(On Ubuntu Desktop) GNOME Shell Integration extensions:
1. App Icons Taskbar
2. Autohide Battery
3. Autohide Volume
4. DDTERM
5. Just Perfection

```

wget https://raw.githubusercontent.com/AaronWeinberg/init/master/init.sh && sudo chmod +x init.sh && ./init.sh && rm init.sh

```
- In ~/.ssh/config --> replace <box1 ip> with VPS ip
- In ~/.ssh/ --> ssh keys to public and private key files

#                    Windows                      #
* Windows updates (several restarts)
* Microsoft Store -> update all apps
 
 ## Powershell

```

Set-ExecutionPolicy Unrestricted; (Invoke-webrequest -URI "https://raw.githubusercontent.com/AaronWeinberg/init/master/init.ps1").Content | out-file -filepath init.ps1; .\init.ps1; rm init.ps1

```
 
## Settings App:
### System:
* Display: Night light: on
* Notifications:
  * Notifications: disable
  * Notifications from apps: disable all
  * Offer suggestions: disable
* Multitasking:
  * Alt + Tab: Open windows only
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
  * Taskbar:
    * Taskbar Apps: Disable search/taskview/widgets/chat
    * Other System Tray Icons:
      * Hidden icon menu: disable
      * Safely Remove Hardware: disable
      * Nvidia Container
      * Bluetooth: disable
      * Windows Security notification: disable
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
* Fix Window clock. In Registry Editor:

```
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
Create new DWORD: RealTimeIsUniversal
change value from 0 to 1
```
