$ROOT='C:/Users/aaron/'

# modules #
Install-Module -Name PSWindowsUpdate -Force
wsl --install
winget list --accept-source-agreements # installs winget

# wsl clock sync task #
schtasks /create /tn WSLClockSync /tr "wsl.exe sudo hwclock -s" /sc onevent /ec system /mo "*[System[Provider[@Name='Microsoft-Windows-Kernel-General'] and (EventID=1)]]"
Set-ScheduledTask WSLClockSync -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries)

# dotfiles #
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/AaronWeinberg/init/master/dotfiles/.bashrc' -OutFile 'C:\Users\aaron\.wslconfig'

# ctrl2cap #
Start-Process -FilePath 'https://download.sysinternals.com/files/Ctrl2Cap.zip'
sleep 5 # wait for download to finish
Expand-Archive -LiteralPath $ROOT\Downloads\Ctrl2Cap.zip -DestinationPath $ROOT\Downloads\Ctrl2Cap -Force # unzip
sleep 5 # wait for unzip to finish
cd $ROOT\Downloads\Ctrl2Cap
cmd.exe --% /c ctrl2cap /install

# winget #
## utility
winget install "Balena.Etcher" --accept-package-agreements
winget install "Dell.CommandUpdate.Universal" --accept-package-agreements
winget install "GIMP.GIMP" --accept-package-agreements
winget install "Google Chrome" --accept-package-agreements
winget install "PowerShell" --accept-package-agreements
winget install "Microsoft Visual Studio Code" --accept-package-agreements
winget install "Mozilla.Firefox" --accept-package-agreements
winget install "Ubuntu" --accept-package-agreements
## gaming
winget install "Valve.Steam" --accept-package-agreements
## peripherals
winget install "Logitech.GHUBT" --accept-package-agreements
winget install "Razer Synapse" --accept-package-agreements
winget install "Canon Inkjet Print Utility" --accept-package-agreements

# bloatware #
winget uninstall 'Clipchamp'
winget uninstall 'Cortana'
winget uninstall 'Dell SupportAssist OS Recovery for Dell Update'
winget uninstall 'Feedback Hub'
winget uninstall 'Get Help'
winget uninstall 'Mail and Calendar'
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
winget uninstall 'Paint'
winget uninstall 'Phone Link'
winget uninstall 'Power Automate'
winget uninstall 'Quick Assist'
winget uninstall 'Solitaire and Casual Games'
winget uninstall 'Spotify Music'
winget uninstall 'Waves MaxxAudio Pro for Dell 2020'
winget uninstall 'Windows Camera'
winget uninstall 'Windows Clock'
winget uninstall 'Windows Maps'
winget uninstall 'Windows Voice Recorder'
winget uninstall 'Xbox Game Bar'
winget uninstall 'Xbox Game Bar Plugin'
winget uninstall 'Xbox Game Speech Window'
winget uninstall 'Xbox Identity Provider'
winget uninstall 'Your Phone'

# windows update #
Get-Command -Module PSWindowsUpdate | Out-Null
Install-WindowsUpdate -AcceptAll # windows update -no prompt -no auto-restart
