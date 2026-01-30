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
    cliphist
    greetd
    greetd-tuigreet
    stow
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
    ttf-jetbrains-mono-nerd
    azure-cli
)

cli=(
    tmux
    ripgrep
    fd fzf
    btop
)

langs=(
    lua luarocks luajit
    ruby
    php composer
    dotnet-sdk dotnet-runtime aspnet-runtime
    dotnet-sdk-8.0 dotnet-runtime-8.0 aspnet-runtime-8.0
    python python-pip
    go
    rust
    nodejs npm
)

gui=(
    alacritty
    thunar
    rofi-wayland
    rofi-calc
    waybar dunst
    ttf-nerd-fonts-symbols
    hyprpolkitagent
    pavucontrol
    seahorse
    network-manager-applet
    blueman
    upower
    grim slurp
    cliphist
    spotify-launcher
    discord
    dbeaver
    noto-fonts-emoji
)

aur=(
    neovim-nightly-bin
    cursor-bin
    zen-browser-bin
    onlyoffice-bin
    bruno-bin
    azure-functions-core-tools-bin
    ttf-ms-fonts ttf-vista-fonts
    ttf-menlo-powerline ttf-monaco
    apple-fonts
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
    [security]="${security[*]}"
)


default=(core dev cli langs shell gui aur security)
if [[ $# -eq 0 ]]; then
    enabled=("${default[@]}")
elif [[ $1 == "all" ]]; then
    enabled=("${!groups[@]}")
else
    enabled=("$@")
fi

install_omz() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=yes CHSH=yes KEEP_ZSHRC=yes \
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

install_aur() {
    if ! command -v yay >/dev/null 2>&1; then
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
}

setup_greetd() {
  sudo install -d -m 0755 /etc/greetd
  sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 2

[default_session]
command = "tuigreet --remember --time --asterisks --cmd start-hyprland"
user = "greeter"
EOF

  sudo install -d -m 0755 /etc/systemd/system/greetd.service.d
  sudo tee /etc/systemd/system/greetd.service.d/override.conf >/dev/null <<EOF
[Service]
StandardInput=tty
StandardOutput=tty
StandardError=journal

TTYPath=/dev/tty1
TTYReset=true
TTYVHangup=true
TTYVTDisallocate=true

Type=idle
EOF

  sudo systemctl enable --now greetd.service >/dev/null 2>&1 || true
}

sudo pacman -Syu --noconfirm
for g in "${enabled[@]}"; do
    pkgs=${groups[$g]:-}
    if [[ -n "$pkgs" ]]; then
        echo "Installing $g: $pkgs"
        case "$g" in
            aur) install_aur $pkgs ;;
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

# Azure credentials manager
wget -qO- https://aka.ms/install-artifacts-credprovider.sh | bash
dotnet tool install --global dotnet-ef

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
sudo systemctl enable --now upower.service 2>/dev/null || true

# Zen browser default
xdg-settings set default-web-browser zen.desktop
xdg-mime default zen.desktop x-scheme-handler/http
xdg-mime default zen.desktop x-scheme-handler/https
xdg-mime default zen.desktop text/html
sudo ln -s /opt/zen-browser-bin/zen-bin /usr/local/bin/zen

# Overrides to remove networkmanager spam
sudo mkdir -p /etc/systemd/system/NetworkManager.service.d
sudo tee /etc/systemd/system/NetworkManager.service.d/override.conf >/dev/null <<'EOF'
[Service]
StandardOutput=null
StandardError=journal
EOF
sudo systemctl daemon-reexec
git config --global --type bool push.autoSetupRemote true

mkdir -p ~/projects
# install_omz
sh ./install.sh
setup_greetd

echo "Done!"
