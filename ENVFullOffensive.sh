#!/bin/bash
#===============================================================================
# SCRIPT NAME   : ENVFullOffensive.sh
# DESCRIPTION   : Builds an offensive toolkit tailored to Windows
# AUTHOR        : 3mi55ary
# DATE          : 2025-08-28
# VERSION       : Lost Count
# USAGE         : ./ENVFullOffensive.sh
# NOTES         : Must run "git clone" from "~/" without sudo (sudo is handled by the script when needed).
# NOTES         : Tested on Latest Release of Kali Linux.
#===============================================================================
#===============================================================================
# System Basics ================================================================
#===============================================================================
# Create Report
echo "[+] Report Created" > ~/Report.txt

# Updates Kali GPG keyring
sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg
echo "[+] GPG Keyring Updated" >> ~/Report.txt

#===============================================================================
# Docker + Compose (Official Docker Repo) (Courtesy of wi0n - https://github.com/wi0n)
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

echo "[+] Docker installation complete. Log out/in or run 'newgrp docker' to use without sudo." >> ~/Report.txt
echo "[+] Docker Deployed" >> ~/Report.txt

#===============================================================================
# Requirements =================================================================
#===============================================================================

# Install UV
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "[+] UV Installed" >> ~/Report.txt
fi

# Install Golang
if ! command -v go &>/dev/null; then
    sudo apt install -y golang-go
    echo "[+] Golang Installed" >> ~/Report.txt
fi

