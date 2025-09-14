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
#sshpass
# Prepare System
sudo apt update

# Create Staging Areas
mkdir -p ~/Captures ~/WindowsTools ~/PivotingTools ~/Loot

# PimpMyKali Addition
git clone https://github.com/Dewalt-arch/pimpmykali ~/

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
# netexec
pipx install git+https://github.com/Pennyw0rth/NetExec

# bloodhound

# Impacket
mkdir ~/WindowsTools/impacket
python3 -m pipx install impacket
git clone https://github.com/dirkjanm/krbrelayx.git ~/WindowsTools/impacket

# responder
mkdir ~/WindowsTools/responder
git clone https://github.com/lgandx/Responder.git ~/WindowsTools/responder

# Bloody AD
# certipy-ad
# evil-winrm
# evil-winrm-py
# enum4linux

# ldapdomaindump (sudo python3 ldapdomaindump.py ldap://DC -u 'DOMAIN\user' -p 'Password')
mkdir ~/WindowsTools/ldapdomaindump
git clone https://github.com/dirkjanm/ldapdomaindump.git

# ldapsearch
# smbmap
# windapsearch
# shortscan - IIS Scanner + ds_walk
# https://github.com/ShutdownRepo/targetedKerberoast
# https://github.com/SecWiki/windows-kernel-exploits/tree/master/MS14-068/pykek

# Kerbrute (sudo kerbrute userenum -d DOMAIN.local --dc IP users.txt | Create users list from ldapdomaindump | Hashcat mode 18200)
mkdir ~/WindowsTools/kerbrute
sudo git clone https://github.com/ropnop/kerbrute.git ~/WindowsTools/kerbrute
sudo make -C ~/WindowsTools/kerbrute all
sudo ln -s ~/WindowsTools/kerbrute/dist/kerbrute_linux_amd64 /usr/local/bin/kerbrute

#===============================================================================
# PIVOTING TOOLING =============================================================
#===============================================================================
#ligolo
mkdir ~/PivotingTools/Ligolo
wget -P ~/PivotingTools/Ligolo https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz
tar -xvzf ~/PivotingTools/Ligolo/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz -C ~/PivotingTools/Ligolo

#chisel

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
