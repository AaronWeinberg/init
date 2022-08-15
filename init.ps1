$ROOT='C:/Users/aaron/'

# modules #
Install-Module -Name PSWindowsUpdate -Force
wsl --install
winget list --accept-source-agreements # installs winget
Import-Module update -Force # add 'update' module ### run after opening oneDrive

# ctrl2cap #
Start-Process -FilePath 'https://download.sysinternals.com/files/Ctrl2Cap.zip'
sleep 5 # wait for download to finish
Expand-Archive -LiteralPath $ROOT\Downloads\Ctrl2Cap.zip -DestinationPath $ROOT\Downloads\Ctrl2Cap -Force # unzip
sleep 5 # wait for unzip to finish
cd $ROOT\Downloads\Ctrl2Cap
cmd.exe --% /c ctrl2cap /install

# winget #
winget install "Canon Inkjet Print Utility" --accept-package-agreements
winget install "Dell Command | Update" --accept-package-agreements
winget install "GIMP" --accept-package-agreements
winget install "Google Chrome" --accept-package-agreements
winget install "PowerShell" --accept-package-agreements
winget install 'Microsoft OneDrive' --accept-package-agreements
winget install "Microsoft Visual Studio Code" --accept-package-agreements
winget install "Mozilla Firefox Browser" --accept-package-agreements
winget install "Valve.Steam" --accept-package-agreements
winget install "Ubuntu" --accept-package-agreements
# gaming
winget install "Battle.net" --accept-package-agreements
winget install "Discord" --accept-package-agreements
winget install "Overworld.CurseForge" --accept-package-agreements

# TODO: empty recycle bin automatically
# auto update #
# SCHTASKS /CREATE /SC DAILY /TN 'AutoUpdate' /TR 'powershell.exe -file C:\Users\aaron\OneDrive\Documents\PowerShell\Scripts\update.ps1' /ST 00:00 /RU 'NT AUTHORITY\SYSTEM' /RL HIGHEST # create autoUpdate task

# bloatware #
winget uninstall 'Clipchamp'
winget uninstall 'Cortana'
winget uninstall 'Feedback Hub'
winget uninstall 'Get Help'
winget uninstall 'Groove Music' # Windows Home only
winget uninstall 'Killer Control Center' # Windows Home only
winget uninstall 'Killer Intelligence Center'
winget uninstall 'Mail and Calendar'
winget uninstall 'Microsoft News'
winget uninstall 'Microsoft People'
winget uninstall 'Microsoft Solitaire Collection'
winget uninstall 'Microsoft Sticky Notes'
winget uninstall 'Microsoft Teams'
winget uninstall 'Microsoft Tips'
winget uninstall 'Microsoft To Do'
winget uninstall 'Movies & TV' # Windows Home only
winget uninstall 'Mozilla Maintenance Service'
winget uninstall 'MSN Weather'
winget uninstall 'NVIDIA Control Panel'
winget uninstall 'Office'
winget uninstall 'Paint'
winget uninstall 'Power Automate'
winget uninstall 'Quick Assist'
winget uninstall 'Waves MaxxAudio Pro for Dell 2020'
winget uninstall 'Windows Alarms & Clock'
winget uninstall 'Windows Camera'
winget uninstall 'Windows Maps'
winget uninstall 'Windows Voice Recorder' # Windows Home only
winget uninstall 'Xbox'
winget uninstall 'Xbox Game Bar Plugin'
winget uninstall 'Xbox Game Speech Window'
winget uninstall 'Xbox Identity Provider'
winget uninstall 'Your Phone'

# windows update #
Get-Command -Module PSWindowsUpdate | Out-Null
Install-WindowsUpdate -AcceptAll # windows update -no prompt -no auto-restart
