#!/bin/bash
#===============================================================================
# SCRIPT NAME   : ENVFullOffensive.sh
# DESCRIPTION   : Builds an offensive toolkit tailored to Windows
# AUTHOR        : 3mi55ary
# DATE          : 2025-08-28
# VERSION       : Lost Count
# USAGE         : ./ENVFullOffensive.sh
# NOTES         : Must run without sudo (sudo is handled by the script when needed).
# NOTES         : Tested on Latest Release of Kali Linux.
# Upcoming Fixes: Convert ~/ to hard paths or perform better logic handling
#===============================================================================
#===============================================================================
# System Basics ================================================================
#===============================================================================
# Create Report
echo "[+] Report Created" > ~/Report.txt

# Generate Quick Commands Guide
echo "=== QUICK COMMANDS GUIDE ===" > ~/Commands.txt
echo "[+] Quick Commands Guide Created" > ~/Report.txt

# Updates Kali GPG keyring
sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg
sudo apt update
echo "[+] GPG Keyring Updated" >> ~/Report.txt

if [ ! -d ~/Outpost ]; then
    git clone https://github.com/3mi55ary/Outpost.git ~/Outpost
    echo "[+] Outpost Directory Added!" >> ~/Report.txt
fi

if [ ! -d ~/Loot ]; then
    mkdir -p ~/Loot
    echo "[+] Loot Directory Added -- Start filling it!" >> ~/Report.txt
fi

