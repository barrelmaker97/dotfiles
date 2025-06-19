# .zshrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set umask if it isn't already
umask 022

# History options
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY     # includes timestamps

# Check window size after each command
unsetopt CHECK_WINSIZE      # not needed in zsh

# Auto-correct spelling errors in directory names
setopt CORRECT

# Standard Colors
RED='%F{red}'
YELLOW='%F{yellow}'
GREEN='%F{green}'
CYAN='%F{cyan}'
BLUE='%F{blue}'
PURPLE='%F{magenta}'
WHITE='%F{white}'
BR_RED='%F{196}'
BR_YELLOW='%F{226}'
BR_GREEN='%F{82}'
BR_CYAN='%F{51}'
BR_BLUE='%F{39}'
BR_PURPLE='%F{201}'
BR_WHITE='%F{15}'
RESET='%f'

# Expanded colors
ORANGE='%F{208}'
GOLD='%F{220}'
TEAL='%F{44}'
LIME='%F{46}'

set_prompt() {
  local color symbol git_info test_env
  case "${HOST}" in
    pollux)   color="${ORANGE}" ;;
    zeus)     color="${TEAL}" ;;
    soteria)  color="${LIME}" ;;
    *)        color="${BR_GREEN}" ;;
  esac

  symbol="$"
  [[ $EUID -eq 0 ]] && { color="${BR_RED}"; symbol="#" }

  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -n "$current_branch" ]]; then
    local git_color
    git status --porcelain &>/dev/null && git_color="${BR_RED}" || git_color="${BR_CYAN}"
    git_info="${BR_WHITE} on ${git_color}${current_branch}"
  fi

  if [[ -n "$VIRTUAL_ENV" ]]; then
    test_env="${BR_YELLOW}[${VIRTUAL_ENV##*/}]${RESET}"
  fi

  PROMPT="${test_env}${color}%n@%m${BR_WHITE}:${BR_BLUE}%~${git_info}${BR_WHITE}${symbol}${RESET} "
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd set_prompt

# Completion system
autoload -Uz compinit
compinit

# Set PATH additions
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d "/opt/homebrew/bin" ]] && path=("/opt/homebrew/bin" "/opt/homebrew/sbin" $path)
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

# Load Rust environment if present
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Enable menu-complete with TAB
bindkey '^I' menu-complete

# Set GPG TTY
export GPG_TTY=$(tty)

# Set fc editor
export FCEDIT=vim

# Completions for various tools
[[ -x "$(command -v kubectl)" ]]   && source <(kubectl completion zsh)
[[ -x "$(command -v talosctl)" ]]  && source <(talosctl completion zsh)
[[ -x "$(command -v oc)" ]]        && source <(oc completion zsh)
[[ -x "$(command -v helm)" ]]      && source <(helm completion zsh)
[[ -x "$(command -v kind)" ]]      && source <(kind completion zsh)
[[ -x "$(command -v podman)" ]]    && source <(podman completion zsh)

# Load aliases from dotfiles
[[ -f "$HOME/dotfiles/aliases" ]] && source "$HOME/dotfiles/aliases"
