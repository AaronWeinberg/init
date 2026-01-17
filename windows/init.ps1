### ### ### ### ### ### ###
#  Initial Windows Setup  #
### ### ### ### ### ### ###

# --- Init Directory & Logging ---
$INIT_DIR = "$HOME\init"
New-Item -ItemType Directory -Force -Path $INIT_DIR | Out-Null

$LOG_FILE = "$INIT_DIR\init.log"
Start-Transcript -Path $LOG_FILE -Force

Write-Host ">>> Initializing Windows setup. Log: $LOG_FILE"

# --- Repo Paths ---
$baseUrl          = "https://raw.githubusercontent.com/AaronWeinberg/init/master"
$windowsConfigUrl = "$baseUrl/windows/dotfiles"
$windowsScriptUrl = "$baseUrl/windows/scripts"
$sharedGitUrl     = "$baseUrl/shared/git"
$sharedSshUrl     = "$baseUrl/shared/ssh"
$sharedHelixUrl   = "$baseUrl/shared/helix"

# --- Windows Update ---
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Install-WindowsUpdate -AcceptAll -IgnoreReboot

# --- Winget Installs ---
winget list --accept-source-agreements | Out-Null

## Dev
winget install --id GIMP.GIMP --accept-package-agreements --accept-source-agreements
winget install --id Helix.Helix --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements

## Gaming
winget install --id Blizzard.BattleNet --accept-package-agreements --accept-source-agreements
winget install --id Overwolf.CurseForge --accept-package-agreements --accept-source-agreements
winget install --id Wago.Addons --accept-package-agreements --accept-source-agreements
winget install --id Valve.Steam --accept-package-agreements --accept-source-agreements

## Peripherals
winget install --id Logitech.GHUB --accept-package-agreements --accept-source-agreements

## Utility
winget install --id Balena.Etcher --accept-package-agreements --accept-source-agreements
winget install --id Dell.CommandUpdate --accept-package-agreements --accept-source-agreements
winget install --id Google.Chrome --accept-package-agreements --accept-source-agreements
winget install --id Mozilla.Firefox --accept-package-agreements --accept-source-agreements
winget install --id WireGuard.WireGuard --accept-package-agreements --accept-source-agreements

# --- Bloatware Removal ---
$removeList = @(
    'Clipchamp', 'Cortana', 'Feedback Hub', 'Get Help', 'LinkedIn',
    'Mail and Calendar', 'Microsoft Bing Search', 'Microsoft Family',
    'Microsoft.GamingApp_8wekyb3d8bbwe', 'Microsoft News', 'Microsoft OneDrive',
    'Microsoft People', 'Microsoft Sticky Notes', 'Microsoft Teams',
    'Microsoft Tips', 'Microsoft To Do', 'Movies & TV', 'MSN Weather',
    'NVIDIA Control Panel', 'Office', 'OneDrive', 'Outlook For Windows',
    'Phone Link', 'Power Automate', 'Quick Assist', 'Solitaire & Casual Games',
    'Spotify Music', 'Windows Camera', 'Windows Clock', 'Windows Maps',
    'Windows Voice Recorder', 'Xbox Game Bar', 'Xbox Game Bar Plugin',
    'Xbox Game Speech Window', 'Xbox Identity Provider'
)

foreach ($app in $removeList) {
    winget uninstall --id $app --purge --accept-source-agreements --accept-package-agreements 2>$null
}

# --- Disable Nvidia Container Service ---
sc.exe config "NVDisplay.ContainerLocalSystem" start= disabled
sc.exe stop "NVDisplay.ContainerLocalSystem"

# --- Remove Gallery from Explorer ---
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /f

# --- Dotfiles (Windows-specific + shared) ---

# Windows Terminal settings.json
curl "$windowsConfigUrl/settings.json" `
    -o "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Helix config (shared)
New-Item -ItemType Directory -Force -Path "$env:APPDATA\helix" | Out-Null
curl "$sharedHelixUrl/config.toml" -o "$env:APPDATA\helix\config.toml"

# Git config (shared)
curl "$sharedGitUrl/.gitconfig" -o "$HOME\.gitconfig"

# SSH public key (shared)
New-Item -ItemType Directory -Force -Path "$HOME\.ssh" | Out-Null
curl "$sharedSshUrl/id_ed25519.pub" -o "$HOME\.ssh\id_ed25519.pub"

# --- RealTimeIsUniversal ---
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "RealTimeIsUniversal" -Value 1 -PropertyType DWORD -Force | Out-Null

# --- Ctrl2Cap ---
$extractPath = "$HOME\Downloads\Ctrl2Cap"
$zipFile = "$extractPath.zip"

curl "https://download.sysinternals.com/files/Ctrl2Cap.zip" -o "$zipFile"
Expand-Archive -LiteralPath "$zipFile" -DestinationPath "$extractPath" -Force

Push-Location "$extractPath"
echo Y | cmd.exe --% /c ctrl2cap /install
Pop-Location

Remove-Item -Force "$zipFile" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$extractPath" -ErrorAction SilentlyContinue

# --- Disable Lock Screen Tips ---
$cdm = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty -Path $cdm -Name "ContentDeliveryAllowed" -Value 1
Set-ItemProperty -Path $cdm -Name "RotatingLockScreenEnabled" -Value 1
Set-ItemProperty -Path $cdm -Name "RotatingLockScreenOverlayEnabled" -Value 0
Set-ItemProperty -Path $cdm -Name "SubscribedContent-338387Enabled" -Value 0

# --- PowerShell Setup ---
$powershellPath = "$env:USERPROFILE\Documents\WindowsPowerShell"

# Update module
$updateUrl  = "$windowsScriptUrl/update.psm1"
$updatePath = "$powershellPath\Modules\update"
$updateFile = "$updatePath\update.psm1"

New-Item -Path $updatePath -ItemType Directory -Force | Out-Null
Invoke-WebRequest -Uri $updateUrl -OutFile $updateFile
Import-Module $updateFile -Force

# PowerShell profile
$profileUrl  = "$windowsConfigUrl/Microsoft.PowerShell_profile.ps1"
$profileFile = "$powershellPath\Microsoft.PowerShell_profile.ps1"

curl "$profileUrl" -o "$profileFile"

# --- Final Summary ---
Write-Host ""
Write-Host "################################################"
Write-Host "   WINDOWS SETUP COMPLETE"
Write-Host "   Log File: $LOG_FILE"
Write-Host "################################################"

Stop-Transcript
