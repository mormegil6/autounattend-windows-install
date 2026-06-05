$scripts = @(
	{
		Get-AppxPackage -Name 'Microsoft.Windows.Ai.Copilot.Provider' | Remove-AppxPackage;
	};
	{
		Remove-Item -LiteralPath "${env:USERPROFILE}\Desktop\Microsoft Edge.lnk" -ErrorAction 'SilentlyContinue' -Verbose;
		# Remove any other desktop shortcuts (apps may create them later via InstallApps)
		Get-ChildItem -Path "$env:USERPROFILE\Desktop", "$env:PUBLIC\Desktop" -Filter '*.lnk' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue;
	};
	{
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -Type 'DWord' -Value 1;
	};
	{
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Type 'DWord' -Value 1;
	};
	{
		Set-ItemProperty -LiteralPath 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Type 'DWord' -Value 1 -Force;
	};
	{
		New-Item -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Force;
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{5399e694-6ce5-4d6c-8fce-1d8870fdcba0}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{b4bfcc3a-db2c-424c-b029-7fe99a87c641}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{a8cdff1c-4878-43be-b5fd-f8091c1c60d0}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{374de290-123f-4565-9164-39c4925e467b}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{1cf1260c-4dd0-4ebb-811f-33c572699fde}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{f02c1a0d-be21-4350-88b0-7367fc96ef3c}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{3add1653-eb32-4cb0-bbd7-dfa0abb5acca}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{645ff040-5081-101b-9f08-00aa002f954e}' -Value 0 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{20d04fe0-3aea-1069-a2d8-08002b30309d}' -Value 0 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Value 0 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{a0953c92-50dc-43bf-be83-3742fed03c9c}' -Value 1 -Type 'DWord';
		New-Item -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Force;
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{5399e694-6ce5-4d6c-8fce-1d8870fdcba0}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{b4bfcc3a-db2c-424c-b029-7fe99a87c641}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{a8cdff1c-4878-43be-b5fd-f8091c1c60d0}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{374de290-123f-4565-9164-39c4925e467b}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{1cf1260c-4dd0-4ebb-811f-33c572699fde}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{f02c1a0d-be21-4350-88b0-7367fc96ef3c}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{3add1653-eb32-4cb0-bbd7-dfa0abb5acca}' -Value 1 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{645ff040-5081-101b-9f08-00aa002f954e}' -Value 0 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{20d04fe0-3aea-1069-a2d8-08002b30309d}' -Value 0 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Value 0 -Type 'DWord';
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{a0953c92-50dc-43bf-be83-3742fed03c9c}' -Value 1 -Type 'DWord';
	};
	{
		Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start' -Name 'VisiblePlaces' -Value $( [convert]::FromBase64String('hghzUqpRQ0Kfeyd2WEZZ1LwkihQM1olCoIBu2buiSILO1TQtWvpDRYLyIubq93c8L7Nn496JVUO/zmHzexipNyAGC7BRfzJMqh40zFR/cxXFpbNChn30QoCkk/rKeoi1oAc/OArogEywWobbhF28TUqwvXRK+WhPi9ZDmAcdqLxEgXX+DQiuQovaNO2XtmOU') ) -Type 'Binary';
	};
	{
		# Create Screenshots folder
		New-Item -Path 'C:\Users\User\Pictures\Screenshots' -ItemType Directory -Force -ErrorAction SilentlyContinue;
	};
	{
		# Taskbar: combine only when full, active monitor only
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_Layout' -Value 1 -Type DWord -Force;
		New-Item -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Start' -Force -ErrorAction SilentlyContinue | Out-Null;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Start' -Name 'AllAppsViewMode' -Value 1 -Type DWord -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' -Value 1 -Type DWord -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'MMTaskbarMode' -Value 2 -Type DWord -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'MMTaskbarGlomLevel' -Value 1 -Type DWord -Force;
	};
	{
		# Accent color on title bars
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\DWM' -Name 'ColorPrevalence' -Value 1 -Type DWord -Force;
	};
	{
		# Show Task View button
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 1 -Type DWord -Force;
	};
	{
		# Force Details view on all folders
		New-Item -Path 'Registry::HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' -Force -ErrorAction SilentlyContinue;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' -Name 'Mode' -Value 4 -Type DWord -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' -Name 'LogicalViewMode' -Value 1 -Type DWord -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' -Name 'FolderType' -Value 'NotSpecified' -Type String -Force;
	};
	{
		# Disable web search in taskbar
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled' -Value 0 -Type DWord -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'CortanaConsent' -Value 0 -Type DWord -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'AllowSearchToUseLocation' -Value 0 -Type DWord -Force;
	};
	{
		# Hide Copilot button and Smart Clipboard
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowCopilotButton' -Value 0 -Type DWord -Force;
		New-Item -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard' -Force -ErrorAction SilentlyContinue;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard' -Name 'Disabled' -Value 1 -Type DWord -Force;
		# Remove extra keyboard layouts - keep only Polish Programmers (0415:00000415)
		$langList = Get-WinUserLanguageList;
		foreach ($lang in $langList) {
			$extra = $lang.InputMethodTips | Where-Object { $_ -ne '0415:00000415' };
			foreach ($tip in $extra) { $lang.InputMethodTips.Remove($tip) | Out-Null; }
		}
		Set-WinUserLanguageList $langList -Force -ErrorAction SilentlyContinue;
		# Hide language bar
		New-Item -Path 'Registry::HKCU\Software\Microsoft\CTF\LangBar' -Force -ErrorAction SilentlyContinue | Out-Null;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\CTF\LangBar' -Name 'ShowStatus' -Value 3 -Type DWord -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\CTF\LangBar' -Name 'Label' -Value 1 -Type DWord -Force;
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\CTF\LangBar' -Name 'ExtraIconsOnMinimized' -Value 0 -Type DWord -Force;
	};
	{
		# Audio enhancements off for all render devices
		Get-ChildItem -Path 'Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render' -ErrorAction SilentlyContinue | ForEach-Object {
			$fx = Join-Path $_.PSPath 'FxProperties';
			if (Test-Path $fx) { Set-ItemProperty -LiteralPath $fx -Name '{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},6' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue; }
		};
	};
	{
		# Set WSL2 as default version
		wsl.exe --set-default-version 2;
	};
	{
		# Apply themeA (Captured Motion / Windows 11 built-in theme)
		Start-Process -FilePath 'C:\Windows\Resources\Themes\themeA.theme' -Wait;
	};


	{
		Get-Process -Name 'explorer' -ErrorAction 'SilentlyContinue' | Where-Object -FilterScript {
			$_.SessionId -eq ( Get-Process -Id $PID ).SessionId;
		} | Stop-Process -Force;
	};
);

& {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Id 0 -Activity 'Running scripts to configure this user account. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command &#xAB;{0}&#xBB;.' -f $(
      $script.ToString().Trim() -replace '\s+', ' ' -replace '^(.{99})(.+)$', '$1&#x2026;';
    );
    $start = [datetime]::Now;
    & $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *>&1 | Out-String -Width 1KB -Stream >> "$env:TEMP\UserOnce.log";