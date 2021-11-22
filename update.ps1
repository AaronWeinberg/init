Get-Command -Module PSWindowsUpdate | Out-Null
Install-WindowsUpdate -AcceptAll # windows update -no prompt -no auto-restart

choco upgrade chocolatey

choco install nvidia-display-driver

choco upgrade nvidia-display-driver

Clear-RecycleBin -Force

Exit