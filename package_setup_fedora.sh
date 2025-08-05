# This script sets up a Fedora system with various development tools and utilities.

# Update system
echo "Updating system..."
sudo dnf update -y

# Install OZSH
if ! echo "$SHELL" | grep -q "zsh"; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install essential packages
echo "Installing essential packages..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf copr enable scottames/ghostty
sudo dnf install -y \
    git \
    curl \
    wget \
    htop \
    gcc \
    make \
    fd-find \
    fzf \
    jq \
    lua \
    luarocks \
    python3 \
    python3-pip \
    zip \
    unzip \
    ripgrep \
    go \
    npm \
    nodejs \
    ruby \
    php \
    rust \
    cargo \
    ghostty \
    tmux \
    neovim

# Clone dotfiles repository and run setup script
echo "Cloning dotfiles repository..."
git clone git@github.com:EDRasmussen/dotfiles.git ~/dotfiles
echo "Running setup script from dotfiles..."
bash ~/dotfiles/install.sh

# Docker
echo "Installing Docker..."
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

# Dotnet
echo "Installing Dotnet..."
sudo yum install libicu
sudo dnf install dotnet-sdk-8.0 \
    aspnetcore-runtime-8.0 \
    dotnet-sdk-9.0 \
    aspnetcore-runtime-9.0

dotnet tool install --global dotnet-ef
dotnet tool install --global EasyDotnet
dotnet tool install --global dotnet-outdated-tool

# Hyprland
sudo dnf install hyprland hyprland-devel hyprpaper hypridle hyprlock waybar

# Firewall
sudo dnf install ufw
sudo wget -O /usr/local/bin/ufw-docker https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker
sudo chmod +x /usr/local/bin/ufw-docker
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH in
sudo ufw allow 22/tcp

# Allow Docker containers to use DNS on host
sudo ufw allow in on docker0 to any port 53

# Turn on the firewall
sudo ufw enable

# Turn on Docker protections
sudo ufw-docker install
sudo ufw reload

echo "Setup complete! Please set up your SSH keys."
