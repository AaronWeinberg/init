#!/bin/bash

### ### ### ### ### ### ###
#  Initial Windows Setup  #
### ### ### ### ### ### ###

$ROOT='C:\Users\aaron\'
$githubBaseUrl = "https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/"
$githubScriptUrl = "$githubBaseUrl/scripts/"
$githubConfigUrl = "$githubBaseUrl/dotfiles/"

# modules #
  Install-PackageProvider -Name NuGet -Force
  Install-Module -Name PSWindowsUpdate -Force
  wsl --install
  winget list --accept-source-agreements # installs winget

# winget #
  ## utility
  winget install "Balena.Etcher" --accept-package-agreements
  winget install "Chocolatey" --accept-package-agreements
  winget install "Dell.CommandUpdate" --accept-package-agreements
  winget install "GIMP.GIMP" --accept-package-agreements
  winget install "Google Chrome" --accept-package-agreements
  winget install "Microsoft.PowerShell.Preview" --accept-package-agreements
  winget install "Microsoft Visual Studio Code" --accept-package-agreements
  winget install "Mozilla.Firefox" --accept-package-agreements
  winget install "Ubuntu" --accept-package-agreements
  winget install "Wireguard.Wireguard" --accept-package-agreements
  ## gaming
  #winget install "Battle.net" --accept-package-agreements
  winget install "Valve.Steam" --accept-package-agreements
  ## peripherals
  winget install "7-Zip" # archiver for Nvidia driver script
  winget install "Razer Synapse 3" --accept-package-agreements

# chocolatey #
  choco install vim -y
  
# bloatware #
  winget uninstall 'Clipchamp'
  winget uninstall 'Cortana'
  winget uninstall 'Feedback Hub'
  winget uninstall 'Get Help'
  winget uninstall 'Mail and Calendar'
  winget uninstall 'Microsoft Bing Search'
  winget uninstall 'Microsoft Family'
  winget uninstall 'Microsoft.GamingApp_8wekyb3d8bbwe'
  winget uninstall 'Microsoft News'
  winget uninstall 'Microsoft People'
  winget uninstall 'Microsoft Sticky Notes'
  winget uninstall 'Microsoft Teams'
  winget uninstall 'Microsoft Tips'
  winget uninstall 'Microsoft To Do'
  winget uninstall 'Movies & TV'
  winget uninstall 'MSN Weather'
  winget uninstall 'NVIDIA Control Panel'
  winget uninstall 'Office'
  winget uninstall 'Outlook For Windows'
  winget uninstall 'Phone Link'
  winget uninstall 'Power Automate'
  winget uninstall 'Quick Assist'
  winget uninstall 'Solitaire & Casual Games'
  winget uninstall 'Spotify Music'
  winget uninstall 'Windows Camera'
  winget uninstall 'Windows Clock'
  winget uninstall 'Windows Maps'
  winget uninstall 'Windows Voice Recorder'
  winget uninstall 'Xbox Game Bar'
  winget uninstall 'Xbox Game Bar Plugin'
  winget uninstall 'Xbox Game Speech Window'
  winget uninstall 'Xbox Identity Provider'

# settings #
  Remove-Item -Path "HKLM:\SOFTWARE\Classes\.zip\CompressedFolder\ShellNew" -Recurse # remove .zip from context menu
  Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace_41040327\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" -ErrorAction SilentlyContinue # remove Gallery from explorer
  sc config NVDisplay.ContainerLocalSystem start= disabled # disable Nvidia Display Container

  ## RealTimeIsUniversal ##
  $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
  $Name = "RealTimeIsUniversal"
  $value = "1"
  if (!(Test-Path $registryPath)) { # if the path doesn't exist, create the key
      New-Item -Path $registryPath -Force | Out-Null
  }
  New-ItemProperty -Path $registryPath -Name $Name -Value $value -PropertyType DWORD -Force | Out-Null # set the value

  ## ctrl2cap ##
    $url = 'https://download.sysinternals.com/files/Ctrl2Cap.zip' # url of ctrl2cap
    $zipFile = "$ROOT\Downloads\Ctrl2Cap.zip" # path to zipped file
    $extractPath = "$ROOT\Downloads\Ctrl2Cap" # path to unzipped file
    
    Invoke-WebRequest -Uri $url -OutFile $zipFile # download ctrl2cap
    Expand-Archive -LiteralPath $zipFile -DestinationPath $extractPath -Force # unzip
    Set-Location -Path $extractPath # change directory to ctrl2cap
    cmd.exe --% /c ctrl2cap /install
    Set-Location -Path $ROOT # change directory away from ctrl2cap
    Remove-Item -Path $zipFile -Force # delete zip
    Remove-Item -Path $extractPath -Force -Recurse # delete unzipped

  ## terminal ##
    $settingsUrl = "$githubConfigUrl\settings.json" # URL of settings.json file on GitHub
    $settingsFile = "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" # path to the default settings.json file

    Remove-Item $settingsFile -ErrorAction SilentlyContinue # delete settings.json if it exists
    Invoke-WebRequest -Uri $settingsUrl -OutFile $settingsFile # download the settings.json file from the GitHub

  ## powershell ##
    $powershellPath = "$ROOT\Documents\PowerShell" # path to PowerShell

    ### nvidia script ###
    $nvidiaUrl = "$githubScriptUrl\nvidia.ps1" # URL of nvidia.ps1 file on GitHub
    $nvidiaPath = "$powershellPath\Scripts\nvidia" # path to nvidia script directory
    $nvidiaFile = "$nvidiaPath\nvidia.ps1" # path to nvidia script

    Remove-Item $nvidiaFile -ErrorAction SilentlyContinue # delete nvidia script if it exists
    New-Item -ItemType Directory -Force -Path $nvidiaPath # create script dir
    Invoke-WebRequest -Uri $nvidiaUrl -OutFile $nvidiaPath # download nvidia script from GitHub
    
    ### update module ###
    $updateUrl = "$githubScriptUrl\update.psm1" # URL of update.psm1 file on GitHub
    $updatePath = "$powershellPath\Modules\update" # path to update module directory
    $updateFile = "$updatePath\update.psm1" # path to update module
    
    Remove-Item $updateFile -ErrorAction SilentlyContinue # delete update module if it exists
    New-Item -ItemType Directory -Force -Path $updatePath # create module dir
    Invoke-WebRequest -Uri $updateUrl -OutFile $updatePath # download update module from GitHub
    Import-Module update # install update module
      
    ### profile ###
    $profileUrl = "$githubConfigUrl\Microsoft.PowerShell_profile.ps1" # URL of profile on GitHub
    $profileFile = "$powershellPath\Microsoft.PowerShell_profile.ps1" # path to profile
    
    Remove-Item $profileFile -ErrorAction SilentlyContinue # delete profile if it exists
    New-Item -ItemType Directory -Force -Path $powershellPath # create profile path
    Invoke-WebRequest -Uri $profileUrl -OutFile $profileFile # download profile from GitHub

# windows update #
  Get-Command -Module PSWindowsUpdate | Out-Null
  Install-WindowsUpdate -AcceptAll # windows update -no prompt -no auto-restart
