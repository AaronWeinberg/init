# ================================
# Tier 2 — Personal / Opinionated
# ================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Elevation Guard ---
$principal = New-Object Security.Principal.WindowsPrincipal `
    [Security.Principal.WindowsIdentity]::GetCurrent()

if (-not $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Tier 2 must be run as Administrator."
    exit 1
}

# --- Init Directory & Logging ---
$INIT_DIR = "$HOME\init"
New-Item -ItemType Directory -Force -Path $INIT_DIR | Out-Null

$LOG_FILE = "$INIT_DIR\tier2.log"
Start-Transcript -Path $LOG_FILE -Force

Write-Warning ">>> Tier 2 is PERSONAL and OPINIONATED"
Write-Warning ">>> Proceeding will remove apps and alter system behavior"
Write-Host "Log: $LOG_FILE"

# --- Repo URLs ---
$baseUrl        = "https://raw.githubusercontent.com/AaronWeinberg/init/master"
$windowsConfig  = "$baseUrl/windows/dotfiles"
$sharedGitUrl   = "$baseUrl/shared/git"
$sharedSshUrl   = "$baseUrl/shared/ssh"
$sharedHelixUrl = "$baseUrl/shared/helix"

# ================================
# Gaming Stack
# ================================

Write-Host ">>> Installing gaming applications"

$gamingApps = @(
    "Valve.Steam",
    "Blizzard.BattleNet"
)

foreach ($app in $gamingApps) {
    winget install `
        --id $app `
        --accept-package-agreements `
        --accept-source-agreements `
        --silent `
        || Write-Warning "Install skipped or failed: $app"
}

# ================================
# Peripheral Software
# ================================

Write-Host ">>> Installing peripheral software"

winget install `
  --id Logitech.GHUB `
  --accept-package-agreements `
  --accept-source-agreements `
  --silent `
  || Write-Warning "Logitech G HUB install failed or skipped"

# ================================
# Dotfiles
# ================================

Write-Host ">>> Applying dotfiles"

# --- Windows Terminal ---
$terminalSettings = "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $terminalSettings) {
    Invoke-WebRequest `
      "$windowsConfig/settings.json" `
      -OutFile "$terminalSettings\settings.json"
} else {
    Write-Warning "Windows Terminal Store install not detected; skipping settings.json"
}

# --- Helix ---
$helixDir = "$env:APPDATA\helix"
New-Item -ItemType Directory -Force -Path $helixDir | Out-Null
Invoke-WebRequest `
  "$sharedHelixUrl/config.toml" `
  -OutFile "$helixDir\config.toml"

# --- Git ---
Invoke-WebRequest `
  "$sharedGitUrl/.gitconfig" `
  -OutFile "$HOME\.gitconfig"

# --- SSH ---
$sshDir = "$HOME\.ssh"
New-Item -ItemType Directory -Force -Path $sshDir | Out-Null
Invoke-WebRequest `
  "$sharedSshUrl/id_ed25519.pub" `
  -OutFile "$sshDir\id_ed25519.pub"

# ================================
# Bloatware Removal
# ================================

Write-Host ">>> Removing unwanted Windows apps"

$removeWinget = @(
    "Microsoft.GetHelp",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Teams",
    "Microsoft.Todos",
    "Microsoft.StickyNotes",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay"
)

foreach ($app in $removeWinget) {
    winget uninstall `
        --id $app `
        --accept-package-agreements `
        --accept-source-agreements `
        --silent `
        || Write-Warning "Uninstall skipped or failed: $app"
}

# ================================
# NVIDIA Opinionation
# ================================

Write-Host ">>> Disabling NVIDIA container service (if present)"

$nvService = "NVDisplay.ContainerLocalSystem"

if (Get-Service $nvService -ErrorAction SilentlyContinue) {
    sc.exe config $nvService start= disabled | Out-Null
    sc.exe stop $nvService | Out-Null
} else {
    Write-Host "NVIDIA container service not present"
}

# ================================
# Startup Pruning (Known Offenders)
# ================================

Write-Host ">>> Pruning known startup entries"

$startupRunKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

$startupBlacklist = @(
    "OneDrive",
    "Teams",
    "Spotify",
    "Adobe"
)

foreach ($name in $startupBlacklist) {
    if (Get-ItemProperty $startupRunKey -Name $name -ErrorAction SilentlyContinue) {
        Remove-ItemProperty $startupRunKey -Name $name
        Write-Host "Removed startup entry: $name"
    }
}

# ================================
# WireGuard (Config Import Placeholder)
# ================================

Write-Host ">>> WireGuard installed; import tunnel manually if not automated"

# Intentionally not automated here:
# - Requires access to .conf
# - Credential-adjacent
# - You already said this may stay manual

# ================================
# Completion
# ================================

Write-Host ""
Write-Host "=========================================="
Write-Host " Tier 2 complete"
Write-Host " Personal environment applied"
Write-Host "=========================================="

Stop-Transcript
