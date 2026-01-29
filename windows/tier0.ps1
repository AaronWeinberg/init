# tier0.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Assert-Admin
Start-Transcript -Path "$HOME\init\tier0.log"

Write-Host ">>> Tier 0: OS foundation"

# Windows Update
Install-PackageProvider NuGet -Force
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Install-WindowsUpdate -AcceptAll -IgnoreReboot

# System registry policies
.\policies\notifications.ps1
.\policies\updates.ps1
.\policies\explorer.ps1

# Hardware tweaks
.\hardware\ctrl2cap.ps1

Write-Warning "Tier 0 complete. Reboot strongly recommended."
Stop-Transcript