#===============================================================================
# Docker + Compose (Official Docker Repo) (Courtesy of wi0n - https://github.com/wi0n)
#===============================================================================
# Install prerequisites
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
# WINDOWS TOOLING (UV and Bloodhound) ==========================================
#===============================================================================
# https://wadcoms.github.io/
if [ ! -d ~/WindowsTools ]; then   
    # NetExec
    uv tool install git+https://github.com/Pennyw0rth/NetExec.git --force
    echo "NXC: nxc <service> -u '' -p '' (-M <module>)" >> ~/Commands.txt
    echo "[+] NXC Deployed" >> ~/Report.txt
    
    # BloodHound-CE
    if [ ! -d ~/WindowsTools/bloodhound ]; then
        mkdir -p ~/WindowsTools/bloodhound
        sudo curl -L https://ghst.ly/getbhce -o ~/WindowsTools/bloodhound/docker-compose.yml
        sudo docker-compose -f ~/WindowsTools/bloodhound/docker-compose.yml up -d
        until curl -sfI http://localhost:8080/ui >/dev/null; do
            sleep 5
        done
        sudo docker logs $(whoami)-bloodhound-1 2>&1 | grep "Initial Password Set To:"
        sudo docker logs $(uname -n)-bloodhound-1 2>&1 | grep "Initial Password Set To:"
        sudo docker logs bloodhound-bloodhound-1 2>&1 | grep "Initial Password Set To:"
        sudo docker logs $(whoami)-bloodhound-1 2>&1 | grep "Initial Password Set To:" >> ~/Report.txt
        sudo docker logs $(uname -n)-bloodhound-1 2>&1 | grep "Initial Password Set To:" >> ~/Report.txt
        sudo docker logs bloodhound-bloodhound-1 2>&1 | grep "Initial Password Set To:" >> ~/Report.txt
        sudo cp ~/Outpost/RedeployBloodhound.sh ~/WindowsTools/bloodhound # SECONDARY PERSONAL SCRIPT HERE
        sudo chmod +x ~/WindowsTools/bloodhound/RedeployBloodhound.sh
        sudo ln -s ~/WindowsTools/bloodhound/RedeployBloodhound.sh /usr/local/bin/RedeployBloodhound
        echo "Bloodhound-CE: RedeployBloodhound" >> ~/Commands.txt
        echo "[+] RedeployBloodhound Deployed" >> ~/Report.txt
        echo "[+] Bloodhound-CE Deployed" >> ~/Report.txt
    fi
    
    # Bloodhound-CE Ingestor (Python Based) (bloodhound-ce-python -c All -d yourdomain.local -u username -p password -ns dnsserver)
    uv tool install git+https://github.com/dirkjanm/BloodHound.py@bloodhound-ce --force
    echo "Bloodhound-CE Ingestor: bloodhound-ce-python -c All -d yourdomain.local -u username -p password -ns dnsserver" >> ~/Commands.txt
    echo "[+] Bloodhound-CE Ingestor Deployed" >> ~/Report.txt
    
    # Impacket
    uv tool install git+https://github.com/fortra/impacket.git --force
    echo "IMPACKET: impacket-<option> domain/username:'password'@<IP/Hostname>" >> ~/Commands.txt
    echo "[+] Impacket Deployed" >> ~/Report.txt
    
    # ldapdomaindump (sudo python3 ldapdomaindump.py ldap://DC -u 'DOMAIN\user' -p 'Password')
    # If throwing MD4 crypt error (sudo python3 /usr/local/bin/ldapdomaindump ldap://DC -u 'DOMAIN\user' -p 'Password')
    uv tool install git+https://github.com/dirkjanm/ldapdomaindump.git --force
    echo "LDAPDOMAINDUMP: sudo python3 /usr/local/bin/ldapdomaindump ldap://<DC-IP> -u 'DOMAIN\user' -p 'Password'" >> ~/Commands.txt
    echo "[+] ldapdomaindump Deployed" >> ~/Report.txt
    
    # BloodyAD
    uv tool install git+https://github.com/CravateRouge/bloodyAD.git --force
    echo "BloodyAD: bloodyAD --host <DC-IP> -d 'domain.local' -u 'owneduser' -p 'password' remove uac 'targetuser' -f ACCOUNTDISABLE" >> ~/Commands.txt
    echo "BloodyAD: bloodyAD --host <DC-IP> -d 'domain.local' -u 'owneduser' -p 'password' set password 'targetuser' 'newpassword'" >> ~/Commands.txt
    echo "[+] BloodyAD Deployed" >> ~/Report.txt
    
    # Certipy-AD
    uv tool install git+https://github.com/ly4k/Certipy.git --force
    echo "[+] Certipy Deployed" >> ~/Report.txt
    
    # Evil-WinRM-py
    uv tool install git+https://github.com/adityatelange/evil-winrm-py.git --force
    echo "[+] Evil-WinRM-py Deployed" >> ~/Report.txt
    
    # enum4linux
    uv tool install git+https://github.com/cddmp/enum4linux-ng.git --force
    echo "[+] enum4linux Deployed" >> ~/Report.txt

    # pyWhisker
    uv tool install git+https://github.com/ShutdownRepo/pywhisker.git --force
    echo "[+] pyWhisker Deployed" >> ~/Report.txt
    
    # smbmap
    uv tool install git+https://github.com/ShawnDEvans/smbmap.git --force
    echo "[+] SMBmap Deployed" >> ~/Report.txt

    #===============================================================================
    # WINDOWS TOOLING (Make/Build/Link) ============================================
    #===============================================================================
    # Updates Kali GPG keyring
    sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg
    sudo apt update
    echo "[+] GPG Keyring Updated" >> ~/Report.txt

    # Install Golang
    if ! command -v go &>/dev/null; then
        sudo apt install -y golang-go
        echo "[+] Golang Installed" >> ~/Report.txt
    fi

    # kerbrute (sudo kerbrute userenum -d DOMAIN.local --dc IP users.txt | Create users list from ldapdomaindump | Hashcat mode 18200)
    mkdir -p ~/WindowsTools/kerbrute
    git clone https://github.com/ropnop/kerbrute.git ~/WindowsTools/kerbrute
    sudo make -C ~/WindowsTools/kerbrute all
    sudo ln -sf ~/WindowsTools/kerbrute/dist/kerbrute_linux_amd64 /usr/local/bin/kerbrute
    echo "KERBRUTE: sudo kerbrute userenum -d DOMAIN.local --dc IP users.txt" >> ~/Commands.txt
    echo "[+] Kerbrute Deployed" >> ~/Report.txt
    
    # manspider
    pip install pipx --break-system-packages
    pipx install git+https://github.com/blacklanternsecurity/MANSPIDER
    echo "MANSPIDER: manspider <IP> --sharenames Share -d domain.local -u '' -p '' -f '.'" >> ~/Commands.txt
    echo "[+] Manspider Deployed" >> ~/Report.txt
    
    # Evil-WinRM
    sudo apt install -y ruby ruby-dev libkrb5-dev
    sudo gem install evil-winrm
    echo "[+] Evil-WinRM Deployed" >> ~/Report.txt

    # responder
    mkdir -p ~/WindowsTools/responder
    git clone https://github.com/lgandx/Responder.git ~/WindowsTools/responder
    sudo ln -s ~/WindowsTools/responder/Responder.py /usr/local/bin/responder2
    echo "RESPONDER: sudo responder2 -i eth0" >> ~/Commands.txt
    echo "[+] Responder Deployed" >> ~/Report.txt

    # username-anarchy
    mkdir -p ~/WindowsTools/username-anarchy
    git clone https://github.com/urbanadventurer/username-anarchy.git ~/WindowsTools/username-anarchy
    sudo ln -sf ~/WindowsTools/username-anarchy/username-anarchy /usr/local/bin/username-anarchy
    echo "USERNAME-ANARCHY: username-anarchy -i names.txt -f flast,lfirst,f.last > usernames.txt" >> ~/Commands.txt
    echo "[+] Username-Anarchy Deployed" >> ~/Report.txt

    # ldapsearch
    sudo apt install -y ldap-utils
    echo "[+] LDAPsearch Deployed" >> ~/Report.txt
    
    # windapsearch
    mkdir -p ~/WindowsTools/windapsearch
    git clone https://github.com/ropnop/go-windapsearch.git ~/WindowsTools/windapsearch
    cd ~/WindowsTools/windapsearch && go build ./cmd/windapsearch
    sudo ln -sf "$(pwd)/windapsearch" /usr/local/bin/windapsearch
    echo "[+] Windapsearch Deployed" >> ~/Report.txt
    
    # shortscan
    mkdir -p ~/WindowsTools/shortscan
    git clone https://github.com/bitquark/shortscan.git ~/WindowsTools/shortscan
    cd ~/WindowsTools/shortscan/cmd/shortscan && go build
    sudo ln -sf "$(pwd)/shortscan" /usr/local/bin/shortscan
    echo "[+] Shortscan Deployed" >> ~/Report.txt

    # targetedkerberoast (Abuses ACLs to Add an SPN and Kerberoast)
    mkdir -p ~/WindowsTools/targetedkerberoast
    git clone https://github.com/ShutdownRepo/targetedKerberoast.git ~/WindowsTools/targetedkerberoast
    sudo ln -s ~/WindowsTools/targetedkerberoast/targetedKerberoast.py /usr/local/bin/targetedKerberoast.py
    echo "[+] TargetedKerberoast Deployed" >> ~/Report.txt
    
    # krbrelayx
    git clone https://github.com/dirkjanm/krbrelayx.git ~/WindowsTools/krbrelayx
    sudo ln -s ~/WindowsTools/krbrelayx/krbrelayx.py /usr/local/bin/krbrelayx.py
    sudo ln -s ~/WindowsTools/krbrelayx/dnstool.py /usr/local/bin/dnstool.py
    sudo ln -s ~/WindowsTools/krbrelayx/addspn.py /usr/local/bin/addspn.py
    sudo ln -s ~/WindowsTools/krbrelayx/printerbug.py /usr/local/bin/printerbug.py
    echo "[+] Krbrelayx Deployed" >> ~/Report.txt
    
    # ds_walk
    mkdir -p ~/WindowsTools/dswalk
    git clone https://github.com/Keramas/DS_Walk.git ~/WindowsTools/dswalk
    sudo ln -s ~/WindowsTools/dswalk/ds_walk.py /usr/local/bin/ds_walk.py
    sudo ln -s ~/WindowsTools/dswalk/dsstore.py /usr/local/bin/dsstore.py
    echo "[+] DS_Walk Deployed" >> ~/Report.txt
