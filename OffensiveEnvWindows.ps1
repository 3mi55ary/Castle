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

# Function to Download a File
function Get-ToolFile($name, $url, $destination) {
    $fullPath = Join-Path $ToolkitRoot $destination
    if (-Not (Test-Path $fullPath)) {
        Write-Host "[+] Downloading $name..."
        Invoke-WebRequest -Uri $url -OutFile $fullPath
    } else {
        Write-Host "[-] $name already exists. Skipping..."
    }
}

# Run a Desired EXE
function Run-EXE($exe, $args) {
    if (-not (Test-Path $exe)) {
        Write-Host "[!] Executable not found: $exe" -ForegroundColor Red
        return
    }
    Write-Host "[+] Running: $exe $args" -ForegroundColor Green
    & $exe @args
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

# Docker Desktop
Get-ToolFile -name "Docker Desktop" -URL "https://desktop.docker.com/win/main/amd64/Docker Desktop Installer.exe" -destination "DockerDesktop"
Run-EXE "$env:USERPROFILE\OffensiveTools\DockerDesktop\Docker Desktop Installer.exe"

# BloodhoundCE
# Get-ToolFile -name "BloodHoundCE" -URL "https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-windows-amd64.zip" -destination "BloodHoundCE"

# Bloodhound
# Get-ToolGit -name "" -gitURL "" -destination ""

# Mimikatz
Get-ToolGit -name "Mimikatz" -gitURL "https://github.com/ParrotSec/mimikatz.git" -destination "mimikatz"

# Rubeus
Get-ToolGit -name "Rubeus" -gitURL "https://github.com/GhostPack/Rubeus.git" -destination "Rubeus"