#===============================================================================
# WINDOWS TOOLING ==============================================================
#===============================================================================
# https://wadcoms.github.io/
if [ ! -d ~/WindowsTools ]; then   
    # NetExec
    uv tool install git+https://github.com/Pennyw0rth/NetExec.git
    echo "[+] NXC Deployed" >> ~/Report.txt
    
    # BloodHound-CE
    if [ ! -d ~/WindowsTools/bloodhound ]; then
        mkdir -p ~/WindowsTools/bloodhound
        sudo curl -L https://ghst.ly/getbhce -o ~/WindowsTools/bloodhound/docker-compose.yml
        sudo docker-compose -f ~/WindowsTools/bloodhound/docker-compose.yml up -d
        echo "sudo docker-compose -f docker-compose.yml up -d" > ~/WindowsTools/bloodhound/Deploy.sh
        chmod +x ~/WindowsTools/bloodhound/Deploy.sh
        until curl -sfI http://localhost:8080/ui >/dev/null; do
            sleep 5
        done
        sudo docker logs $(whoami)-bloodhound-1 2>&1 | grep "Initial Password Set To:"
        sudo docker logs $(uname -n)-bloodhound-1 2>&1 | grep "Initial Password Set To:"
        sudo docker logs bloodhound-bloodhound-1 2>&1 | grep "Initial Password Set To:"
        sudo docker logs $(whoami)-bloodhound-1 2>&1 | grep "Initial Password Set To:" >> ~/Report.txt
        sudo docker logs $(uname -n)-bloodhound-1 2>&1 | grep "Initial Password Set To:" >> ~/Report.txt
        sudo docker logs bloodhound-bloodhound-1 2>&1 | grep "Initial Password Set To:" >> ~/Report.txt
        sudo mv ~/Castle/RedeployBloodhound.sh ~/WindowsTools/bloodhound
        sudo chmod +x ~/WindowsTools/bloodhound/RedeployBloodhound.sh
        echo "[+] Bloodhound-CE Deployed" >> ~/Report.txt
    fi
    
    # Bloodhound-CE Ingestor (Python Based) (bloodhound-ce-python -c All -d yourdomain.local -u username -p password -ns dnsserver)
    uv tool install git+https://github.com/dirkjanm/BloodHound.py@bloodhound-ce
    echo "[+] Bloodhound-CE Ingestor Deployed" >> ~/Report.txt
    
    # Impacket
    uv tool install git+https://github.com/fortra/impacket.git
    echo "[+] Impacket Deployed" >> ~/Report.txt
    
    # ldapdomaindump (sudo python3 ldapdomaindump.py ldap://DC -u 'DOMAIN\user' -p 'Password')
    uv tool install git+https://github.com/dirkjanm/ldapdomaindump.git
    echo "[+] ldapdomaindump Deployed" >> ~/Report.txt
    
    # BloodyAD
    uv tool install git+https://github.com/CravateRouge/bloodyAD.git
    echo "[+] BloodyAD Deployed" >> ~/Report.txt
    
    # Certipy-AD
    uv tool install git+https://github.com/ly4k/Certipy.git
    echo "[+] Certipy Deployed" >> ~/Report.txt
    
    # Evil-WinRM
    sudo apt install -y ruby ruby-dev libkrb5-dev
    sudo gem install evil-winrm
    echo "[+] Evil-WinRM Deployed" >> ~/Report.txt
    
    # Evil-WinRM-py
    uv tool install git+https://github.com/adityatelange/evil-winrm-py.git
    echo "[+] Evil-WinRM-py Deployed" >> ~/Report.txt
    
    # enum4linux
    uv tool install git+https://github.com/cddmp/enum4linux-ng.git
    echo "[+] enum4linux Deployed" >> ~/Report.txt

    # pyWhisker
    uv tool install git+https://github.com/ShutdownRepo/pywhisker.git
    echo "[+] pyWhisker Deployed" >> ~/Report.txt
    
    # ldapsearch
    sudo apt install -y ldap-utils
    echo "[+] ldapsearch Deployed" >> ~/Report.txt
    
    # smbmap
    uv tool install git+https://github.com/ShawnDEvans/smbmap.git
    echo "[+] smbmap Deployed" >> ~/Report.txt
    
    # responder
    mkdir -p ~/WindowsTools/responder
    git clone https://github.com/lgandx/Responder.git ~/WindowsTools/responder
    sudo ln -s ~/WindowsTools/responder/Responder.py /usr/local/bin/responder2
    echo "[+] Responder Deployed" >> ~/Report.txt
    
    # kerbrute (sudo kerbrute userenum -d DOMAIN.local --dc IP users.txt | Create users list from ldapdomaindump | Hashcat mode 18200)
    if ! command -v kerbrute &>/dev/null; then
        mkdir -p ~/WindowsTools/kerbrute
        git clone https://github.com/ropnop/kerbrute.git ~/WindowsTools/kerbrute
        sudo make -C ~/WindowsTools/kerbrute all
        sudo ln -sf ~/WindowsTools/kerbrute/dist/kerbrute_linux_amd64 /usr/local/bin/kerbrute
        echo "[+] Kerbrute Deployed" >> ~/Report.txt
    fi
    
    # windapsearch
    if ! command -v windapsearch &>/dev/null; then
        mkdir -p ~/WindowsTools/windapsearch
        git clone https://github.com/ropnop/go-windapsearch.git ~/WindowsTools/windapsearch
        cd ~/WindowsTools/windapsearch && go build ./cmd/windapsearch
        sudo ln -sf "$(pwd)/windapsearch" /usr/local/bin/windapsearch
        echo "[+] windapsearch Deployed" >> ~/Report.txt
    fi
    
    # shortscan
    if ! command -v shortscan &>/dev/null; then
        mkdir -p ~/WindowsTools/shortscan
        git clone https://github.com/bitquark/shortscan.git ~/WindowsTools/shortscan
        cd ~/WindowsTools/shortscan/cmd/shortscan && go build
        sudo ln -sf "$(pwd)/shortscan" /usr/local/bin/shortscan
        echo "[+] shortscan Deployed" >> ~/Report.txt
    fi

    # targetedkerberoast (Abuses ACLs to Add an SPN and Kerberoast)
    mkdir -p ~/WindowsTools/targetedkerberoast
    git clone https://github.com/ShutdownRepo/targetedKerberoast.git ~/WindowsTools/targetedkerberoast
    sudo ln -s ~/WindowsTools/targetedkerberoast/targetedKerberoast.py /usr/local/bin/targetedKerberoast.py
    echo "[+] TargetedKerberoast Deployed" >> ~/Report.txt
    
    mkdir -p ~/WindowsTools/dswalk
    git clone https://github.com/Keramas/DS_Walk.git ~/WindowsTools/dswalk
    sudo ln -s ~/WindowsTools/dswalk/ds_walk.py /usr/local/bin/ds_walk.py
    sudo ln -s ~/WindowsTools/dswalk/dsstore.py /usr/local/bin/dsstore.py
    echo "[+] DS_Walk Deployed" >> ~/Report.txt
    
    # krbrelayx
    git clone https://github.com/dirkjanm/krbrelayx.git ~/WindowsTools/krbrelayx
    sudo ln -s ~/WindowsTools/krbrelayx/krbrelayx.py /usr/local/bin/krbrelayx.py
    sudo ln -s ~/WindowsTools/krbrelayx/dnstool.py /usr/local/bin/dnstool.py
    sudo ln -s ~/WindowsTools/krbrelayx/addspn.py /usr/local/bin/addspn.py
    sudo ln -s ~/WindowsTools/krbrelayx/printerbug.py /usr/local/bin/printerbug.py
    
    # ds_walk
    mkdir -p ~/WindowsTools/dswalk
    git clone https://github.com/Keramas/DS_Walk.git ~/WindowsTools/dswalk
    sudo ln -s ~/WindowsTools/dswalk/ds_walk.py /usr/local/bin/ds_walk.py
    sudo ln -s ~/WindowsTools/dswalk/dsstore.py /usr/local/bin/dsstore.py
    echo "[+] DS_Walk Deployed" >> ~/Report.txt
    
    # UNTESTED TOOLING -------------------------------------------------------------------------------------------------------
    
    # https://github.com/SecWiki/windows-kernel-exploits/tree/master/MS14-068/pykek
    #uv tool install git+https://github.com/mubix/pykek.git # ERRORS HERE
    #echo "[+] pykek Deployed" >> ~/Report.txt
