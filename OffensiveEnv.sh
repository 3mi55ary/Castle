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
# System Basics ================================================================
#===============================================================================
# Prepare System
sudo apt update

# Create Base Staging Areas
mkdir -p ~/Captures ~/WindowsTools ~/PivotingTools ~/Monitoring ~/Loot

# Install UV
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Ensure Python3 + pipx are Installed
if ! command -v python3 &>/dev/null; then
    echo "[*] Installing Python3..."
    sudo apt install -y python3 python3-pip
fi

if ! command -v pipx &>/dev/null; then
    echo "[*] Installing pipx..."
    sudo apt install -y pipx
    pipx ensurepath
fi

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
# Passwords ====================================================================
#=============================================================================== 
# hashcat
# seclists
# rockyou extract
# https://github.com/insidetrust/statistically-likely-usernames

#===============================================================================
# WINDOWS TOOLING ==============================================================
#===============================================================================
# WADcoms link
# NetExec
uv tool install git+https://github.com/Pennyw0rth/NetExec.git

# BloodHound-CE

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

# smbmap
uv tool install git+https://github.com/ShawnDEvans/smbmap.git

# windapsearch

# shortscan

# ds_walk
uv tool install git+https://github.com/Keramas/DS_Walk.git

# https://github.com/ShutdownRepo/targetedKerberoast
uv tool install git+https://github.com/ShutdownRepo/targetedKerberoast.git

# https://github.com/SecWiki/windows-kernel-exploits/tree/master/MS14-068/pykek
uv tool install git+https://github.com/mubix/pykek.git

# Kerbrute (sudo kerbrute userenum -d DOMAIN.local --dc IP users.txt | Create users list from ldapdomaindump | Hashcat mode 18200)
mkdir ~/WindowsTools/kerbrute
sudo git clone https://github.com/ropnop/kerbrute.git ~/WindowsTools/kerbrute
sudo make -C ~/WindowsTools/kerbrute all
sudo ln -s ~/WindowsTools/kerbrute/dist/kerbrute_linux_amd64 /usr/local/bin/kerbrute

#===============================================================================
# PIVOTING TOOLING =============================================================
#===============================================================================
# Ligolo
mkdir ~/PivotingTools/Ligolo
wget -P ~/PivotingTools/Ligolo https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz
tar -xvzf ~/PivotingTools/Ligolo/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz -C ~/PivotingTools/Ligolo

#chisel

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
