<#=============================================================================================
Script by    : Leo Nguyen
Website      : www.bonguides.com
Telegram     : https://t.me/bonguides
Discord      : https://discord.gg/fUVjuqexJg
YouTube      : https://www.youtube.com/@BonGuides

Script Highlights:
~~~~~~~~~~~~~~~~~
#. Install Windows Package Manager (winget).
============================================================================================#>

if (-not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need to have Administrator rights to run this script!`nPlease re-run this script as an Administrator in an elevated powershell prompt!"
    break
}

# Create temporary directory
    $null = New-Item -Path $env:temp\temp -ItemType Directory -Force
    Set-Location $env:temp\temp
    $path = "$env:temp\temp"

# Install C++ Runtime framework packages for Desktop Bridge
    $ProgressPreference='Silent'
    $url = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
    (New-Object Net.WebClient).DownloadFile($url, "$env:temp\temp\Microsoft.VCLibs.x64.14.00.Desktop.appx")
    Add-AppxPackage -Path Microsoft.VCLibs.x64.14.00.Desktop.appx -ErrorAction SilentlyContinue | Out-Null

# Install Microsoft.UI.Xaml through Nuget.
    Write-Host "Downloading Windows Package Manager..." -ForegroundColor Green
    $ProgressPreference='Silent'
    $url = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    (New-Object Net.WebClient).DownloadFile($url, "$env:temp\temp\nuget.exe")
    .\nuget.exe install Microsoft.UI.Xaml -Version 2.7 | Out-Null
    Add-AppxPackage -Path "$path\Microsoft.UI.Xaml.2.7.0\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx" -ErrorAction:SilentlyContinue | Out-Null

# Download winget and license file the install it
    Write-Host "Installing Windows Package Manager..." -ForegroundColor Green
    function getLink($match) {
        $uri = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
        $data = $get[0].assets | Where-Object name -Match $match
        return $data.browser_download_url
    }

    $url = getLink("msixbundle")
    $licenseUrl = getLink("License1.xml")

    # Finally, install winget
    $fileName = 'winget.msixbundle'
    $licenseName = 'license1.xml'

    (New-Object Net.WebClient).DownloadFile($url, "$env:temp\temp\$fileName")
    (New-Object Net.WebClient).DownloadFile($licenseUrl, "$env:temp\temp\$licenseName")

    Add-AppxProvisionedPackage -Online -PackagePath $fileName -LicensePath $licenseName | Out-Null

$wpath = "C:\Program Files\WindowsApps"
$winget = Get-ChildItem $wpath -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.name -like "AppInstallerCLI.exe" -or $_.name -like "WinGet.exe" } | Select-Object -ExpandProperty fullname -ErrorAction SilentlyContinue

# If there are multiple versions, select latest.
    if ($winget.count -gt 1){ $winget = $winget[-1] }
    $wingetPath = [string]((Get-Item $winget).Directory.FullName)


# Checking installed apps
    Write-Host "The Windows Package Manager has been installed." -ForegroundColor Green
    Write-Host "Winget version: $(& "$wingetPath\winget.exe" -v) `n" -ForegroundColor Green

# Cleanup
    Remove-Item $path\* -Recurse -Force
