# Require in elecated mode
if (-not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Warning "You need to have Administrator rights to run this script!`nPlease re-run this script as an Administrator in an elevated powershell prompt!"
  # Start-Process -Verb runas -FilePath powershell.exe -ArgumentList "irm msgang.com/config | iex"
  break
}

$edition = (Get-CimInstance Win32_OperatingSystem).Caption

# Build a runspace
  $runspace = [runspacefactory]::CreateRunspace()
  $runspace.ApartmentState = 'STA'
  $runspace.ThreadOptions = 'ReuseThread'
  $runspace.Open()

# Share info between runspaces
  $sync = [hashtable]::Synchronized(@{})
  $sync.runspace = $runspace
  $sync.host = $host
  $sync.DebugPreference = $DebugPreference
  $sync.VerbosePreference = $VerbosePreference

# Add shared data to the runspace
  $runspace.SessionStateProxy.SetVariable("sync", $sync)

# 1. Turn off UCA
  Write-Host "`n1. Turning off UAC..." -ForegroundColor Green
  Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0  | Out-Null
  powercfg -change -monitor-timeout-ac 0
  Start-Sleep -Second 1

# 2. Turn off News and Interests
  Write-Host "2. Turning off News and Interests..." -ForegroundColor Green
  TASKKILL /IM explorer.exe /F | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2 -ErrorAction:SilentlyContinue  | Out-Null
  Start-Process explorer.exe
  Start-Sleep -Second 1

# 3. Remove search highlight
  Write-Host "3. Turning off search highlight..." -ForegroundColor Green
  $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
  $Name         = 'EnableDynamicContentInWSB'
  # $Value        = '0x00000000'
  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
  New-ItemProperty $registryPath -Name $Name -PropertyType DWORD -Value 0 | Out-Null
  Start-Sleep -Second 1

# 4. LaunchTo This PC (disable Quick Access)
  Write-Host "4. Turning off Quick Access..." -ForegroundColor Green
  $scriptBlock = {
    $registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $regName = 'LaunchTo'
    $regValue = Get-ItemPropertyValue -Path $registryPath -Name $regName -ErrorAction SilentlyContinue | Out-Null

    If ($regValue -eq $Null) {
      New-ItemProperty -Path $registryPath -Name $regName -Value '1' -Type 'DWORD' -Force | Out-Null
    } else {
        Set-Itemproperty -Path $registryPath -Name $regName -Value '1' -Type 'DWORD' | Out-Null
    }
  }
  $PSIinstance = [powershell]::Create().AddScript($scriptBlock)
  $PSIinstance.Runspace = $runspace
  $result = $PSIinstance.BeginInvoke()
  Start-Sleep 1
  $PSIinstance.Dispose()

# 5. AutoCheckSelect
  Write-Host "5. Enabling checkbox select..." -ForegroundColor Green
  $registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  $regName = 'AutoCheckSelect'

  function RefreshEnv {
    $userpath = [System.Environment]::GetEnvironmentVariable("Path","User")
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    $env:Path = $userpath + ";" + $machinePath 
  }

# 6. Installing Chocolatey package manager
  Write-Host "6. Installing Chocolatey package manager..." -ForegroundColor Green
  $scriptBlock = {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  }
  $PSIinstance = [powershell]::Create().AddScript($scriptBlock)
  $PSIinstance.Runspace = $runspace
  $result = $PSIinstance.BeginInvoke()

  do { 
    Start-Sleep -Second 1 
  } until ($result.IsCompleted -eq "true")

  $PSIinstance.Dispose()

# 7. Installing the required application...
  Write-Host '7. Installing the required application...' -ForegroundColor Green
  $scriptBlock = {
    RefreshEnv
    Set-Location 'C:\ProgramData\chocolatey\bin'
    .\choco.exe feature enable -n allowGlobalConfirmation
    .\choco.exe install oh-my-posh -y
    # .\choco install adblockpluschrome -y
    .\choco install winscp -y
<#     .\choco install teamviewer.host	-y
    $apps = @(
      'GoogleChrome', 
      'VisualStudioCode', 
      'audacity', 
      'pdfsam', 
      'github-desktop'
    )
    
    foreach ($app in $apps) {
      .\choco install $app -y
    } #>
  }

  $PSIinstance = [powershell]::Create().AddScript($scriptBlock)
  $PSIinstance.Runspace = $runspace
  $result = $PSIinstance.BeginInvoke()
  do { 
    Start-Sleep -Second 1 
  } until ($result.IsCompleted -eq "true")

  $PSIinstance.Dispose()

# 8. PowerShell console customizations
  Write-Host "8. Customizing PowerShell console..." -ForegroundColor Green
  RefreshEnv
  oh-my-posh font install JetBrainsMono | Out-Null

  $filePath = "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk"
  Remove-Item -Path $filePath -Force
  $uri = 'https://filedn.com/lOX1R8Sv7vhpEG9Q77kMbn0/Temp/Windows%20PowerShell.lnk'
  (New-Object Net.WebClient).DownloadFile($uri, $filePath)

# 9. Activating Windows license.
  # Write-Host "9. Activating Windows license..." -ForegroundColor Green
  # Invoke-RestMethod msgang.com/win | Invoke-Expression

# 10. Creating shortcuts to desktop
  Write-Host "10. Creating shortcuts to desktop..." -ForegroundColor Green
  Copy-Item "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\Control Panel.lnk" "$env:userprofile\Desktop\"

# 11. Change to the Light theme
  Write-Host "11. Changing to the Light theme..." -ForegroundColor Green
  Start-Process -Filepath "C:\Windows\Resources\Themes\light.theme"
  Start-Sleep -Seconds 3
  Get-Process -ProcessName 'SystemSettings' | Stop-Process

# 12. Configure Terminal
  Write-Host "12. Configure Terminal..." -ForegroundColor Green
  $filePath = "$env:userprofile\Appdata\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
  Remove-Item -Path $filePath -Force
  $uri = 'https://filedn.com/lOX1R8Sv7vhpEG9Q77kMbn0/Temp/settings.json'
  (New-Object Net.WebClient).DownloadFile($uri, $filePath)




Write-Host "Completed..." -ForegroundColor Green
Write-Host "Restarting..." -ForegroundColor Yellow
#Restart-Computer
