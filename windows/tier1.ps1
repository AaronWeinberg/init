# ================================
# Tier 1 — Core Tooling + UI Defaults
# ================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Elevation Guard ---
$principal = New-Object Security.Principal.WindowsPrincipal `
    [Security.Principal.WindowsIdentity]::GetCurrent()

if (-not $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Tier 1 must be run as Administrator."
    exit 1
}

# --- Init Directory & Logging ---
$INIT_DIR = "$HOME\init"
New-Item -ItemType Directory -Force -Path $INIT_DIR | Out-Null

$LOG_FILE = "$INIT_DIR\tier1.log"
Start-Transcript -Path $LOG_FILE -Force

Write-Host ">>> Tier 1: Core tooling and UI defaults"
Write-Host "Log: $LOG_FILE"

# ================================
# Winget Bootstrap
# ================================

Write-Host ">>> Initializing winget"

winget list --accept-source-agreements | Out-Null

# ================================
# Core Applications
# ================================

Write-Host ">>> Installing core applications"

$apps = @(
    "Helix.Helix",
    "Microsoft.VisualStudioCode",
    "GIMP.GIMP",
    "Google.Chrome",
    "Mozilla.Firefox",
    "WireGuard.WireGuard",
    "Balena.Etcher"
)

foreach ($app in $apps) {
    winget install `
        --id $app `
        --accept-package-agreements `
        --accept-source-agreements `
        --silent `
        || Write-Warning "Install skipped or failed: $app"
}

# ================================
# UI: Dark Mode
# ================================

Write-Host ">>> Enabling dark mode (system + apps)"

$personalize = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
New-Item -Path $personalize -Force | Out-Null

Set-ItemProperty $personalize AppsUseLightTheme 0
Set-ItemProperty $personalize SystemUsesLightTheme 0

# ================================
# UI: Taskbar Cleanup
# ================================

Write-Host ">>> Disabling taskbar search, widgets, and chat"

# Disable Search box
Set-ItemProperty `
  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
  SearchboxTaskbarMode 0

# Disable Widgets
Set-ItemProperty `
  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
  TaskbarDa 0

# Disable Chat (Teams)
Set-ItemProperty `
  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
  TaskbarMn 0

# ================================
# Explorer: File Visibility
# ================================

Write-Host ">>> Enabling file extensions and hidden/system files"

$explorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

Set-ItemProperty $explorer HideFileExt 0
Set-ItemProperty $explorer Hidden 1
Set-ItemProperty $explorer ShowSuperHidden 1

# Restart Explorer to apply changes
Stop-Process -Name explorer -Force

# ================================
# Notifications (User-level)
# ================================

Write-Host ">>> Disabling toast notifications"

Set-ItemProperty `
  "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" `
  ToastEnabled 0

# ================================
# Windows Update: Optional Updates Policy
# ================================

Write-Host ">>> Enabling optional Windows updates"

$wuPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
New-Item $wuPolicy -Force | Out-Null

# Allow driver updates
New-ItemProperty `
  -Path $wuPolicy `
  -Name ExcludeWUDriversInQualityUpdate `
  -Value 0 `
  -PropertyType DWord `
  -Force | Out-Null

# ================================
# PowerShell Profile
# ================================

Write-Host ">>> Installing PowerShell profile"

$baseUrl        = "https://raw.githubusercontent.com/AaronWeinberg/init/master"
$windowsConfig = "$baseUrl/windows/dotfiles"

$psProfileDir  = "$env:USERPROFILE\Documents\WindowsPowerShell"
$psProfileFile = "$psProfileDir\Microsoft.PowerShell_profile.ps1"

New-Item -ItemType Directory -Force -Path $psProfileDir | Out-Null

Invoke-WebRequest `
  "$windowsConfig/Microsoft.PowerShell_profile.ps1" `
  -OutFile $psProfileFile

# ================================
# Completion
# ================================

Write-Host ""
Write-Host "=========================================="
Write-Host " Tier 1 complete"
Write-Host " Core tools installed and UI defaults set"
Write-Host "=========================================="

Stop-Transcript
