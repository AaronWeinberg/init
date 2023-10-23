Function update {

  # only displays winget command output if something was changed
  Function WingetQuiet {
    param ([string] $output)
    if ($output -ne "No installed package found matching input criteria.") {
      Write-Output $output >> $null
    } else {
      Write-Output $output
    }
  }

  Clear-RecycleBin -Force

  $result = winget upgrade 2>&1 # upgrade winget
  WingetQuiet $result

  $result = winget update --all --include-unknown 2>&1 # update winget apps
  WingetQuiet $result

  Get-WindowsUpdate | Out-Null # windows update -no prompt -no auto-restart
  Install-WindowsUpdate -AcceptAll
}