export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="eastwood"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$PATH:$HOME/.local/scripts"
export PATH="$PATH:$HOME/.local/bin/azure-functions-cli"
alias logmeout="loginctl terminate-session self"
alias sshadd="find ~/.ssh -type f -name \"id_*\" ! -name \"*.pub\" -exec ssh-add {} \;"
export PATH="$HOME/.local/omnisharp:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"
export EDITOR=nvim
export PRETTIERD_DEFAULT_CONFIG="$HOME/dotfiles/.prettierrc.json"
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
bindkey -s ^f "herdr-s\n"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/home/era/.bun/_bun" ] && source "/home/era/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Herdr auto rename
autoload -Uz add-zsh-hook

_herdr_tab_number() {
  [[ -n "$HERDR_TAB_ID" && -n "$HERDR_WORKSPACE_ID" ]] || return

  herdr tab list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null |
    jq -r --arg id "$HERDR_TAB_ID" \
      '.result.tabs | to_entries[] | select(.value.tab_id == $id) | .key + 1'
}

_herdr_set_tab_name() {
  [[ -n "$HERDR_TAB_ID" ]] || return

  local number=$(_herdr_tab_number)
  [[ -n "$number" ]] || return

  herdr tab rename "$HERDR_TAB_ID" "$number:$1" >/dev/null 2>&1
}

_herdr_preexec() {
  local command_name="${${(z)1}[1]:t}"
  _herdr_set_tab_name "$command_name"
}

_herdr_precmd() {
  _herdr_set_tab_name "zsh"
}

add-zsh-hook preexec _herdr_preexec
add-zsh-hook precmd _herdr_precmd

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
