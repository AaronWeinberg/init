# tier1.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Assert-Admin
Start-Transcript -Path "$HOME\init\tier1.log"

Write-Host ">>> Tier 1: Core tooling"

# Winget bootstrap
winget list --accept-source-agreements | Out-Null

# Dev tools
winget install --id Helix.Helix --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements

# Browsers
winget install --id Google.Chrome --accept-package-agreements --accept-source-agreements
winget install --id Mozilla.Firefox --accept-package-agreements --accept-source-agreements

# UI sanity
.\ui\darkmode.ps1
.\ui\taskbar.ps1
.\ui\explorer-visibility.ps1

# PowerShell profile
.\shell\profile.ps1

Stop-Transcript
