#!/usr/bin/env bash
# Tier 3 – Desktop UX (GNOME only)
# Applies dconf and enables GNOME extensions referenced by dconf

set -euo pipefail

### CONFIG ####################################################################
BASE_URL="https://raw.githubusercontent.com/AaronWeinberg/init/master"
DCONF_URL="$BASE_URL/linux/dconf/gnome.dconf"

### LOGGING ###################################################################
log() {
  printf '[tier3-desktop] %s\n' "$*"
}

### GUARDS ####################################################################
# Must be GNOME
if ! command -v gnome-shell >/dev/null 2>&1; then
  log "GNOME Shell not detected — exiting"
  exit 0
fi

# Must be a running desktop session
if [[ -z "${DISPLAY:-}" ]]; then
  log "No DISPLAY detected — exiting"
  exit 0
fi

# Must not be root
if [[ "$EUID" -eq 0 ]]; then
  log "Do not run Tier-3 as root"
  exit 1
fi

### DCONF #####################################################################
apply_dconf() {
  log "Applying dconf settings"
  curl -fsSL "$DCONF_URL" | dconf load /
}

### GNOME EXTENSIONS ##########################################################
enable_extensions_from_dconf() {
  log "Enabling GNOME extensions from dconf state"

  # dconf path used by GNOME to track enabled extensions
  local enabled
  enabled="$(dconf read /org/gnome/shell/enabled-extensions || true)"

  if [[ -z "$enabled" || "$enabled" == "@as []" ]]; then
    log "No enabled extensions found in dconf"
    return
  fi

  # Normalize list -> one per line
  echo "$enabled" \
    | tr -d "[]',@" \
    | tr ' ' '\n' \
    | while read -r ext; do
        [[ -z "$ext" ]] && continue
        gnome-extensions enable "$ext" 2>/dev/null || true
      done
}

### MAIN ######################################################################
main() {
  log "Starting Tier-3 GNOME configuration"

  apply_dconf
  enable_extensions_from_dconf

  log "Tier-3 GNOME configuration complete"
}

main "$@"
