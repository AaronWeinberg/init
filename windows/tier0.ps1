# ================================
# Tier 0 — OS Foundation
# ================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Elevation Guard ---
$principal = New-Object Security.Principal.WindowsPrincipal `
    [Security.Principal.WindowsIdentity]::GetCurrent()

if (-not $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Tier 0 must be run as Administrator."
    exit 1
}

# --- Init Directory & Logging ---
$INIT_DIR = "$HOME\init"
New-Item -ItemType Directory -Force -Path $INIT_DIR | Out-Null

$LOG_FILE = "$INIT_DIR\tier0.log"
Start-Transcript -Path $LOG_FILE -Force

Write-Host ">>> Tier 0: OS Foundation"
Write-Host "Log: $LOG_FILE"

# --- Repo URLs ---
$baseUrl          = "https://raw.githubusercontent.com/AaronWeinberg/init/master"
$windowsScriptUrl = "$baseUrl/windows/scripts"

# ================================
# Package Infrastructure
# ================================

Write-Host ">>> Bootstrapping package providers"

Install-PackageProvider NuGet -Force -Confirm:$false | Out-Null

Install-Module PSWindowsUpdate -Force -Confirm:$false
Import-Module PSWindowsUpdate

# ================================
# Windows Update
# ================================

Write-Host ">>> Installing Windows Updates (reboot will be required)"

Install-WindowsUpdate -AcceptAll -IgnoreReboot

# ================================
# OEM / Firmware Tooling
# ================================

Write-Host ">>> Installing Dell Command Update (if applicable)"

winget list --accept-source-agreements | Out-Null

winget install `
  --id Dell.CommandUpdate `
  --accept-package-agreements `
  --accept-source-agreements `
  --silent `
  || Write-Warning "Dell Command Update install skipped or failed"

# ================================
# System Policies
# ================================

# --- RealTimeIsUniversal ---
Write-Host ">>> Setting RealTimeIsUniversal"

$tzKey = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
New-Item -Path $tzKey -Force | Out-Null
New-ItemProperty `
  -Path $tzKey `
  -Name RealTimeIsUniversal `
  -Value 1 `
  -PropertyType DWord `
  -Force | Out-Null

# --- Disable Windows Spotlight / Tips ---
Write-Host ">>> Disabling lock screen content delivery"

$cdm = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

Set-ItemProperty $cdm ContentDeliveryAllowed 0
Set-ItemProperty $cdm RotatingLockScreenEnabled 0
Set-ItemProperty $cdm RotatingLockScreenOverlayEnabled 0
Set-ItemProperty $cdm SubscribedContent-338387Enabled 0

# ================================
# Explorer Namespace Cleanup
# ================================

Write-Host ">>> Removing Gallery from Explorer"

$galleryGuid = "{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
$galleryKey  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$galleryGuid"

if (Test-Path $galleryKey) {
    Remove-Item $galleryKey -Recurse -Force
}

# ================================
# Ctrl2Cap (Keyboard Filter Driver)
# ================================

Write-Host ">>> Installing Ctrl2Cap (reboot required)"

$extractPath = "$HOME\Downloads\Ctrl2Cap"
$zipFile = "$extractPath.zip"

Invoke-WebRequest `
  "https://download.sysinternals.com/files/Ctrl2Cap.zip" `
  -OutFile $zipFile

Expand-Archive -LiteralPath $zipFile -DestinationPath $extractPath -Force

Push-Location $extractPath
echo Y | cmd.exe /c ctrl2cap /install
Pop-Location

Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue

# ================================
# OneDrive Removal (Complete)
# ================================

Write-Host ">>> Removing OneDrive completely"

# Stop OneDrive if running
Get-Process OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force

# Uninstall OneDrive (system + user)
$oneDriveSetup = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (-not (Test-Path $oneDriveSetup)) {
    $oneDriveSetup = "$env:SystemRoot\System32\OneDriveSetup.exe"
}

if (Test-Path $oneDriveSetup) {
    Start-Process $oneDriveSetup "/uninstall" -Wait
}

# Remove leftovers
$paths = @(
    "$env:LOCALAPPDATA\Microsoft\OneDrive",
    "$env:PROGRAMDATA\Microsoft OneDrive",
    "$env:SYSTEMDRIVE\OneDriveTemp",
    "$env:USERPROFILE\OneDrive"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Disable OneDrive via policy
$odPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
New-Item $odPolicy -Force | Out-Null
New-ItemProperty `
  -Path $odPolicy `
  -Name DisableFileSyncNGSC `
  -Value 1 `
  -PropertyType DWord `
  -Force | Out-Null

# Remove Explorer integration
Remove-ItemProperty `
  -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" `
  -Name System.IsPinnedToNameSpaceTree `
  -ErrorAction SilentlyContinue

Remove-ItemProperty `
  -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" `
  -Name System.IsPinnedToNameSpaceTree `
  -ErrorAction SilentlyContinue

# ================================
# Completion
# ================================

Write-Warning "Tier 0 complete."
Write-Warning "A REBOOT IS REQUIRED before running Tier 1."

Stop-Transcript
