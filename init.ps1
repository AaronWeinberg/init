### Modules ###

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) # install Chocolatey if not already installed
Install-Module -Name PSWindowsUpdate -Force
wsl --install
winget list --accept-source-agreements # installs winget


### Bloatware ###

winget uninstall "Cortana"
winget uninstall "Feedback Hub"
winget uninstall "Get Help"
winget uninstall "Groove Music"
winget uninstall "Killer Control Center"
winget uninstall "Mail and Calendar"
winget uninstall "Microsoft News"
winget uninstall "Microsoft OneDrive"
winget uninstall "Microsoft People"
winget uninstall "Microsoft Solitaire Collection"
winget uninstall "Microsoft Sticky Notes"
winget uninstall "Microsoft Teams"
winget uninstall "Microsoft Tips"
winget uninstall "Microsoft To Do"
winget uninstall "Movies & TV"
winget uninstall "MSN Weather"
winget uninstall "Office"
winget uninstall "OneDrive"
winget uninstall "Power Automate"
winget uninstall "Windows Alarms & Clock"
winget uninstall "Windows Camera"
winget uninstall "Windows Maps"
winget uninstall "Windows Voice Recorder"
winget uninstall "Xbox"
winget uninstall "Xbox Game Bar Plugin"
winget uninstall "Xbox Game Speech Window"
winget uninstall "Xbox Identity Provider"
winget uninstall "Xbox TCUI"
winget uninstall "Your Phone"


### Desktop Applications ###

## Browsers ##
<# Brave #>       Start-Process "https://brave.com/download/"
<# Chrome #>      Start-Process "https://www.google.com/chrome/"
<# Firefox #>     Start-Process "https://www.mozilla.org/en-US/firefox/"

## Gaming ##
<# Steam #>       Start-Process "https://store.steampowered.com/about/"

## Peripherals ##
<# SoundSwitch #> Start-Process "https://github.com/Belphemur/SoundSwitch/releases/download/v6.1.0/SoundSwitch_v6.1.0.19729_Release_Installer.exe"
<# WD19 Dock #>   Start-Process "https://www.dell.com/support/home/en-us/product-support/product/dell-wd19tb-dock/drivers"
<# LGhub #>       Start-Process "https://www.logitechg.com/en-us/innovation/g-hub.html"

## Setup ##
<# Ctrl2Cap #>    Start-Process "https://docs.microsoft.com/en-us/sysinternals/downloads/ctrl2cap"
<# Dell Update #> Start-Process "https://www.dell.com/support/home/en-us/drivers/DriversDetails?driverId=GRVPK"
<# PwshUpdate #>  Start-Process "https://4bes.nl/2019/06/30/get-pwshupdates-check-if-there-is-a-powershell-update-available-and-install-it/"
<# Veracrypt #>   Start-Process "https://sourceforge.net/projects/veracrypt/files/latest/download"
<# VS Code #>     Start-Process "https://code.visualstudio.com/docs/?dv=win"
