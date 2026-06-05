$scripts = @(
	{
		Remove-Item -LiteralPath 'C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk', 'C:\Windows\System32\OneDriveSetup.exe', 'C:\Windows\SysWOW64\OneDriveSetup.exe' -ErrorAction 'Continue';
	};
	{
		Remove-Item -LiteralPath 'Registry::HKLM\Software\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate' -Force -ErrorAction 'SilentlyContinue';
	};
	{
		reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" /v ConfigureChatAutoInstall /t REG_DWORD /d 0 /f;
	};
	{
		& 'C:\Windows\Setup\Scripts\RemovePackages.ps1';
	};
	{
		& 'C:\Windows\Setup\Scripts\RemoveCapabilities.ps1';
	};
	{
		& 'C:\Windows\Setup\Scripts\RemoveFeatures.ps1';
	};
	{
		net.exe accounts /maxpwage:UNLIMITED;
	};
	{
		reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
	};
	{
		netsh.exe advfirewall firewall set rule group="@FirewallAPI.dll,-28752" new enable=Yes;
		reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f;
	};
	{
		# Enable Wake-on-LAN via registry
		Get-ChildItem 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4D36E972-E325-11CE-BFC1-08002BE10318}' -ErrorAction SilentlyContinue | ForEach-Object {
			Set-ItemProperty -LiteralPath $_.PSPath -Name '*WakeOnMagicPacket' -Value 1 -Type DWord -ErrorAction SilentlyContinue;
		};
	};

	{
		# Write LayoutModification.json for UWP app pins at first user logon
		$lmDir = 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell'
		New-Item -Path $lmDir -ItemType Directory -Force | Out-Null
		'{"pinnedList":[{"packagedAppId":"Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"},{"packagedAppId":"Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"},{"packagedAppId":"Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"},{"packagedAppId":"NVIDIACorp.NVIDIAControlPanel_56jybvy8sckqj!App"},{"packagedAppId":"RealtekSemiconductorCorp.RealtekAudioControl_dt26b99r8h8gj!App"}]}' | Set-Content "$lmDir\LayoutModification.json" -Encoding UTF8;
		# Also write LayoutModification.xml for taskbar pins (OEM approach)
		'<LayoutModificationTemplate xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification" xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" Version="1"><CustomTaskbarLayoutCollection PinListPlacement="Replace"><defaultlayout:TaskbarLayout><taskbar:TaskbarPinList><taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\File Explorer.lnk"/><taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"/><taskbar:UWA AppUserModelID="Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"/></taskbar:TaskbarPinList></defaultlayout:TaskbarLayout></CustomTaskbarLayoutCollection></LayoutModificationTemplate>' | Set-Content "$lmDir\LayoutModification.xml" -Encoding UTF8;
	};

	{
		Remove-Item -LiteralPath 'C:\Users\Public\Desktop\Microsoft Edge.lnk' -ErrorAction 'SilentlyContinue' -Verbose;
	};
	{
		reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f;
	};
	{
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f;
	};
	{
		reg.exe add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKLM\Software\Policies\Microsoft\Edge" /v HideFirstRunExperience /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v StartupBoostEnabled /t REG_DWORD /d 0 /f;
	};
	{
		& 'C:\Windows\Setup\Scripts\SetStartPins.ps1';
	};
	{
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ControlAnimations" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TaskbarAnimations" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMAeroPeekEnabled" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMSaveThumbnailEnabled" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ThumbnailsOrIcon" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ComboBoxAnimation" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListBoxSmoothScrolling" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
		Set-ItemProperty -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow" -Name 'DefaultValue' -Value 1 -Type 'DWord' -Force;
	};
	{
		# Copilot off
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f;
	};
	{
		# Telemetry level 1
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f;
		reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f;
	};
	{
		# Windows Update active hours 8-23
		reg.exe add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v ActiveHoursStart /t REG_DWORD /d 8 /f;
		reg.exe add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v ActiveHoursEnd /t REG_DWORD /d 23 /f;
	};
	{
		# NumLock on at boot
		Set-ItemProperty -LiteralPath 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -Value '2' -Type String -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'InitialKeyboardIndicators' -Value '2' -Type String -Force;
	};
	{
		# Assign drive letters: Disk 2 (render NVMe) -> D: and Disk 0 (18TB data) -> E:
		$renderPart = Get-Disk -Number 2 -ErrorAction SilentlyContinue | Get-Partition -ErrorAction SilentlyContinue | Where-Object { $_.Type -notin @('System','Reserved','Recovery') -and $_.Size -gt 1GB } | Sort-Object Size -Descending | Select-Object -First 1;
		if ($renderPart -and $renderPart.DriveLetter -ne 'D') { $renderPart | Set-Partition -NewDriveLetter D -ErrorAction SilentlyContinue; };
		$dataPart = Get-Disk -Number 0 -ErrorAction SilentlyContinue | Get-Partition -ErrorAction SilentlyContinue | Where-Object { $_.Type -notin @('System','Reserved','Recovery') -and $_.Size -gt 1GB } | Sort-Object Size -Descending | Select-Object -First 1;
		if ($dataPart -and $dataPart.DriveLetter -ne 'E') { $dataPart | Set-Partition -NewDriveLetter E -ErrorAction SilentlyContinue; };
	};
	{
		# Developer Mode
		reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 1 /f;
	};
	{
		# WSL2 components
		Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart -ErrorAction SilentlyContinue;
		Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart -ErrorAction SilentlyContinue;
	};
	{
		# Power settings
		powercfg.exe /CHANGE standby-timeout-ac 0;
		powercfg.exe /CHANGE monitor-timeout-ac 30;
	};
	{
		# Additional Consumer Experience keys
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableCloudOptimizedContent /t REG_DWORD /d 1 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableConsumerAccountStateContent /t REG_DWORD /d 1 /f;
	};
	{
		# Edge clean settings - disable all non-browser features
		# Suppress Chrome desktop shortcut creation
		reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v CreateDesktopShortcut /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v CreateDesktopShortcutDefault /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v NewTabPageContentEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v NewTabPageQuickLinksEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v NewTabPageAllowedBackgroundTypes /t REG_DWORD /d 3 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v HubsSidebarEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v DiscoverEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v EdgeShoppingAssistantEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v PaymentMethodQueryEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v CryptoWalletEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v ShowMicrosoftRewards /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v ShowRecommendationsEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v SpotlightExperiencesAndRecommendationsEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v PersonalizationReportingEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v MicrosoftEdgeInsiderPromotionEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v AutoImportAtFirstRun /t REG_DWORD /d 4 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v ImportBrowserDataOnEachLaunch /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v DiagnosticData /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v SendSiteInfoToImproveServices /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v CopilotCDPPageContext /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v Microsoft365CopilotChatIconEnabled /t REG_DWORD /d 0 /f;
	};

	{
		# Create This PC and Control Panel shortcuts for Start menu pins
		$shell = New-Object -ComObject WScript.Shell;
		$sc = $shell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\This PC.lnk");
		$sc.TargetPath = 'explorer.exe'; $sc.Arguments = 'shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}'; $sc.IconLocation = '%SystemRoot%\System32\imageres.dll,104'; $sc.Save();
		$sc2 = $shell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\Control Panel.lnk");
		$sc2.TargetPath = 'explorer.exe'; $sc2.Arguments = 'shell:::{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'; $sc2.IconLocation = '%SystemRoot%\System32\shell32.dll,21'; $sc2.Save();
	};

	{
		# Pre-seed Greenshot config to Default user profile
		$dest = 'C:\Users\Default\AppData\Roaming\Greenshot';
		New-Item -Path $dest -ItemType Directory -Force -ErrorAction SilentlyContinue;
		Copy-Item -Path 'C:\Windows\Setup\Scripts\Greenshot.ini' -Destination $dest -Force;
	};
);

& {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Id 0 -Activity 'Running scripts to customize your Windows installation. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command &#xAB;{0}&#xBB;.' -f $(
      $script.ToString().Trim() -replace '\s+', ' ' -replace '^(.{99})(.+)$', '$1&#x2026;';
    );
    $start = [datetime]::Now;
    & $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *>&1 | Out-String -Width 1KB -Stream >> "C:\Windows\Setup\Scripts\Specialize.log";