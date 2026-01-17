### ### ### ### ### ### ###
#  Windows Reset / Uninstall
### ### ### ### ### ### ###

# --- Init Directory & Logging ---
$INIT_DIR = "$HOME\init"
New-Item -ItemType Directory -Force -Path $INIT_DIR | Out-Null

$LOG_FILE = "$INIT_DIR\reset.log"
Start-Transcript -Path $LOG_FILE -Force

Write-Host ">>> Starting Windows reset. Log: $LOG_FILE"

# --- Winget Uninstalls (reverse of init.ps1) ---
$uninstallList = @(
    # Dev
    'GIMP.GIMP', 'Helix.Helix', 'Microsoft.VisualStudioCode',

    # Gaming
    'Blizzard.BattleNet', 'Overwolf.CurseForge', 'Wago.Addons', 'Valve.Steam',

    # Peripherals
    'Logitech.GHUB',

    # Utility
    'Balena.Etcher', 'Dell.CommandUpdate', 'Google.Chrome',
    'Mozilla.Firefox', 'WireGuard.WireGuard'
)

foreach ($app in $uninstallList) {
    winget uninstall --id $app --purge --accept-source-agreements --accept-package-agreements 2>$null
}

# --- Restore Nvidia Container Service ---
sc.exe config "NVDisplay.ContainerLocalSystem" start= auto
sc.exe start "NVDisplay.ContainerLocalSystem" 2>$null

# --- Restore Explorer Gallery (if desired) ---
# This key is normally present by default; restore it if missing.
$galleryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
if (-not (Test-Path $galleryKey)) {
    New-Item -Path $galleryKey -Force | Out-Null
}

# --- Remove Dotfiles Installed by init.ps1 ---
$terminalSettings = "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$helixConfigDir = "$env:APPDATA\helix"
$powershellProfile = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$updateModuleDir = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\update"

Remove-Item -Force $terminalSettings -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $helixConfigDir -ErrorAction SilentlyContinue
Remove-Item -Force $powershellProfile -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $updateModuleDir -ErrorAction SilentlyContinue

# --- Undo RealTimeIsUniversal ---
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
if (Test-Path "$registryPath\RealTimeIsUniversal") {
    Remove-ItemProperty -Path $registryPath -Name "RealTimeIsUniversal" -Force
}

# --- Undo Lock Screen Content Tweaks ---
$cdm = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

$lockscreenKeys = @(
    "ContentDeliveryAllowed",
    "RotatingLockScreenEnabled",
    "RotatingLockScreenOverlayEnabled",
    "SubscribedContent-338387Enabled"
)

foreach ($key in $lockscreenKeys) {
    if (Test-Path "$cdm\$key") {
        # Restore Windows defaults
        switch ($key) {
            "ContentDeliveryAllowed" { Set-ItemProperty -Path $cdm -Name $key -Value 1 }
            "RotatingLockScreenEnabled" { Set-ItemProperty -Path $cdm -Name $key -Value 1 }
            "RotatingLockScreenOverlayEnabled" { Set-ItemProperty -Path $cdm -Name $key -Value 1 }
            "SubscribedContent-338387Enabled" { Set-ItemProperty -Path $cdm -Name $key -Value 1 }
        }
    }
}

# --- Remove Ctrl2Cap Driver ---
# This reverses: ctrl2cap /install
echo Y | cmd.exe --% /c ctrl2cap /uninstall 2>$null

# --- Clean Up Init Directory (optional) ---
# Remove-Item -Recurse -Force "$HOME\init" -ErrorAction SilentlyContinue

# --- Final Summary ---
Write-Host ""
Write-Host "################################################"
Write-Host "   WINDOWS RESET COMPLETE"
Write-Host "   Log File: $LOG_FILE"
Write-Host "################################################"

Stop-Transcript
