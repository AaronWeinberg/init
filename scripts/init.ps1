#!/bin/bash

### ### ### ### ### ### ###
#  Initial Windows Setup  #
### ### ### ### ### ### ###

$githubBaseUrl = "https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/"
$githubScriptUrl = "$githubBaseUrl/scripts/"
$githubConfigUrl = "$githubBaseUrl/dotfiles/"

# modules #
  install-packageprovider -force -name NuGet
  install-module -force -name PSWindowsUpdate
  wsl --install
  winget list --accept-source-agreements # installs winget

# winget #
  ## utility
  winget add "Balena.Etcher" --accept-package-agreements
  winget add "Chocolatey" --accept-package-agreements
  winget add "Dell.CommandUpdate" --accept-package-agreements
  winget add "GIMP.GIMP" --accept-package-agreements
  winget add "Git" --accept-package-agreements
  winget add "Google Chrome" --accept-package-agreements
  winget add "Microsoft.PowerShell.Preview" --accept-package-agreements
  winget add "Microsoft Visual Studio Code" --accept-package-agreements
  winget add "Mozilla.Firefox" --accept-package-agreements
  winget add "Node" --accept-package-agreements
  winget add "Ubuntu" --accept-package-agreements
  winget add "Wireguard.Wireguard" --accept-package-agreements
  ## gaming
  #winget add "Battle.net" --accept-package-agreements
  winget add "Valve.Steam" --accept-package-agreements
  ## peripherals
  winget add "7-Zip" # archiver for Nvidia driver script
  winget add "Razer Synapse 3" --accept-package-agreements

# chocolatey #
  choco install vim -y
  
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
  winget rm 'Microsoft People'
  winget rm 'Microsoft Sticky Notes'
  winget rm 'Microsoft Teams'
  winget rm 'Microsoft Tips'
  winget rm 'Microsoft To Do'
  winget rm 'Movies & TV'
  winget rm 'MSN Weather'
  winget rm 'NVIDIA Control Panel'
  winget rm 'Office'
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

# settings #
  rm -r "HKLM:\SOFTWARE\Classes\.zip\CompressedFolder\ShellNew" # remove .zip from context menu
  rm -r -ea 0 "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace_41040327\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" # remove Gallery from explorer
  sc config NVDisplay.ContainerLocalSystem start= disabled # disable Nvidia Display Container

  ## RealTimeIsUniversal ##
  $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
  $Name = "RealTimeIsUniversal"
  $value = "1"
  if (!(test-path $registryPath)) { # if the path doesn't exist, create the key
    mkdir -force $registryPath
  }
  New-ItemProperty -path $registryPath -name $Name -Value $value -PropertyType DWORD -force | Out-Null # set the value

  ## ctrl2cap ##
    $url = 'https://download.sysinternals.com/files/Ctrl2Cap.zip' # url of ctrl2cap
    $zipFile = "~\Downloads\Ctrl2Cap.zip" # path to zipped file
    $extractPath = "~\Downloads\Ctrl2Cap" # path to unzipped file
    
    iwr -uri $url -outfile $zipFile # download ctrl2cap
    Expand-Archive -literalpath $zipFile -destinationpath $extractPath -force # unzip
    cd $extractPath # change directory to ctrl2cap
    cmd.exe --% /c ctrl2cap /install
    cd ~ # change directory away from ctrl2cap
    rm -ea 0 -force $zipFile # delete zip
    rm -r -ea 0 -force $extractPath # delete unzipped

  ## terminal ##
    $settingsUrl = "$githubConfigUrl\settings.json" # URL of settings.json file on GitHub
    $settingsFile = "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" # path to the default settings.json file

    rm -ea 0 $settingsFile # delete settings.json if it exists
    iwr -uri $settingsUrl -outfile $settingsFile # download the settings.json file from the GitHub

  ## powershell ##
    $powershellPath = "~\Documents\PowerShell" # path to PowerShell

    rm -force -ea 0 "~\.gitconfig; iwr -uri

    ### nvidia script ###
    $nvidiaUrl = "$githubScriptUrl\nvidia.ps1" # URL of nvidia.ps1 file on GitHub
    $nvidiaPath = "$powershellPath\Scripts\nvidia" # path to nvidia script directory
    $nvidiaFile = "$nvidiaPath\nvidia.ps1" # path to nvidia script

    rm -ea 0 $nvidiaFile # delete nvidia script if it exists
    mkdir -ea 0 $nvidiaPath # create script dir
    iwr -uri $nvidiaUrl -outfile $nvidiaPath # download nvidia script from GitHub
    
    ### update module ###
    $updateUrl = "$githubScriptUrl\update.psm1" # URL of update.psm1 file on GitHub
    $updatePath = "$powershellPath\Modules\update" # path to update module directory
    $updateFile = "$updatePath\update.psm1" # path to update module
    
    rm -ea 0 $updateFile # delete update module if it exists
    mkdir -ea 0 $updatePath # create module dir
    iwr -uri $updateUrl -outfile $updatePath # download update module from GitHub
    ipmo update # install update module
      
    ### profile ###
    $profileUrl = "$githubConfigUrl\Microsoft.PowerShell_profile.ps1" # URL of profile on GitHub
    $profileFile = "$powershellPath\Microsoft.PowerShell_profile.ps1" # path to profile
    
    rm -ea 0 $profileFile # delete profile if it exists
    mkdir -ea 0 $powershellPath # create profile path
    iwr -uri $profileUrl -outfile $profileFile # download profile from GitHub

# windows update #
  gcm -Module PSWindowsUpdate | Out-Null
  install-windowsupdate -acceptall # windows update -no prompt -no auto-restart