fi

#===============================================================================
# WINDOWS TOOLING (Transfer to Compromised Host) ===============================
#===============================================================================
if [ ! -d ~/WindowsNative ]; then
    # mimikatz
    mkdir -p ~/WindowsNative/mimikatz
    git clone https://github.com/ParrotSec/mimikatz.git ~/WindowsNative/mimikatz
    echo "[+] Mimikatz Added" >> ~/Report.txt

    # netcat
    mkdir -p ~/WindowsNative/netcat
    git clone https://github.com/int0x33/nc.exe.git ~/WindowsNative/netcat
    echo "[+] Netcat Added" >> ~/Report.txt
    
    # inveigh
    mkdir -p ~/WindowsNative/inveigh
    git clone https://github.com/Kevin-Robertson/Inveigh.git ~/WindowsNative/inveigh
    echo "[+] Inveigh Added" >> ~/Report.txt
    
    # powersploit (RECON -> Then Upload PowerView.ps1)
    mkdir -p ~/WindowsNative/powersploit
    git clone https://github.com/PowerShellMafia/PowerSploit.git ~/WindowsNative/powersploit
    echo "[+] PowerSploit Added" >> ~/Report.txt
    
    # Manual Credential Hunting
    # echo "" >> ~/WindowsNative/CredentialHunting.txt
    echo 'findstr /SIM /C:"password" *.txt *.ini *.cfg *.config *.xml' > ~/WindowsNative/CredentialHunting.txt
    echo 'findstr /SI /M "password" *.xml *.ini *.txt' >> ~/WindowsNative/CredentialHunting.txt
    echo 'findstr /si password *.xml *.ini *.txt *.config' >> ~/WindowsNative/CredentialHunting.txt
    echo 'findstr /spin "password" *.*' >> ~/WindowsNative/CredentialHunting.txt
    echo 'dir /S /B *pass*.txt == *pass*.xml == *pass*.ini == *cred* == *vnc* == *.config*' >> ~/WindowsNative/CredentialHunting.txt
    echo 'where /R C:\ *.config' >> ~/WindowsNative/CredentialHunting.txt
    echo 'foreach($user in ((ls C:\users).fullname)){cat "$user\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt" -ErrorAction SilentlyContinue}' >> ~/WindowsNative/CredentialHunting.txt
fi

