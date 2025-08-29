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

# Create Staging Areas
mkdir -p ~/Captures ~/WindowsTools ~/PivotingTools ~/Loot

# PimpMyKali Addition
cd ~
git clone https://github.com/Dewalt-arch/pimpmykali
cd ~/pimpmykali
# WORKING HERE ON AUTOMATING PIMPMYKALI FROM CLI --------------------------------------------------- >>> ###
sudo ./pimpmykali.sh --auto

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
# netexec
# bloodhound
# impacket
# responder
# enum4linux
# ldapdomaindump
# ldapsearch
# Kerbrute
cd ~/WindowsTools
sudo git clone https://github.com/ropnop/kerbrute.git
cd kerbrute
sudo make all
sudo ln -s ~/WindowsTools/kerbrute/dist/kerbrute_linux_amd64 /usr/local/bin/kerbrute

#===============================================================================
# PIVOTING TOOLING =============================================================
#===============================================================================
#ligolo
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