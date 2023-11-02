Function update {
  # empty recycle bin
  Clear-RecycleBin -Force

  # update all winget apps
  winget update --all --include-unknown;

  # download and install Nvidia drivers
  & "C:\Users\aaron\Documents\PowerShell\Scripts\nvidia\nvidia.ps1"

  # windows update - no prompt - no auto-restart
  Get-WindowsUpdate | Out-Null
  Install-WindowsUpdate -AcceptAll
}
