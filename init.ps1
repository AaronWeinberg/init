# modules #
Install-Module -Name PSWindowsUpdate -Force
wsl --install
winget list --accept-source-agreements # installs winget
## add 'update' module
Import-Module update -Force

# .ssh #
ssh-keygen -t ed25519 -C 'aaron.weinberg@gmail.com'

# powershell + terminal config/scripts #
curl 'https://raw.githubusercontent.com/AaronWeinberg/init/master/config/win/settings.json' | out-file -Path C:\Users\aaron\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

# ctrl2cap #
Start-Process -Path 'https://download.sysinternals.com/files/Ctrl2Cap.zip' # download ctrl2cap
Expand-Archive -Path C:\Users\aaron\Downloads\Ctrl2Cap.zip -DestinationPath C:\Users\aaron\Downloads\Ctrl2Cap -Force # unzip ctrl2cap
cd C:\Users\aaron\Downloads\Ctrl2Cap
cmd.exe --% /c ctrl2cap /install # install ctrl2cap

# winget #
winget install Canonical.Ubuntu --accept-package-agreements
winget install Dell.CommandUpdate --accept-package-agreements
winget install Git.Git --accept-package-agreements
winget install Google.Chrome --accept-package-agreements
winget install Microsoft.PowerShell --accept-package-agreements
winget install Microsoft.VisualStudioCode --accept-package-agreements
winget install Mozilla.Firefox --accept-package-agreements
winget install OpenJS.NodeJS.LTS --accept-package-agreements
winget install Valve.Steam --accept-package-agreements

# settings #

SCHTASKS /CREATE /SC DAILY /TN 'AutoUpdate' /TR 'powershell.exe -file C:\Users\aaron\OneDrive\Documents\PowerShell\Scripts\update.ps1' /ST 00:00 /RU 'NT AUTHORITY\SYSTEM' /RL HIGHEST # create autoUpdate task

# TODO: empty recycle bin automatically
# TODO: reload terminal so npm works
# npm -g #
npm i -g eslint eslint-config-prettier prettier npm-check-updates typescript

# git #
git config --global user.name "Aaron Weinberg"
git config --global user.email "aaron.weinberg@gmail.com"

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
winget uninstall 'Your Phone'
winget uninstall Microsoft.Paint_8wekyb3d8bbwe
winget uninstall Microsoft.WindowsNotepad_8wekyb3d8bbwe
winget uninstall RivetNetworks.KillerControlCenter_rh07ty8m5nkag
winget uninstall NVIDIACorp.NVIDIAControlPanel_56jybvy8sckqj
winget uninstall MozillaMaintenanceService
winget uninstall WavesAudio.MaxxAudioProforDell2020_fh4rh281wavaa

# windows update #
Get-Command -Module PSWindowsUpdate | Out-Null
Install-WindowsUpdate -AcceptAll # windows update -no prompt -no auto-restart
