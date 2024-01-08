function prompt {
  $hostname = "$([System.Net.Dns]::GetHostName()) "
  $shell = "$($ShellId.split('.')[1]) "
  $path = "$($executionContext.SessionState.Path.CurrentLocation)"
  $path = $path.Replace($HOME, "~")
  $userPrompt = "$(' >>' * ($nestedPromptLevel + 1)) "

  Write-Host $hostname -NoNewLine -ForegroundColor "DarkMagenta"
  Write-Host $shell -NoNewline -ForegroundColor "Cyan"
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
