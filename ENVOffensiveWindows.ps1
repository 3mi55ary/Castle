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
# Tool Installation ============================================================
#===============================================================================

# Inveigh
iwr https://github.com/Kevin-Robertson/Inveigh/releases/download/v2.0.11/Inveigh-net8.0-v2.0.11.zip -O Inveigh.zip

# ADRecon
# mkdir ~/WindowsTools/adrecon
# git clone https://github.com/sense-of-security/ADRecon.git ~/WindowsTools/adrecon

#Get-ToolGit -name "Inveigh" -gitURL "https://github.com/Kevin-Robertson/Inveigh.git" -destination "Inveigh"

# DomainPasswordSpray
#Get-ToolGit -name "DomainPasswordSpray" -gitURL "https://github.com/dafthack/DomainPasswordSpray.git" -destination "DomainPasswordSpray"

# PowerSploit
#Get-ToolGit -name "PowerSploit" -gitURL "https://github.com/PowerShellMafia/PowerSploit.git" -destination "PowerSploit"

# SharpView
# Get-Tool -name "" -gitURL "" -destination ""

# Snaffler
#Get-ToolGit -name "Snaffler" -gitURL "https://github.com/SnaffCon/Snaffler.git" -destination "Snaffler"

# 

# BloodhoundCE
# Get-ToolFile -name "BloodHoundCE" -URL "https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-windows-amd64.zip" -destination "BloodHoundCE"

# Mimikatz
#Get-ToolGit -name "Mimikatz" -gitURL "https://github.com/ParrotSec/mimikatz.git" -destination "mimikatz"

# Rubeus
#Get-ToolGit -name "Rubeus" -gitURL "https://github.com/GhostPack/Rubeus.git" -destination "Rubeus"
