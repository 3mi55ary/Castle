# Windows Enumeration Script
# Usage: Run in PowerShell or paste into a compromised environment
# Reference: https://swisskyrepo.github.io/InternalAllTheThings/redteam/escalation/windows-privilege-escalation/

Write-Host "`n=== SYSTEM INFORMATION ==="
Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber
systeminfo
Get-HotFix | Format-Table -AutoSize

Write-Host "`n=== PROCESSES & SERVICES ==="
tasklist /svc

Write-Host "`n=== ENVIRONMENT VARIABLES ==="
Get-ChildItem Env:

Write-Host "`n=== INSTALLED PROGRAMS ==="
Get-WmiObject -Class Win32_Product | Select-Object Name, Version

Write-Host "`n=== NETWORK CONNECTIONS ==="
netstat -ano

Write-Host "`n=== USER ENUMERATION ==="
Write-Host "`n-- Logged-in Users --"
query user

Write-Host "`n-- Local Users --"
net user

Write-Host "`n-- Local Groups --"
net localgroup

Write-Host "`n-- Administrators Group --"
net localgroup administrators

Write-Host "`n-- Account Policies --"
net accounts

Write-Host "`n=== CURRENT USER CONTEXT ==="
Write-Host "Username: $env:USERNAME"
whoami /priv
whoami /groups
