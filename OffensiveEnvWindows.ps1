#===============================================================================
# SCRIPT NAME   : OffensiveEnvWindows.ps1
# DESCRIPTION   : Builds an offensive toolkit tailored to Windows
# AUTHOR        : 3mi55ary
# DATE          : 2025-08-31
# VERSION       : 1.0
# USAGE         : .\OffensiveEnvWindows.ps1
# NOTES         : RUN AS ADMINISTRATOR - Tested on Windows 10 and Windows 11
#===============================================================================

#===============================================================================
# System Preperation ===========================================================
#===============================================================================
# Verify Running as Administrator
function Check-Admin {
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "Please run this script with Administrator privileges!"
        exit
    }
}
Check-Admin

#===============================================================================
# Toolkit ======================================================================
#===============================================================================
# Set Path for Tools
$ToolkitRoot = "$env:USERPROFILE\OffensiveTools"
New-Item -ItemType Directory -Path $ToolkitRoot -Force | Out-Null

#===============================================================================
# Support Functions ============================================================
#===============================================================================
# Function to Git Clone a Designated Tool
function Get-ToolGit($name, $gitURL, $destination) {
    $fullPath = Join-Path $ToolkitRoot $destination
    if (-Not (Test-Path $fullPath)) {
        Write-Host "[+] Downloading $name..."
        git clone $gitURL $fullPath
    } else {
        Write-Host "[-] $name already exists. Skipping..."
    }
}

# Function to Download a Binary
function Get-ToolBinary($name, $url, $destination) {
    $fullPath = Join-Path $ToolkitRoot $destination
    if (-Not (Test-Path $fullPath)) {
        Write-Host "[+] Downloading $name..."
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        $zipPath = Join-Path $fullPath "$name.zip"
        Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $fullPath -Force
    } else {
        Write-Host "[-] $name already exists. Skipping..."
    }
}


#===============================================================================
# Tool Installation ============================================================
#===============================================================================

# Inveigh
Get-ToolGit -name "Inveigh" -gitURL "https://github.com/Kevin-Robertson/Inveigh.git" -destination "Inveigh"

# DomainPasswordSpray
Get-ToolGit -name "DomainPasswordSpray" -gitURL "https://github.com/dafthack/DomainPasswordSpray.git" -destination "DomainPasswordSpray"

# PowerSploit
Get-ToolGit -name "PowerSploit" -gitURL "https://github.com/PowerShellMafia/PowerSploit.git" -destination "PowerSploit"

# SharpView
# Get-Tool -name "" -gitURL "" -destination ""

# Snaffler
Get-ToolGit -name "Snaffler" -gitURL "https://github.com/SnaffCon/Snaffler.git" -destination "Snaffler"

# Install WSL for BloodhoundCE
# Get-ToolBinary -name "WSL" -URL "https://github.com/microsoft/WSL/releases/download/2.5.10/wsl.2.5.10.0.arm64.msi" -destination "WSL"

# BloodhoundCE
# Get-ToolBinary -name "BloodHoundCE" -URL "https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-windows-amd64.zip" -destination "BloodHoundCE"

# Bloodhound
# Get-ToolGit -name "" -gitURL "" -destination ""

# Mimikatz
Get-ToolGit -name "Mimikatz" -gitURL "https://github.com/ParrotSec/mimikatz.git" -destination "mimikatz"

# Rubeus
Get-ToolGit -name "Rubeus" -gitURL "https://github.com/GhostPack/Rubeus.git" -destination "Rubeus"