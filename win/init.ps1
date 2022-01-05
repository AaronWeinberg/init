# modules #
Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) # install Chocolatey if not already installed
choco feature enable -n=allowGlobalConfirmation # enable chocolatey global confirm
Install-Module -Name PSWindowsUpdate -Force
wsl --install
winget list --accept-source-agreements # installs winget

# dev path #
mkdir C:\Users\aaron\Development

# .ssh #
ssh-keygen -t ed25519 -C 'aaron.weinberg@.com'

# powershell + terminal config/scripts #
New-Item -Path 'C:\Users\aaron\Documents\PowerShell\Scripts' -ItemType Directory
curl 'https://raw.githubusercontent.com/AaronWeinberg/init/master/win/Microsoft.PowerShell_profile.ps1' | out-file -Path C:\Users\aaron\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
curl 'https://raw.githubusercontent.com/AaronWeinberg/init/master/win/update.ps1' | out-file -Path C:\Users\aaron\Documents\PowerShell\Scripts\update.ps1
curl 'https://raw.githubusercontent.com/AaronWeinberg/init/master/win/settings.json' | out-file -Path C:\Users\aaron\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
curl 'https://raw.githubusercontent.com/AaronWeinberg/init/master/lin/.eslintrc' | out-file -Path C:\Users\aaron\.eslintrc
curl 'https://raw.githubusercontent.com/AaronWeinberg/init/master/lin/.prettierrc' | out-file -Path C:\Users\aaron\.prettierrc

# ctrl2cap #
Start-Process -Path 'https://download.sysinternals.com/files/Ctrl2Cap.zip' # download ctrl2cap
Expand-Archive -Path C:\Users\aaron\Downloads\Ctrl2Cap.zip -DestinationPath C:\Users\aaron\Downloads\Ctrl2Cap -Force # unzip ctrl2cap
cd C:\Users\aaron\Downloads\Ctrl2Cap
cmd.exe --% /c ctrl2cap /install # install ctrl2cap

# settings #
SCHTASKS /CREATE /SC DAILY /TN 'AutoUpdate' /TR 'powershell.exe -file C:\Users\aaron\Documents\PowerShell\Scripts\update.ps1' /ST 00:00 /RU 'NT AUTHORITY\SYSTEM' /RL HIGHEST # create autoUpdate task
choco feature enable -n=allowGlobalConfirmation # enable chocolatey global confirm

# chocolatey #
choco upgrade chocolatey
choco install firacode
choco install nvidia-display-driver
choco upgrade nvidia-display-driver

# winget #
winget install Google.Chrome --accept-package-agreements
winget install Git.Git --accept-package-agreements
winget install OpenJS.NodeJS.LTS --accept-package-agreements
winget install Mozilla.Firefox --accept-package-agreements
winget install Logitech.GHUB --accept-package-agreements
winget install Valve.Steam --accept-package-agreements
winget install Microsoft.VisualStudioCode --accept-package-agreements
winget install Dell.CommandUpdate --accept-package-agreements
winget install Balena.Etcher --accept-package-agreements
winget install AntoineAflalo.SoundSwitch --accept-package-agreements
winget install 9NBLGGH4MSV6 --accept-package-agreements # Ubuntu
winget install 9MZ1SNWT0N5D --accept-package-agreements # Powershell

# TODO: reload terminal so npm works
# npm -g #
npm i -g eslint prettier npm-check-updates

# bloatware #
winget uninstall 'Cortana'
winget uninstall 'Feedback Hub'
winget uninstall 'Get Help'
winget uninstall 'Groove Music'
winget uninstall 'Killer Control Center'
winget uninstall 'Mail and Calendar'
winget uninstall 'Microsoft News'
winget uninstall 'Microsoft OneDrive'
winget uninstall 'Microsoft People'
winget uninstall 'Microsoft Solitaire Collection'
winget uninstall 'Microsoft Sticky Notes'
winget uninstall 'Microsoft Teams'
winget uninstall 'Microsoft Tips'
winget uninstall 'Microsoft To Do'
winget uninstall 'Movies & TV'
winget uninstall 'MSN Weather'
winget uninstall 'Office'
winget uninstall 'OneDrive'
winget uninstall 'Power Automate'
winget uninstall 'Windows Alarms & Clock'
winget uninstall 'Windows Camera'
winget uninstall 'Windows Maps'
winget uninstall 'Windows Voice Recorder'
winget uninstall 'Xbox'
winget uninstall 'Xbox Game Bar Plugin'
winget uninstall 'Xbox Game Speech Window'
winget uninstall 'Xbox Identity Provider'
winget uninstall 'Xbox TCUI'
winget uninstall 'Your Phone'

# windows update #
Get-Command -Module PSWindowsUpdate | Out-Null
Install-WindowsUpdate -AcceptAll # windows update -no prompt -no auto-restart
