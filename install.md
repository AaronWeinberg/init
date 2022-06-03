#                   Linux                         #
(On Ubuntu Desktop) GNOME Shell Integration extensions:
* Audio Output Switcher
* Autohide Battery
* DDTERM
* Just Perfection

```

wget https://raw.githubusercontent.com/AaronWeinberg/init/master/init.sh && sudo chmod +x init.sh && ./init.sh && rm init.sh

```

#                    Windows                      #
* Windows updates (several restarts)
* Microsoft Store -> update all apps

* open/sync OneDrive
* delete ShellNew registry keys for .lnk and .zip
* configure/run Dell Command Update
* uninstall Dell Support Assist OS Recovery
* unpin all apps from taskbar
* Widgets: remove unnecessary + make watchlist large
* Services: Stop + disable Nvidia container service
* Nvidia Control Panel:
  1. context menu: disable
  2. desktop icon: disable

## Settings App:
### System:
* Display: NIght light: on
* Notifications:
  * Notifications from apps: disable all
  * Notifications: disable
  * Offer suggestions: disable
* Bluetooth and Devices: Devices: Connect Keyboard, mouse, controller
* Personalization:
  * Themes:
    * Theme: dark
    * Desktop Icon Settings: Recycle Bin: disable
  * Lockscreen: different photo
  * Start:
    * Show recently added apps: disable
    * Show recently opened items: disable
  * Taskbar:
    * Taskbar Apps: Disable search/taskview/widgets/chat
    * Taskbar corner overflow: enable all
    * Other System Tray Icons:
      * Hidden icon menu: disable
      * Safely Remove Hardware: disable
      * Bluetooth: disable
      * Windows Security notification: disable
  * Apps:
    * Default apps:
      * Chrome for web stuff
      * Vscode for text stuff
    * Startup: disable all
* Accounts:
  * Sign-in options:
    * Facial Recognition (must be on laptop)
    * Fingerprint (must be on laptop)
* Time & Language:
  * Date & Time:
    * Set time automatically :toggle off - on
    * Set time zone automatically
  * Language & Region: Regional Format: change all to yyyy-mm-dd + 24-hour time
* Privacy & Security: For Developers: Show extensions & hidden files
  * Windows Update:
    * Advanced Options: Notify when restart is required
    * Windows insider program: Join - beta channel

## Run from Powershell after above settings have been changed

```

Set-ExecutionPolicy Unrestricted; (Invoke-webrequest -URI "https://raw.githubusercontent.com/AaronWeinberg/init/master/init.ps1").Content | out-file -filepath init.ps1; .\init.ps1; rm init.ps1

```

Fix Window clock. In Registry Editor:

```
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
Create new DWORD: RealTimeIsUniversal
change value from 0 to 1
```
