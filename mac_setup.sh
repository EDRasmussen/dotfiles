#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

formulae=(
    bash
    git
    curl
    wget
    ca-certificates
    stow
    coreutils
    findutils
    gnu-sed
    gawk
    gcc
    make
    just
    cmake
    ninja
    zip
    unzip
    unar
    p7zip
    pkgconf
    gdb
    llvm
    jq
    docker
    docker-compose
    docker-buildx
    docker-credential-helper
    colima
    kubectl
    postgresql
    mariadb
    sqlite
    redis
    tree
    lazydocker
    lazygit
    neovim
    tmux
    ripgrep
    fd
    fzf
    btop
    lua
    luarocks
    luajit
    ruby
    php
    composer
    go
    rustup
    node
    pnpm
    python
    zsh
    yazi
    ffmpeg-full
    sevenzip 
    poppler
    zoxide
    resvg
    imagemagick-full
)

casks=(
    raycast
    nikitabobko/tap/aerospace
    linearmouse
    karabiner-elements
    dotnet-sdk
    alacritty
    spotify
    discord
    dbeaver-community
    zen-browser
    bruno
    font-jetbrains-mono-nerd-font
    font-symbols-only-nerd-font
    font-inter
    font-noto-color-emoji
)

load_brew_shellenv() {
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_homebrew() {
    load_brew_shellenv

    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        load_brew_shellenv
    fi
}

use_homebrew_bash() {
    local brew_bash

    brew_bash="$(brew --prefix)/bin/bash"
    brew list --formula bash >/dev/null 2>&1 || brew install bash

    if [[ -z "${MAC_SETUP_HOMEBREW_BASH:-}" && -x "$brew_bash" && "$BASH" != "$brew_bash" ]]; then
        MAC_SETUP_HOMEBREW_BASH=1 exec "$brew_bash" "$0" "$@"
    fi
}

brew_install_formulae() {
    local pkg

    for pkg in "${formulae[@]}"; do
        brew list --formula "$pkg" >/dev/null 2>&1 || brew install "$pkg"
    done
}

brew_install_casks() {
    local pkg

    for pkg in "${casks[@]}"; do
        brew list --cask "$pkg" >/dev/null 2>&1 || brew install --cask "$pkg"
    done
}

install_omz() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "$SHELL" != "$zsh_path" ]]; then
        if ! grep -qx "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi
        sudo chsh -s "$zsh_path" "$USER"
    fi

    local zsh_custom
    zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
    fi
    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting"
    fi
}

install_sdkman() {
    export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
    local java_version="${SDKMAN_JAVA_VERSION:-21.0.7-tem}"
    local gradle_version="${SDKMAN_GRADLE_VERSION:-9.5.1}"
    local maven_version="${SDKMAN_MAVEN_VERSION:-3.9.16}"

    export sdkman_auto_answer=true

    if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
        curl -fsSL "https://get.sdkman.io" | bash
    fi

    set +u
    # shellcheck disable=SC1091
    source "$SDKMAN_DIR/bin/sdkman-init.sh"

    sdk install java "$java_version"
    sdk install gradle "$gradle_version"
    sdk install maven "$maven_version"

    sdk default java "$java_version"
    sdk default gradle "$gradle_version"
    sdk default maven "$maven_version"
    set -u
}

setup_rust() {
    rustup toolchain install stable
    rustup default stable
    rustup component add rust-src
}

setup_docker() {
    colima status >/dev/null 2>&1 || colima start --cpu 12 --memory 12 --disk 100
    docker context use colima >/dev/null 2>&1 || true
}

setup_security() {
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on >/dev/null
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on >/dev/null
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on >/dev/null
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp on >/dev/null
}

setup_dotnet() {
    dotnet tool install --global dotnet-ef || dotnet tool update --global dotnet-ef
}

setup_yazi() {
    brew link ffmpeg-full imagemagick-full -f --overwrite
}

launch_mac_apps() {
    open -a Raycast || true
    open -a AeroSpace || true
    open -a LinearMouse || true
    open -a Karabiner-Elements || true
}

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "mac_setup.sh is intended for macOS only."
    exit 1
fi

install_homebrew
brew update
use_homebrew_bash "$@"
brew_install_formulae
brew_install_casks

install_sdkman
setup_rust
setup_docker
setup_security
setup_dotnet
setup_yazi 
install_omz

git config --global --type bool push.autoSetupRemote true
mkdir -p "$HOME/projects"
(cd "$script_dir" && sh ./install.sh)
launch_mac_apps

echo "Done!"