fi

#===============================================================================
# WINDOWS TOOLING (Transfer to Compromised Host) ===============================
#===============================================================================
if [ ! -d ~/WindowsNative ]; then
    # mimikatz
    mkdir -p ~/WindowsNative/mimikatz
    git clone https://github.com/ParrotSec/mimikatz.git ~/WindowsNative/mimikatz
    echo "[+] Mimikatz Added" >> ~/Report.txt

    # Ghostpack
    mkdir -p ~/WindowsNative/ghostpack
    git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries.git ~/WindowsNative/ghostpack
    echo "[+] Ghostpack Binaries Added" >> ~/Report.txt
    
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
    sudo cp ~/Outpost/LigoloNXC.sh ~/PivotingTools/ligolo
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
# Screenshots ==================================================================
#===============================================================================
# Install and Configure Flameshot for Instant Usage
sudo apt install -y flameshot
flameshot &
echo "[+] Flameshot Deployed" >> ~/Report.txt

# Set XFCE's default screenshot save path (BACKUP)
xfconf-query -c xfce4-screenshooter \
    -p /last-save-location \
    -s "$HOME/Loot"
echo "[+] XFCE Default Path Changed to ~/Loot" >> ~/Report.txt

#===============================================================================
# System QoL ===================================================================
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

    # Creds Script (stores found credentials in 'username':'password' format and puts them in ~/Loot/creds.txt)
    mkdir -p ~/Monitoring/qol
    sudo cp ~/Outpost/StoreCred.sh ~/Monitoring/qol/StoreCred.sh # SECONDARY PERSONAL SCRIPT HERE
    sudo chmod +x ~/Monitoring/qol/StoreCred.sh
    sudo ln -s ~/Monitoring/qol/StoreCred.sh /usr/local/bin/StoreCred
    echo "[+] StoreCred Deployed" >> ~/Report.txt

    # Hostname Script (stores hostname in /etc/hosts)
    mkdir -p ~/Monitoring/qol
    sudo cp ~/Outpost/StoreHostname.sh ~/Monitoring/qol/StoreHostname.sh # SECONDARY PERSONAL SCRIPT HERE
    sudo chmod +x ~/Monitoring/qol/StoreHostname.sh
    sudo ln -s ~/Monitoring/qol/StoreHostname.sh /usr/local/bin/StoreHostname
    echo "[+] StoreHostname Deployed" >> ~/Report.txt

    # Set default tab opening to the Loot directory
    echo 'cd ~/Loot' >> ~/.zshrc
    echo 'cd ~/Loot' >> ~/.bashrc
    echo "[+] Default Opening Directory Deployed" >> ~/Report.txt
fi

#===============================================================================
# Wrapping Up ==================================================================
#===============================================================================
# Finishing Print Statement
echo "[+] Lets Roll" >> ~/Report.txt