#===============================================================================
# PIVOTING TOOLING =============================================================
#===============================================================================
if [ ! -d ~/PivotingTools ]; then
    # ligolo
    mkdir -p ~/PivotingTools/ligolo
    wget -P ~/PivotingTools/ligolo https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz
    wget -P ~/PivotingTools/ligolo https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_agent_0.8.2_linux_amd64.tar.gz
    wget -P ~/PivotingTools/ligolo https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_agent_0.8.2_windows_amd64.zip
    tar -xvzf ~/PivotingTools/ligolo/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz -C ~/PivotingTools/ligolo
    tar -xvzf ~/PivotingTools/ligolo/ligolo-ng_agent_0.8.2_linux_amd64.tar.gz -C ~/PivotingTools/ligolo
    unzip -q ~/PivotingTools/ligolo/ligolo-ng_agent_0.8.2_windows_amd64.zip -d ~/PivotingTools/ligolo
    mkdir -p ~/PivotingTools/ligolo/storage
    sudo mv ~/PivotingTools/ligolo/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz ~/PivotingTools/ligolo/ligolo-ng_agent_0.8.2_linux_amd64.tar.gz ~/PivotingTools/ligolo/ligolo-ng_agent_0.8.2_windows_amd64.zip ~/PivotingTools/ligolo/storage
    sudo mv ~/Castle/LigoloNXC.sh ~/PivotingTools/ligolo
    sudo chmod +x ~/PivotingTools/ligolo/LigoloNXC.sh
    echo "[+] Ligolo Deployed" >> ~/Report.txt

    # chisel
    mkdir -p ~/PivotingTools/chisel
    curl https://i.jpillora.com/chisel! | bash
    wget -P ~/PivotingTools/chisel https://github.com/jpillora/chisel/releases/download/v1.11.3/chisel_1.11.3_windows_amd64.zip
    unzip -q ~/PivotingTools/chisel/chisel_1.11.3_windows_amd64.zip -d ~/PivotingTools/chisel
    wget -P ~/PivotingTools/chisel https://github.com/jpillora/chisel/releases/download/v1.11.3/chisel_1.11.3_linux_amd64.gz
    gunzip -c ~/PivotingTools/chisel/chisel_1.11.3_linux_amd64.gz > ~/PivotingTools/chisel/chisel_1.11.3_linux_amd64
    echo "[+] Chisel Deployed" >> ~/Report.txt
fi

#===============================================================================
# Privilege Escelation (Transfer to Compromised Host) ==========================
#===============================================================================
#if [ ! -d ~/PrivEsc ]; then
    # Seatbelt https://github.com/GhostPack/Seatbelt (https://github.com/r3motecontrol/Ghostpack-CompiledBinaries)
    # winPEAS https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS
    # PowerUp https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1 
    # SharpUp https://github.com/GhostPack/SharpUp (https://github.com/r3motecontrol/Ghostpack-CompiledBinaries)
    # JAWS https://github.com/411Hall/JAWS
    # SessionGopher https://github.com/Arvanaghi/SessionGopher
    # Watson https://github.com/rasta-mouse/Watson
    # LaZagne https://github.com/AlessandroZ/LaZagne
    # Windows Exploit Suggester - Next Generation (WES-NG) https://github.com/bitsadmin/wesng
    # Sysinternals https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite
    # PrintSpoofer for SeImpersonate
    # Backup Operator Copy NTDS.dit https://github.com/giuliano108/SeBackupPrivilege/tree/master
#fi

#===============================================================================
# Command & Control ============================================================
#===============================================================================
#if [ ! -d ~/C2 ]; then
    # Sliver Agent
#fi

#===============================================================================
# Passwords ====================================================================
#=============================================================================== 
#if [ ! -d ~/Passwords ]; then
    # hashcat
    # seclists
    # rockyou extract
    # https://github.com/insidetrust/statistically-likely-usernames
#fi

#===============================================================================
# Screenshots / Captures =======================================================
#===============================================================================
if [ ! -d ~/Captures ]; then
    # Create Staging Area
    mkdir -p ~/Captures
    
    # Install and Configure Flameshot for Instant Usage
    sudo apt install -y flameshot
    flameshot &
    echo "[+] Flameshot Deployed" >> ~/Report.txt
    
    # Set XFCE's default screenshot save path (BACKUP)
    xfconf-query -c xfce4-screenshooter \
        -p /last-save-location \
        -s "$HOME/Captures"
    echo "[+] XFCE Default Path Changed" >> ~/Report.txt
fi
#===============================================================================
# System Monitoring ============================================================
#===============================================================================
if [ ! -d ~/Monitoring ]; then
    # DUF
    mkdir -p ~/Monitoring/duf
    git clone https://github.com/muesli/duf.git ~/Monitoring/duf
    go build -C ~/Monitoring/duf
    sudo cp ~/Monitoring/duf/duf /usr/local/bin/duf
    echo "[+] DUF Deployed" >> ~/Report.txt

    # btop
    mkdir -p ~/Monitoring/btop
    wget -qO ~/Monitoring/btop/btop.tbz https://github.com/aristocratos/btop/releases/download/v1.4.5/btop-x86_64-linux-musl.tbz
    sudo tar xf ~/Monitoring/btop/btop.tbz --strip-components=2 -C /usr/local ./btop/bin/btop
    echo "[+] Btop Deployed" >> ~/Report.txt
fi

# Set default tab opening to the Loot directory
echo 'cd ~/Loot' >> ~/.zshrc
echo 'cd ~/Loot' >> ~/.bashrc

# Finishing Print Statement
echo "[+] Lets Roll" >> ~/Report.txt
