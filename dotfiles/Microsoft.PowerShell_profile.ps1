function prompt {
  $hostname = "$([System.Net.Dns]::GetHostName()) "
  $shell = "$($ShellId.split('.')[1]) "
  $path = "$($executionContext.SessionState.Path.CurrentLocation)"
  $path = $path.Replace($HOME, "~")
  $userPrompt = "$(' >>' * ($nestedPromptLevel + 1)) "

  Write-Host $hostname -NoNewLine -ForegroundColor "DarkMagenta"
  Write-Host $shell -NoNewline -ForegroundColor "Cyan"
  Write-Host $path -NoNewline -ForegroundColor "Green"

  if (Test-Path .git) {
    Write-BranchName
  }

  return $userPrompt
}