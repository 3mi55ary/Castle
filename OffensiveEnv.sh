#!/bin/bash
#===============================================================================
# SCRIPT NAME   : OffensiveEnv.sh
# DESCRIPTION   : Builds an offensive toolkit tailored to Windows
# AUTHOR        : 3mi55ary
# DATE          : 2025-08-28
# VERSION       : 1.0
# USAGE         : sudo ./OffensiveEnv.sh
# NOTES         : Tested on Latest Release of Kali Linux
#===============================================================================

#===============================================================================
# Docker + Compose (Official Docker Repo, Debian Bullseye) ===================== -- TESTED
#===============================================================================
# Install prerequisites
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key (only if missing)
if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg \
        | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
fi

# Add Docker apt repository (only if missing)
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/debian bullseye stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

# Update and install Docker Engine + plugins
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install latest standalone docker-compose binary (optional, for scripts expecting it)
if [ ! -f /usr/local/bin/docker-compose ]; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Enable and start Docker
sudo systemctl enable --now docker

# Add current user to docker group (requires re-login to take effect)
sudo usermod -aG docker "$USER"

echo "[+] Docker installation complete. Log out/in or run 'newgrp docker' to use without sudo."

#===============================================================================
# System Basics ================================================================ -- TESTED
#===============================================================================
# Updates Kali GPG keyring
sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg

# Create Base Staging Areas
mkdir -p ~/Captures ~/WindowsTools ~/PivotingTools ~/Monitoring ~/Loot

# Install UV
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Install Golang
if ! command -v go &>/dev/null; then
    sudo apt install -y golang-go
fi

# Install Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"

#===============================================================================
# Screenshots / Captures =======================================================
#===============================================================================
# Install and Configure Flameshot for Instant Usage
sudo apt install -y flameshot
flameshot &
flameshot gui --path "$HOME/Captures" --accept-on-select &

# Set XFCE's default screenshot save path (BACKUP)
xfconf-query -c xfce4-screenshooter \
    -p /last-save-location \
    -s "$HOME/Captures"

#===============================================================================
# WINDOWS TOOLING ==============================================================
#===============================================================================
# https://wadcoms.github.io/
# NetExec
uv tool install git+https://github.com/Pennyw0rth/NetExec.git

# BloodHound-CE (Courtesy of wi0n - https://github.com/wi0n)
mkdir -p ~/bloodhound
curl -Lo ~/bloodhound/docker-compose.yml https://ghst.ly/getbhce
sg docker -c 'docker-compose -f ~/bloodhound/docker-compose.yml pull'
sg docker -c '
BLOODHOUND_HOST=0.0.0.0 BLOODHOUND_PORT=8888 docker-compose -f ~/bloodhound/docker-compose.yml up -d

# Wait for the API to respond
echo "Waiting for BloodHound API to be ready..."
until curl -s -f http://localhost:8888 >/dev/null 2>&1; do
    echo -n "."
    sleep 2
done
echo " Ready!"

'
sg docker -c 'echo $(docker logs $(docker ps -qf "ancestor=specterops/bloodhound:latest") | grep -i "initial password") | cut -d# -f2'
source ~/.zshrc

# RustHound
cargo install rusthound-ce
export PATH="$HOME/.cargo/bin:$PATH"
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc

# Impacket
uv tool install git+https://github.com/fortra/impacket.git
uv tool install git+https://github.com/dirkjanm/krbrelayx.git

# Responder
uv tool install git+https://github.com/lgandx/Responder.git

# BloodyAD
uv tool install git+https://github.com/CravateRouge/bloodyAD.git

# Certipy-AD
uv tool install git+https://github.com/ly4k/Certipy.git

# Evil-WinRM
sudo apt install -y ruby ruby-dev libkrb5-dev
sudo gem install evil-winrm

# Evil-WinRM-py
uv tool install git+https://github.com/Hackplayers/evil-winrm-py.git

# enum4linux
uv tool install git+https://github.com/cddmp/enum4linux-ng.git

# ldapdomaindump (sudo python3 ldapdomaindump.py ldap://DC -u 'DOMAIN\user' -p 'Password')
uv tool install git+https://github.com/dirkjanm/ldapdomaindump.git

# ldapsearch
sudo apt install -y ldap-utils

# smbmap
uv tool install git+https://github.com/ShawnDEvans/smbmap.git

# windapsearch
if ! command -v windapsearch &>/dev/null; then
    mkdir -p ~/WindowsTools/windapsearch
    git clone https://github.com/ropnop/go-windapsearch.git ~/WindowsTools/windapsearch
    cd ~/WindowsTools/windapsearch && go build ./cmd/windapsearch
    sudo ln -sf "$(pwd)/windapsearch" /usr/local/bin/windapsearch
fi

# shortscan
if ! command -v shortscan &>/dev/null; then
    mkdir -p ~/WindowsTools/shortscan
    git clone https://github.com/bitquark/shortscan.git ~/WindowsTools/shortscan
    cd ~/WindowsTools/shortscan/cmd/shortscan && go build
    sudo ln -sf "$(pwd)/shortscan" /usr/local/bin/shortscan
fi

# ds_walk
uv tool install git+https://github.com/Keramas/DS_Walk.git

# https://github.com/ShutdownRepo/targetedKerberoast
uv tool install git+https://github.com/ShutdownRepo/targetedKerberoast.git

# https://github.com/SecWiki/windows-kernel-exploits/tree/master/MS14-068/pykek
uv tool install git+https://github.com/mubix/pykek.git

# Kerbrute (sudo kerbrute userenum -d DOMAIN.local --dc IP users.txt | Create users list from ldapdomaindump | Hashcat mode 18200)
if ! command -v kerbrute &>/dev/null; then
    mkdir -p ~/WindowsTools/kerbrute
    git clone https://github.com/ropnop/kerbrute.git ~/WindowsTools/kerbrute
    sudo make -C ~/WindowsTools/kerbrute all
    sudo ln -sf ~/WindowsTools/kerbrute/dist/kerbrute_linux_amd64 /usr/local/bin/kerbrute
fi

#===============================================================================
# PIVOTING TOOLING =============================================================
#===============================================================================
# Ligolo
if [ ! -f ~/PivotingTools/Ligolo/ligolo-ng_proxy ]; then
    mkdir -p ~/PivotingTools/Ligolo
    wget -P ~/PivotingTools/Ligolo https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz
    tar -xvzf ~/PivotingTools/Ligolo/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz -C ~/PivotingTools/Ligolo
fi

#chisel

#===============================================================================
# Passwords ====================================================================
#=============================================================================== 
# hashcat
# seclists
# rockyou extract
# https://github.com/insidetrust/statistically-likely-usernames

#===============================================================================
# System Monitoring ============================================================
#===============================================================================
# DUF
mkdir ~/Monitoring/duf
git clone https://github.com/muesli/duf.git ~/Monitoring/duf
go build -C ~/Monitoring/duf


#===============================================================================
# CUSTOMIZING ==================================================================
#===============================================================================
# Change Wallpaper (COMES LAST - SHOWS SYSTEM IS READY)
read -p "Change Wallpaper? [y/N]: " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    xfconf-query -c xfce4-desktop \
        -p /backdrop/screen0/monitor0/image-path \
        -s "$(wget -O /tmp/remote_wallpaper.png https://wallhere.com/es/wallpaper/1837777 && echo /tmp/remote_wallpaper.png)"

    xfconf-query -c xfce4-desktop \
        -p /backdrop/screen0/monitor0/image-show \
        -s true
fi
