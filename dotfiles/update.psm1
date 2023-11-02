Function update {
  # empty recycle bin
  Write-Host "/\/\/\ Emptying Recycle Bin /\/\/\";
  Clear-RecycleBin -Force;

  # update all winget apps
  Write-Host "/\/\/\ Updating Winget apps /\/\/\";
  winget update --all --include-unknown;

  # download and install Nvidia drivers
  Write-Host "/\/\/\ Updating Nvidia drivers /\/\/\";
  & "C:\Users\aaron\Documents\PowerShell\Scripts\nvidia\nvidia.ps1";

  # windows update - no prompt - no auto-restart
  Write-Host "/\/\/\ Running Windows Update /\/\/\";
  Get-WindowsUpdate;
  Install-WindowsUpdate -AcceptAll;
}
