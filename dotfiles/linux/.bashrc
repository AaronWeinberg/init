# ~/.bashrc — minimal, clean, and fully custom

# Exit if not interactive
case $- in
    *i*) ;;
      *) return;;
esac

# --- History ---
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

# --- lesspipe ---
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# --- dircolors + colorized tools ---
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi

# --- Load user aliases ---
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# --- Bash completion ---
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# --- update() function ---
update() {
  sudo apt update -qq

  UPGRADES=$(apt list --upgradable 2>/dev/null | grep -vc Listing)

  if [ "$UPGRADES" -gt 0 ]; then
    echo "📦 $UPGRADES package(s) can be upgraded, upgrading..."
    sudo apt -y full-upgrade
    sudo apt -y autoremove
  else
    echo "📦 System already up to date"
  fi

  # Safely empty user trash
  rm -rf "$HOME/.local/share/Trash/files/"* \
         "$HOME/.local/share/Trash/info/"*

  # Firmware updates (non-WSL, non-virtualized)
  if ! grep -qi microsoft /proc/version && \
     [ "$(systemd-detect-virt 2>/dev/null)" = "none" ]; then

    sudo fwupdmgr refresh >/dev/null 2>&1

    if sudo fwupdmgr get-updates | grep -q "Upgrade available"; then
      echo "🔧 Firmware updates found, applying..."
      sudo fwupdmgr update
    fi
  fi
}

# --- Go ---
if [ -d /usr/local/go/bin ]; then
  export PATH="/usr/local/go/bin:$PATH"
fi

# Go workspace (for `go install`)
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# --- npm global bin path ---
export PATH="$HOME/.npm-global/bin:$PATH"

# --- NVM ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# --- Git branch helper ---
parse_git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null | sed 's/^/|/'
}

# --- Custom Prompt (Git branch aware) ---
PS1='\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[0;34m\]\w\[\e[m\]\[\e[0;33m\]$(parse_git_branch)\[\e[m\]$ '
