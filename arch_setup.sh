core=(
    base-devel
    git
    curl
    wget
    ca-certificates
    openssh
    brightnessctl
    power-profiles-daemon
    networkmanager
    gvfs gvfs-smb udisks2
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
    bluez bluez-utils
    gnome-keyring
    hyprland hypridle hyprpaper hyprlock xdg-desktop-portal-hyprland
    wl-clipboard
)

dev=(
    gcc make
    cmake ninja
    unzip zip tar unrar p7zip
    pkgconf
    gdb lldb
    jq
    docker docker-compose
    kubectl
    postgresql mariadb sqlite
    redis
    tree
    lazydocker
    lazygit
)

cli=(
    neovim
    tmux
    ripgrep
    fd fzf
    btop
)

langs=(
    lua luarocks luajit
    ruby
    php composer
    dotnet-sdk
    python python-pip
    go
    rust
    nodejs
)

gui=(
    ghostty
    thunar
    rofi-wayland
    waybar dunst
    ttf-nerd-fonts-symbols
    hyprpolkitagent
    pavucontrol
    seahorse
    network-manager-applet
    blueman
    grim slurp
    cliphist
)

aur=(
    nerd-fonts-jetbrains-mono
)

flatpaks=(
    app.zen_browser.zen
    com.spotify.Client
    com.discordapp.Discord
)

shell=( zsh )

security=( ufw )

declare -A groups=(
    [core]="${core[*]}"
    [dev]="${dev[*]}"
    [cli]="${cli[*]}"
    [langs]="${langs[*]}"
    [gui]="${gui[*]}"
    [shell]="${shell[*]}"
    [aur]="${aur[*]}"
    [flatpak]="${flatpaks[*]}"
    [security]="${security[*]}"
)


default=(core dev cli gui aur)
if [[ $# -eq 0 ]]; then
    enabled=("${default[@]}")
elif [[ $1 == "all" ]]; then
    enabled=("${!groups[@]}")
else
    enabled=("$@")
fi

install_omz() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    sudo chsh -s "$(command -v zsh)" "$USER"
  fi

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi
  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  fi
}

install_flatpaks() {
    if ! command -v flatpak >/dev/null 2>&1; then
        echo "Flatpak not found, installing..."
        sudo pacman -S --needed --noconfirm flatpak
        flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
    fi

    for app in "$@"; do
        flatpak install -y --user flathub "$app"
    done
}

install_aur() {
    if ! command -v yay >/dev/null 2>&1; then
        echo "yay not found, installing..."
        sudo pacman -S --needed --noconfirm base-devel git
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
        (cd "$tmpdir/yay" && makepkg -si --noconfirm)
        rm -rf "$tmpdir"
    fi

    yay -S --needed --noconfirm "$@"
}

setup_ufw() {
  sudo ufw --force reset >/dev/null 2>&1 || true
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  sudo ufw --force enable
  sudo systemctl enable --now ufw.service >/dev/null 2>&1 || true

  echo "UFW enabled: incoming DENY, outgoing ALLOW."
}

echo "Updating system..."
sudo pacman -Syu --noconfirm
for g in "${enabled[@]}"; do
    pkgs=${groups[$g]:-}
    if [[ -n "$pkgs" ]]; then
        echo "Installing $g: $pkgs"
        case "$g" in
            aur) install_aur $pkgs ;;
            flatpak) install_flatpaks $pkgs ;;
            shell)
                sudo pacman -S --needed --noconfirm $pkgs
                install_omz
                ;;
            security)
                sudo pacman -S --needed --noconfirm $pkgs
                setup_ufw
                ;;
            *) sudo pacman -S --needed --noconfirm $pkgs ;;
        esac
    else
        echo "Unknown group: $g"
    fi
done

if command -v docker >/dev/null 2>&1; then
    sudo systemctl enable --now docker >/dev/null 2>&1 || true
    if ! id -nG "$USER" | grep -qw docker; then
        sudo usermod -aG docker "$USER"
        echo "Added $USER to docker group (log out/in to take effect)."
    fi
fi

sudo systemctl enable --now power-profiles-daemon >/dev/null 2>&1 || true
sudo systemctl enable --now NetworkManager.service >/dev/null 2>&1 || true
sudo systemctl enable --now bluetooth.service >/dev/null 2>&1 || true

echo "Done!"
