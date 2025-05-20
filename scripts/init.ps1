#!/bin/bash

### ### ### ### ### ### ###
#  Initial Windows Setup  #
### ### ### ### ### ### ###

$configDir = "~\.config"
$baseUrl = "https://raw.githubusercontent.com/AaronWeinberg/init/master"
$githubScriptUrl = "$baseUrl/scripts/"
$githubConfigUrl = "$baseUrl/dotfiles/"

# windows update #
install-module -force -name PSWindowsUpdate
gcm -module PSWindowsUpdate | out-null
install-windowsupdate -acceptall # windows update -no prompt -no auto-restart

# winget #
winget list --accept-source-agreements # installs winget

  ## dev
  winget add "GIMP.GIMP" --accept-package-agreements
  winget add "Helix.Helix" --accept-package-agreements
  winget add "Microsoft Visual Studio Code" --accept-package-agreements

  ## gaming
  winget add "Battle.net" --accept-package-agreements
  winget add "Overwolf.CurseForge" --accept-package-agreements
  winget add "Wago.Addons" --accept-package-agreements
  winget add "Valve.Steam" --accept-package-agreements
  
  ## peripherals
  winget add "Logitech G HUB" --accept-package-agreements

  ## utility
  winget add "Balena.Etcher" --accept-package-agreements
  winget add "Dell.CommandUpdate" --accept-package-agreements
  winget add "Google.Chrome" --accept-package-agreements
  winget add "Mozilla.Firefox" --accept-package-agreements
  winget add "Wireguard.Wireguard" --accept-package-agreements
  
# bloatware #
winget rm 'Clipchamp'
winget rm 'Cortana'
winget rm 'Feedback Hub'
winget rm 'Get Help'
winget rm 'Mail and Calendar'
winget rm 'Microsoft Bing Search'
winget rm 'Microsoft Family'
winget rm 'Microsoft.GamingApp_8wekyb3d8bbwe'
winget rm 'Microsoft News'
winget rm 'Microsoft OneDrive'
winget rm 'Microsoft People'
winget rm 'Microsoft Sticky Notes'
winget rm 'Microsoft Teams'
winget rm 'Microsoft Tips'
winget rm 'Microsoft To Do'
winget rm 'Movies & TV'
winget rm 'MSN Weather'
winget rm 'NVIDIA Control Panel'
winget rm 'Office'
winget rm 'OneDrive'
winget rm 'Outlook For Windows'
winget rm 'Phone Link'
winget rm 'Power Automate'
winget rm 'Quick Assist'
winget rm 'Solitaire & Casual Games'
winget rm 'Spotify Music'
winget rm 'Windows Camera'
winget rm 'Windows Clock'
winget rm 'Windows Maps'
winget rm 'Windows Voice Recorder'
winget rm 'Xbox Game Bar'
winget rm 'Xbox Game Bar Plugin'
winget rm 'Xbox Game Speech Window'
winget rm 'Xbox Identity Provider'

# Disable Nvidia container service
sc.exe config "NVDisplay.ContainerLocalSystem" start= disabled
sc.exe stop "NVDisplay.ContainerLocalSystem"

# settings #
wsl --install
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /f # remove Gallery from explorer

  ## dotfiles ##
  curl "$githubConfigUrl\settings.json" -o "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" # create or replace settings.json
  curl "$githubConfigUrl/config.toml" -o ~\AppData\Roaming\helix\config.toml

  ## RealTimeIsUniversal ##
  $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
  mkdir -force "$registryPath"
  New-ItemProperty -path "$registryPath" -name "RealTimeIsUniversal" -Value 1 -PropertyType DWORD -force | Out-Null

  ## ctrl2cap ##
  $extractPath = "~\Downloads\Ctrl2Cap" # path to unzipped file
  $zipFile = "$extractPath.zip" # path to zipped file
  
  curl "https://download.sysinternals.com/files/Ctrl2Cap.zip" -o "$zipFile" # download ctrl2cap
  Expand-Archive -literalpath "$zipFile" -destinationpath "$extractPath" -force # unzip
  cd "$extractPath" # change directory to ctrl2cap
  cmd.exe --% /c ctrl2cap /install
  cd ~ # change directory away from ctrl2cap
  rm -ea 0 -force "$zipFile"; rm -r -ea 0 -force "$extractPath" # delete Ctrl2Cap files

  ## disable tips and tricks on the lock screen ##
    # Set the path
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    
    # Set ContentDeliveryAllowed to 1
    Set-ItemProperty -Path $path -Name "ContentDeliveryAllowed" -Value 1
    
    # Set RotatingLockScreenEnabled to 1
    Set-ItemProperty -Path $path -Name "RotatingLockScreenEnabled" -Value 1
    
    # Set RotatingLockScreenOverlayEnabled to 0
    Set-ItemProperty -Path $path -Name "RotatingLockScreenOverlayEnabled" -Value 0
    
    # Set SubscribedContent-338387Enabled to 0
    Set-ItemProperty -Path $path -Name "SubscribedContent-338387Enabled" -Value 0

  ## powershell ##
  $powershellPath = "C:\Users\aaron\OneDrive\Documents\WindowsPowerShell" # path to PowerShell
    
    ### update module ###
    $updateUrl = "$githubScriptUrl\update.psm1" # URL of update.psm1 file on GitHub
    $updatePath = "$powershellPath\Modules\update" # path to update module directory
    $updateFile = "$updatePath\update.psm1" # path to update module

    New-Item -Path "$powershellPath\Modules\update" -ItemType Directory -Force
    Invoke-WebRequest -Uri $updateUrl -OutFile $updateFile
    Import-Module "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\update\update.psm1" -Force # install update module
      
    ### profile ###
    $profileUrl = "$githubConfigUrl\Microsoft.PowerShell_profile.ps1" # URL of profile on GitHub
    $profileFile = "$powershellPath\Microsoft.PowerShell_profile.ps1" # path to profile
    
    curl "$profileUrl" -o "$profileFile"
