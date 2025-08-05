# This script sets up a Fedora system with various development tools and utilities.

# Update system
echo "Updating system..."
sudo dnf update -y

# Install essential packages
echo "Installing essential packages..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
    git \
    curl \
    wget \
    htop \
    gcc \
    make \
    fd-find \
    fzf \
    python3 \
    python3-pip \
    nodejs \
    npm \
    zip \
    unzip \
    ripgrep \
    go \
    npm \
    nodejs \
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
