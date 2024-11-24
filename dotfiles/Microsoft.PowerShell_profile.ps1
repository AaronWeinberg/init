function prompt {
  $hostname = "$([System.Net.Dns]::GetHostName()) "
  $shell = "$($ShellId.split('.')[1]) "
  $path = "$($executionContext.SessionState.Path.CurrentLocation)"
  $path = $path.Replace($HOME, "~")
  $userPrompt = "$(' >>' * ($nestedPromptLevel + 1)) "

  Write-Host $hostname -NoNewLine -ForegroundColor "DarkMagenta"
  Write-Host $env:USERNAME -NoNewline -ForegroundColor "Cyan"
  Write-Host " " -NoNewline # Add this line to include a space
  Write-Host $path -NoNewline -ForegroundColor "Green"

  function Write-BranchName {
    $branch = & git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch) {
        Write-Host " [$branch]" -NoNewline -ForegroundColor DarkYellow
    }
  }

  if (Test-Path .git) {
    Write-BranchName
  }

  return $userPrompt
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
