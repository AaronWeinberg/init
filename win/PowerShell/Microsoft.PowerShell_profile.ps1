function prompt {
  $ESC = [char]27
  "$ESC[32mPS $($executionContext.SessionState.Path.CurrentLocation)`n> $ESC[0m"
}