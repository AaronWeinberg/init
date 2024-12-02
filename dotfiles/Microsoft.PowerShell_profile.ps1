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

  Write-Host $username -NoNewLine -ForegroundColor Cyan
  Write-Host "@" -NoNewLine -ForegroundColor DarkYellow
  Write-Host $hostname -NoNewLine -ForegroundColor DarkMagenta
  Write-Host ":" -NoNewLine -ForegroundColor DarkYellow
  Write-Host $path -NoNewLine -ForegroundColor Green
  if ($branch) {
    Write-Host $branch -NoNewLine -ForegroundColor DarkYellow
  }
  Write-Host "$" -NoNewLine -ForegroundColor DarkYellow

  return " "
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
