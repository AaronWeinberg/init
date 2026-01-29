# tier2.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Assert-Admin
Start-Transcript -Path "$HOME\init\tier2.log"

Write-Warning "Tier 2 is opinionated and destructive."

# Gaming
winget install --id Valve.Steam --accept-package-agreements --accept-source-agreements
winget install --id Blizzard.BattleNet --accept-package-agreements --accept-source-agreements

# Peripherals
winget install --id Logitech.GHUB --accept-package-agreements --accept-source-agreements

# Dotfiles
.\dotfiles\git.ps1
.\dotfiles\helix.ps1
.\dotfiles\terminal.ps1
.\dotfiles\ssh.ps1

# System opinionation
.\system\bloatware.ps1
.\system\nvidia.ps1
.\system\startup.ps1

# Networking
.\networking\wireguard.ps1

Stop-Transcript
