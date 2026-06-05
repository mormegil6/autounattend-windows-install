# Runs elevated via scheduled task at first logon - no UAC prompts
$log = 'C:\Windows\Setup\Scripts\InstallApps.log'
"$(Get-Date) Starting InstallApps" | Out-File $log
Start-Sleep -Seconds 300
"$(Get-Date) Sleep done, updating winget sources" | Out-File $log -Append
winget source update --disable-interactivity *>> $log
"$(Get-Date) Source update done, installing apps" | Out-File $log -Append
# NVIDIA driver first - ensures GPU is stable for the rest of the session
winget install --id Greenshot.Greenshot --silent --accept-package-agreements --accept-source-agreements *>> $log
# Override Greenshot ini after install (winget may reset it)
$gsIniDest = "$env:APPDATA\Greenshot"
New-Item -Path $gsIniDest -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
Copy-Item -Path 'C:\Windows\Setup\Scripts\Greenshot.ini' -Destination $gsIniDest -Force
winget install --id WinDirStat.WinDirStat --silent --accept-package-agreements --accept-source-agreements *>> $log
winget install --id Microsoft.PowerToys --scope machine --silent --accept-package-agreements --accept-source-agreements *>> $log
winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements *>> $log
winget install --id Notepad++.Notepad++ --silent --accept-package-agreements --accept-source-agreements *>> $log
winget install --id 7zip.7zip --silent --accept-package-agreements --accept-source-agreements *>> $log
winget install --id Microsoft.VisualStudioCode --scope machine --silent --accept-package-agreements --accept-source-agreements *>> $log
winget install --id VideoLAN.VLC --silent --accept-package-agreements --accept-source-agreements *>> $log
winget install --id Google.Chrome --silent --accept-package-agreements --accept-source-agreements *>> $log
winget install --id Microsoft.PowerShell --silent --accept-package-agreements --accept-source-agreements *>> $log
winget install --id REALiX.HWiNFO --silent --accept-package-agreements --accept-source-agreements *>> $log
# Copy HWiNFO shortcut to ASCII path for reliable Start menu pinning
$hwReg = [char]0x00ae
$hwSrc = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\HWiNFO$hwReg 64\HWiNFO$hwReg 64.lnk"
$hwDst = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\HWiNFO64.lnk"
if (Test-Path $hwSrc) { Copy-Item $hwSrc $hwDst -Force }
# Python 3 - direct install from python.org (winget --scope machine unreliable)
"$(Get-Date) Installing Python 3" | Out-File $log -Append
$py3exe = "$env:TEMP\python3-installer.exe"
Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.13.3/python-3.13.3-amd64.exe' -OutFile $py3exe -UseBasicParsing
Start-Process $py3exe -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1 AssociateFiles=0' -Wait
Remove-Item $py3exe -Force -ErrorAction SilentlyContinue
"$(Get-Date) Python 3 done" | Out-File $log -Append
# Python 2.7 (EOL, not in winget - install directly)
"$(Get-Date) Installing Python 2.7" | Out-File $log -Append
$py2msi = "$env:TEMP\python-2.7.18.amd64.msi"
Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/2.7.18/python-2.7.18.amd64.msi' -OutFile $py2msi -UseBasicParsing
Start-Process msiexec.exe -ArgumentList "/i `"$py2msi`" /quiet /norestart TARGETDIR=C:\Python27 ADDLOCAL=ALL" -Wait
# Create python2.exe so 'python2' works in terminal
Copy-Item 'C:\Python27\python.exe' 'C:\Python27\python2.exe' -Force -ErrorAction SilentlyContinue
# Add C:\Python27 to system PATH (after Python3 so 'python' still calls Python 3)
$mp = [Environment]::GetEnvironmentVariable('PATH','Machine')
if ($mp -notlike '*Python27*') { [Environment]::SetEnvironmentVariable('PATH', $mp + ';C:\Python27', 'Machine') }
"$(Get-Date) Python 2.7 done" | Out-File $log -Append
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements *>> $log
"$(Get-Date) All installs done" | Out-File $log -Append
# Schedule a delayed Chrome shortcut cleanup (Chrome recreates shortcut after our cleanup)
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -Command "Start-Sleep 60; Remove-Item -Path \"C:\\Users\\User\\Desktop\\Google Chrome.lnk\" -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"C:\\Users\\Public\\Desktop\\Google Chrome.lnk\" -Force -ErrorAction SilentlyContinue; Unregister-ScheduledTask -TaskName ChromeShortcutCleanup -Confirm:$false"'
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(2)
Register-ScheduledTask -TaskName 'ChromeShortcutCleanup' -Action $action -Trigger $trigger -RunLevel Highest -Force -ErrorAction SilentlyContinue | Out-Null
# Wait for Chrome/VLC background post-install tasks to finish
Start-Sleep -Seconds 20
# Remove desktop shortcuts created by installed apps
$desktops = @(
    "C:\Users\User\Desktop",
    "$env:PUBLIC\Desktop",
    [System.Environment]::GetFolderPath('CommonDesktopDirectory')
) | Select-Object -Unique
foreach ($d in $desktops) {
    Get-ChildItem -Path $d -Filter '*.lnk' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}
# Install OpenSSH Server (Feature-on-Demand) - done here post-logon where networking is up
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue | Out-Null
Start-Service sshd -ErrorAction SilentlyContinue
Set-Service -Name sshd -StartupType Automatic -ErrorAction SilentlyContinue
# sshd_config only exists after the service first starts; now set port 41
$sshdConf = 'C:\ProgramData\ssh\sshd_config'
if (Test-Path $sshdConf) {
    (Get-Content $sshdConf) -replace '#?Port 22','Port 41' | Set-Content $sshdConf
    Restart-Service sshd -ErrorAction SilentlyContinue
}
New-NetFirewallRule -Name 'sshd-41' -DisplayName 'OpenSSH Server (port 41)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 41 -ErrorAction SilentlyContinue | Out-Null
# Create .lnk shortcuts for Calculator, Notepad, Terminal with correct icons
$wsh2 = New-Object -ComObject WScript.Shell
$progDir = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$expl = "$env:SystemRoot\explorer.exe"
# Extract Calculator icon from package Assets (PNG-to-ICO conversion)
$calcIco = $null
try {
    $calcPkg = Get-AppxPackage -Name Microsoft.WindowsCalculator -ErrorAction SilentlyContinue
    if ($calcPkg) {
        $assets = Join-Path $calcPkg.InstallLocation 'Assets'
        # Get 32x32 Calculator icon PNG (targetsize-32 is already correct size, no downsampling needed)
        $png = Get-ChildItem $assets -Filter 'CalculatorAppList.targetsize-32.png' -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $png) { $png = Get-ChildItem $assets -Filter 'CalculatorAppList.scale-200.png' -ErrorAction SilentlyContinue | Select-Object -First 1 }
        if ($png -and $png.FullName) {
            Add-Type -AssemblyName System.Drawing
            $bmp = [System.Drawing.Bitmap]::new([string]$png.FullName)
            $ico = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
            $calcIco = 'C:\Windows\Setup\Scripts\CalcIcon.ico'
            $fs = [System.IO.FileStream]::new([string]$calcIco, [System.IO.FileMode]::Create)
            $ico.Save($fs); $fs.Close(); $ico.Dispose(); $bmp.Dispose()
        }
    }
} catch {}
# Create Calculator.lnk shortcut
$calcLnk = $wsh2.CreateShortcut("$progDir\Calculator.lnk")
$calcLnk.TargetPath = $expl
$calcLnk.Arguments = 'shell:AppsFolder\Microsoft.WindowsCalculator_8wekyb3d8bbwe!App'
if ($calcIco -and (Test-Path $calcIco)) { $calcLnk.IconLocation = "$calcIco,0" }
$calcLnk.Save()

# Extract Terminal icon from package Assets (same approach as Calculator)
$termIco = $null
try {
    # Try Get-AppxPackage first (reliable on fresh install after winget upgrade)
    $termPkg = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
    $termLoc = if ($termPkg -and (Test-Path (Join-Path $termPkg.InstallLocation 'Assets'))) {
        $termPkg.InstallLocation
    } else {
        # Fallback: find any Terminal version with Assets accessible
        $found = Get-ChildItem 'C:\Program Files\WindowsApps' -Filter 'Microsoft.WindowsTerminal_*_x64__8wekyb3d8bbwe' -ErrorAction SilentlyContinue |
                 Where-Object { Test-Path (Join-Path $_.FullName 'Assets') } |
                 Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($found) { $found.FullName } else { $null }
    }
    if ($termLoc) {
        $termAssets = Join-Path $termLoc 'Assets'
        $termPng = Get-ChildItem $termAssets -Filter 'Terminal_*targetsize-32*.png' -ErrorAction SilentlyContinue |
                   Where-Object { $_.Name -notmatch 'contrast|unplated' } | Select-Object -First 1
        if (-not $termPng) {
            $termPng = Get-ChildItem $termAssets -Filter '*.png' -ErrorAction SilentlyContinue |
                       Where-Object { $_.Name -match 'targetsize-32' -and $_.Name -notmatch 'contrast|unplated' } | Select-Object -First 1
        }
        if (-not $termPng) {
            $termPng = Get-ChildItem $termAssets -Filter '*.png' -ErrorAction SilentlyContinue |
                       Sort-Object Length -Descending | Select-Object -First 1
        }
        if ($termPng -and $termPng.FullName) {
            Add-Type -AssemblyName System.Drawing
            $bmp = [System.Drawing.Bitmap]::new([string]$termPng.FullName)
            $ico = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
            $termIco = 'C:\Windows\Setup\Scripts\TerminalIcon.ico'
            $fs = [System.IO.FileStream]::new([string]$termIco, [System.IO.FileMode]::Create)
            $ico.Save($fs); $fs.Close(); $ico.Dispose(); $bmp.Dispose()
        }
    }
} catch {}

# Extract Notepad icon from current package exe to stable .ico path
$notepadIco = $null
try {
    $notepadPkg = Get-AppxPackage -Name Microsoft.WindowsNotepad -ErrorAction SilentlyContinue
    if ($notepadPkg) {
        $notepadExe = Join-Path (Join-Path $notepadPkg.InstallLocation 'Notepad') 'Notepad.exe'
        if (Test-Path $notepadExe) {
            Add-Type -AssemblyName System.Drawing
            $ico = [System.Drawing.Icon]::ExtractAssociatedIcon([string]$notepadExe)
            $notepadIco = 'C:\Windows\Setup\Scripts\NotepadIcon.ico'
            $fs = [System.IO.FileStream]::new([string]$notepadIco, [System.IO.FileMode]::Create)
            $ico.Save($fs); $fs.Close(); $ico.Dispose()
        }
    }
} catch {}

@{
    'Notepad.lnk'    = @{ A='shell:AppsFolder\Microsoft.WindowsNotepad_8wekyb3d8bbwe!App';    P='Microsoft.WindowsNotepad';    E='Notepad.exe'; Sub='Notepad'; UseNotepadIco=$true }
    'Terminal.lnk'   = @{ A='shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App';   P='Microsoft.WindowsTerminal';   E='wt.exe'; UseTermIco=$true }
}.GetEnumerator() | ForEach-Object {
    try {
        $info = $_.Value
        $lnk = $wsh2.CreateShortcut("$progDir\$($_.Key)")
        $lnk.TargetPath = $expl
        $lnk.Arguments = $info.A
        $pkg = Get-AppxPackage -Name $info.P -ErrorAction SilentlyContinue
        if ($pkg) {
            if ($info.ContainsKey('UseTermIco') -and $termIco -and (Test-Path $termIco)) {
                $lnk.IconLocation = "$termIco,0"
            } elseif ($info.ContainsKey('UseNotepadIco') -and $notepadIco -and (Test-Path $notepadIco)) {
                $lnk.IconLocation = "$notepadIco,0"
            } elseif ($info.ContainsKey('I')) {
                $lnk.IconLocation = "$($info.I),0"
            } else {
                $subDir = if ($info.ContainsKey('Sub')) { $info.Sub } else { '' }
                $exePath = if ($subDir) { Join-Path (Join-Path $pkg.InstallLocation $subDir) $info.E } else { Join-Path $pkg.InstallLocation $info.E }
                if (-not (Test-Path $exePath)) {
                    $found = Get-ChildItem $pkg.InstallLocation -Filter $info.E -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($found) { $exePath = $found.FullName }
                }
                if ($exePath -and (Test-Path $exePath)) { $lnk.IconLocation = "$exePath,0" }
            }
        }
        $lnk.Save()
    } catch {}
}
# Re-apply Start menu pins now that apps are installed
& 'C:\Windows\Setup\Scripts\SetStartPins.ps1'
Start-Sleep -Seconds 3
# Fallback: create Screenshots folder if UserOnce didn't
New-Item -Path 'C:\Users\User\Pictures\Screenshots' -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
# Fallback: set search box to icon only
Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
# Fallback: apply themeA if still on aero (UserOnce may have crashed before reaching theme step)
$currentTheme = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes' -ErrorAction SilentlyContinue).CurrentTheme
if ($currentTheme -notlike '*themeA*') {
    Start-Process 'C:\Windows\Resources\Themes\themeA.theme'
    Start-Sleep -Seconds 5
}
# Re-apply taskbar settings (UserOnce may have been reset by theme application)
Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' -Value 1 -Type DWord -Force
Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'MMTaskbarMode' -Value 2 -Type DWord -Force
Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'MMTaskbarGlomLevel' -Value 1 -Type DWord -Force
Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_Layout' -Value 1 -Type DWord -Force
New-Item -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Start' -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Start' -Name 'AllAppsViewMode' -Value 1 -Type DWord -Force
# Configure Windows Terminal settings
$terminalSettings = @{
    '$help' = 'https://aka.ms/terminal-documentation'
    '$schema' = 'https://aka.ms/terminal-profiles-schema'
    'defaultProfile' = '{574e775e-4f2a-5b96-ac1e-a2962a402336}'
    'copyOnSelect' = $true
    'copyFormatting' = 'none'
    'useAcrylicInTabRow' = $true
    'initialCols' = 80
    'initialRows' = 20
    'newTabMenu' = @(@{ 'type' = 'remainingProfiles' })
    'profiles' = @{
        'defaults' = @{ 'useAtlasEngine' = $true }
    }
    'schemes' = @()
}
$termDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
New-Item -Path $termDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
$terminalSettings | ConvertTo-Json -Depth 10 | Set-Content "$termDir\settings.json" -Encoding UTF8
# Set Windows Terminal as default terminal app
New-Item -Path 'HKCU:\Console\%%Startup' -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationConsole' -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -Type String -Force
Set-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -Type String -Force
# Set VisiblePlaces BEFORE deleting start2.bin so it gets encoded into regenerated start2.bin
$vpBytes = [System.Convert]::FromBase64String('hghzUqpRQ0Kfeyd2WEZZ1LwkihQM1olCoIBu2buiSILO1TQtWvpDRYLyIubq93c8L7Nn496JVUO/zmHzexipNyAGC7BRfzJMqh40zFR/cxXFpbNChn30QoCkk/rKeoi1oAc/OArogEywWobbhF28TUqwvXRK+WhPi9ZDmAcdqLxEgXX+DQiuQovaNO2XtmOU')
New-Item -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Start' -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Start' -Name 'VisiblePlaces' -Value $vpBytes -Type Binary -ErrorAction SilentlyContinue
# NOW delete start2.bin - StartMenuExperienceHost regenerates it with VisiblePlaces already set
$start2 = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"
if (Test-Path $start2) { Remove-Item $start2 -Force -ErrorAction SilentlyContinue }
Stop-Process -Name 'StartMenuExperienceHost' -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 30
# Restart Explorer so Start menu refreshes with resolved pins
Get-Process explorer | Where-Object { $_.SessionId -eq (Get-Process -Id $PID).SessionId } | Stop-Process -Force
Start-Sleep -Seconds 15
# Safety net: re-apply VisiblePlaces after Explorer restart
$vpBytes2 = [System.Convert]::FromBase64String('hghzUqpRQ0Kfeyd2WEZZ1LwkihQM1olCoIBu2buiSILO1TQtWvpDRYLyIubq93c8L7Nn496JVUO/zmHzexipNyAGC7BRfzJMqh40zFR/cxXFpbNChn30QoCkk/rKeoi1oAc/OArogEywWobbhF28TUqwvXRK+WhPi9ZDmAcdqLxEgXX+DQiuQovaNO2XtmOU')
New-Item -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Start' -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Start' -Name 'VisiblePlaces' -Value $vpBytes2 -Type Binary -ErrorAction SilentlyContinue
# Re-apply Taskband binary after Explorer restart (Explorer restart resets taskbar to defaults)
$tbBytes2 = [System.Convert]::FromBase64String('hghzUqpRQ0Kfeyd2WEZZ1LwkihQM1olCoIBu2buiSILO1TQtWvpDRYLyIubq93c8L7Nn496JVUO/zmHzexipNyAGC7BRfzJMqh40zFR/cxXFpbNChn30QoCkk/rKeoi1oAc/OArogEywWobbhF28TUqwvXRK+WhPi9ZDmAcdqLxEgXX+DQiuQovaNO2XtmOU')
New-Item -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Name 'Favorites' -Value $tbBytes2 -Type Binary -Force -ErrorAction SilentlyContinue
# Delayed Chrome shortcut cleanup (Chrome recreates shortcut after install)
Start-Sleep -Seconds 30
Remove-Item -Path 'C:\Users\User\Desktop\Google Chrome.lnk' -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'C:\Users\Public\Desktop\Google Chrome.lnk' -Force -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName 'InstallApps' -Confirm:$false -ErrorAction SilentlyContinue