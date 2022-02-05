Clear-RecycleBin -Force

Get-Command -Module PSWindowsUpdate | Out-Null
Install-WindowsUpdate -AcceptAll # windows update -no prompt -no auto-restart

winget upgrade --all

choco upgrade chocolatey

choco install nvidia-display-driver

choco upgrade nvidia-display-driver

Exit
