Function update {
  Write-Host "  >>> Emptying Recycle Bin";
  Clear-RecycleBin -Force -ErrorAction SilentlyContinue;

  Write-Host "  >>> Updating Winget apps";
  winget update --all --include-unknown;

  Write-Host "  >>> Updating Nvidia drivers";
  & "C:\Users\aaron\Documents\WindowsPowerShell\Scripts\nvidia\nvidia.ps1";

  Write-Host "  >>> Running Windows Update";
  Get-WindowsUpdate | Out-Null;
  Install-WindowsUpdate -AcceptAll;
}
