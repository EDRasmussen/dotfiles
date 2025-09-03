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

bindkey -s ^f "tmux-sessionizer\n"
