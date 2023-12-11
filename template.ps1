<#=============================================================================================
Script by    : Leo Nguyen
Website      : www.bonguides.com
Telegram     : https://t.me/bonguides
Discord      : https://discord.gg/fUVjuqexJg
YouTube      : https://www.youtube.com/@BonGuides
Description  : Export Microsoft 365 users' last logon time report using PowerShell

Script Highlights:
~~~~~~~~~~~~~~~~~
#. Single script allows you to generate last login reports.
============================================================================================#>

param (
    [switch]$InstallMainBasic,
    [switch]$InstallMainAll,
    [switch]$OutCSV,
    [switch]$OutGridView
)

if (-not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need to have Administrator rights to run this script!`nPlease re-run this script as an Administrator in an elevated powershell prompt!"
    # Start-Process -Verb runas -FilePath powershell.exe -ArgumentList "irm  | iex"
    break
}

# Install the required Microsoft Graph PowerShell SDK modules
    Set-ExecutionPolicy Bypass -Scope Process -Force | Out-Null
    iex "& { $(irm bonguides.com/graph/modulesinstall) } -InstallMainBasic"

# Output options to console, graphical grid view or export to CSV file.
if($OutCSV.IsPresent) {
    # $result | Sort-Object assignedlicenses -Descending 
    # $result | Out-GridView
    $filePath = "$env:userprofile\desktop\Result-$(Get-Date -Format yyyy-mm-dd-hh-mm-ss).csv"
    $result | Export-CSV $filePath -NoTypeInformation -Encoding UTF8
    Write-Host "`nThe report is saved to: $filePath `n" -ForegroundColor Cyan
    Invoke-Item "$env:userprofile\desktop"
} elseif ($OutGridView.IsPresent) {
    $output | Out-GridView
} else {
    $output | Format-Table
}
