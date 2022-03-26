#                   Linux                         #
    wget https://raw.githubusercontent.com/AaronWeinberg/init/master/init.sh && sudo chmod +x init.sh && ./init.sh && rm init.sh

#                    Windows                      #
Windows updates (several restarts) \
Microsoft Store -> update all apps

open/sync OneDrive
configure/run Dell Command Update
uninstall Dell Support Assist OS Recovery
unpin all apps from taskbar
Widgets: remove unnecessary + make watchlist large
Services: Stop + disable Nvidia container service
Nvidia Control Panel:
  context menu: disable
  desktop icon: disable

Settings App:
  System:
    Display: NIght light: on
    Notifications:
      Notifications from apps: disable all
      Notifications: disable
      Offer suggestions: disable
  Bluetooth: Connect Keyboard, mouse, controller
  Personalization:
    Themes:
      Theme: dark
      Desktop Icon Settings: Recycle Bin: disable
    Lockscreen: different photo
    Start:
      Show recently added apps: disable
      Show recently opened items: disable
    Taskbar:
      Taskbar Apps: Disable search/taskview/widgets/chat
      Taskbar corner overflow: enable all
  Apps:
    Default apps:
      Chrome for web stuff
      Vscode for text stuff
    Startup: disable all
  Accounts:
    Sign-in options:
      Facial Recognition
      Fingerprint
  Time & Language:
    Date & Time:
      Set time zone automatically
      Set time automatically :toggle off - on
    Language & Region: Regional Format: change all to yyyy-mm-dd + 24-hour time
  Privacy & Security: For Developers: Show extensions & hidden files
  Windows Update:
    Advanced Options: Notify when restart is required
    Windows insider program: Join - beta channel

Taskbar:
  remove Bluetooth icon
  Windows Security notification options: disable all


    Set-ExecutionPolicy Unrestricted; (Invoke-webrequest -URI "https://raw.githubusercontent.com/AaronWeinberg/init/master/init.ps1").Content | out-file -filepath init.ps1; .\init.ps1; rm init.ps1

    (Invoke-webrequest -URI "https://raw.githubusercontent.com/AaronWeinberg/init/master/secondary.ps1").Content | out-file -filepath secondary.ps1; .\secondary.ps1;

    rm init.ps1; rm secondary.ps1;

    
