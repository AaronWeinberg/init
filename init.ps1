### Modules ###
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) # install Chocolatey if not already installed
Install-Module -Name PSWindowsUpdate -Force
wsl --install
winget list --accept-source-agreements # installs winget

# Winget #
winget install Google.Chrome --accept-package-agreements
winget install Mozilla.Firefox --accept-package-agreements
winget install Logitech.GHUB --accept-package-agreements
winget install Valve.Steam --accept-package-agreements
winget install Microsoft.VisualStudioCode --accept-package-agreements
winget install Dell.CommandUpdate --accept-package-agreements
winget install Balena.Etcher --accept-package-agreements
winget install 9NBLGGH4MSV6 --accept-package-agreements # Ubuntu

### Bloatware ###
winget uninstall "Cortana"
winget uninstall "Disney+"
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
winget uninstall "Spotify Music"
winget uninstall "Windows Alarms & Clock"
winget uninstall "Windows Camera"
winget uninstall "Windows Maps"
winget uninstall "Windows Voice Recorder"
winget uninstall "Xbox"
winget uninstall "Xbox Game Bar"
winget uninstall "Xbox Game Bar Plugin"
winget uninstall "Xbox Game Speech Window"
winget uninstall "Xbox Identity Provider"
winget uninstall "Xbox TCUI"
winget uninstall "Your Phone"
