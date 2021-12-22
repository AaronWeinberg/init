function prompt {
  $ESC = [char]27
  "$ESC[32mPS $($executionContext.SessionState.Path.CurrentLocation)$ESC[0m`n> "
}
