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
export PATH="$PATH:$(go env GOPATH)/bin"
export EDITOR=nvim
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
bindkey -s ^f "tmux-sessionizer\n"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/home/era/.bun/_bun" ] && source "/home/era/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
