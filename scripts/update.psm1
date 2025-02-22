Function update {
  Write-Host ">>> EMPTY RECYCLE BIN <<<";
  Clear-RecycleBin -Force -ErrorAction SilentlyContinue;

  Write-Host ">>> UPDATE WINGET APPS <<<";
  winget update --all --include-unknown;

  Write-Host ">>> WINDOWS UPDATES <<<";
  Get-WindowsUpdate | Out-Null;
  Install-WindowsUpdate -AcceptAll;
}
