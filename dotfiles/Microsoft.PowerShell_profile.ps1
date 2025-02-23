function prompt {
  $hostname = "$([System.Net.Dns]::GetHostName())"
  $username = $env:USERNAME
  $path = "$($executionContext.SessionState.Path.CurrentLocation)"
  $path = $path.Replace($HOME, "~")
  $branch = ""

  if (Test-Path .git) {
    $branch = & git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch) {
      $branch = " [$branch]"
    }
  }

  Write-Host $username -NoNewLine -ForegroundColor Green
  Write-Host "@" -NoNewLine -ForegroundColor Green
  Write-Host $hostname -NoNewLine -ForegroundColor Green
  Write-Host ":" -NoNewLine -ForegroundColor White
  Write-Host $path -NoNewLine -ForegroundColor Blue
  if ($branch) {
    Write-Host $branch -NoNewLine -ForegroundColor DarkYellow
  }
  Write-Host "$" -NoNewLine -ForegroundColor White

  return " "
}

Set-Location -Path "~"
Clear-Host
