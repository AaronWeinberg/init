# modules #
Install-Module -Name PSWindowsUpdate -Force
wsl --install
winget list --accept-source-agreements # installs winget
Import-Module update -Force # add 'update' module

# .ssh #
ssh-keygen -t ed25519 -C 'aaron.weinberg@gmail.com'

# ctrl2cap #
Start-Process -FilePath 'https://download.sysinternals.com/files/Ctrl2Cap.zip'
Expand-Archive -LiteralPath C:\Users\aaron\Downloads\Ctrl2Cap.zip -DestinationPath C:\Users\aaron\Downloads\Ctrl2Cap -Force # unzip
cd C:\Users\aaron\Downloads\Ctrl2Cap
cmd.exe --% /c ctrl2cap /install

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
winget uninstall 'Microsoft OneDrive'
winget uninstall 'Microsoft People'
winget uninstall 'Microsoft Solitaire Collection'
winget uninstall 'Microsoft Sticky Notes'
winget uninstall 'Microsoft Teams'
winget uninstall 'Microsoft Tips'
winget uninstall 'Microsoft To Do'
winget uninstall 'Movies & TV' # Windows Home only
winget uninstall 'Mozilla Maintenance Service'
winget uninstall 'MSN Weather'
winget uninstall 'NotePad'
winget uninstall 'NVIDIA Control Panel'
winget uninstall 'Office'
winget uninstall 'Paint'
winget uninstall 'Power Automate'
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
