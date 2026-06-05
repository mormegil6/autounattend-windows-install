$scripts = @(
	{
		reg.exe add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Internet Explorer\LowRegistry\Audio\PolicyConfig\PropertyStore" /f;
	};
	{
		Remove-ItemProperty -LiteralPath 'Registry::HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'OneDriveSetup' -Force -ErrorAction 'Continue';
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f;
	};
	{
		if( [System.Environment]::OSVersion.Version.Build -lt 20000 ) {
			# Windows 10
			Set-ItemProperty -LiteralPath 'Registry::HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'EnableAutoTray' -Type 'DWord' -Value 0 -Force;
		} else {
			# Windows 11
			Register-ScheduledTask -TaskName 'ShowAllTrayIcons' -Xml $(
				Get-Content -LiteralPath "C:\Windows\Setup\Scripts\ShowAllTrayIcons.xml" -Raw;
			);
		}
	};
	{
		$names = @(
		  'ContentDeliveryAllowed';
		  'FeatureManagementEnabled';
		  'OEMPreInstalledAppsEnabled';
		  'PreInstalledAppsEnabled';
		  'PreInstalledAppsEverEnabled';
		  'SilentInstalledAppsEnabled';
		  'SoftLandingEnabled';
		  'SubscribedContentEnabled';
		  'SubscribedContent-310093Enabled';
		  'SubscribedContent-338387Enabled';
		  'SubscribedContent-338388Enabled';
		  'SubscribedContent-338389Enabled';
		  'SubscribedContent-338393Enabled';
		  'SubscribedContent-353694Enabled';
		  'SubscribedContent-353696Enabled';
		  'SubscribedContent-353698Enabled';
		  'SystemPaneSuggestionsEnabled';
		);
		
		foreach( $name in $names ) {
		  reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v $name /t REG_DWORD /d 0 /f;
		}
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v TaskbarEndTask /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\DWM" /v ColorPrevalence /t REG_DWORD /d 1 /f;
	};
	{
		# Taskbar pins: File Explorer + Terminal + Edge (binary from configured session)
		$tbBytes = [System.Convert]::FromBase64String('ALIFAAAUAB+Am9Q0QkUC8023gDiTlDRW4ZwFAAD+BEFQUFPsBAgAAwAAAAAAAAB8AgAAMVNQU1UoTJ95nzlLqNDh1C3h1fNhAAAAEQAAAAAfAAAAKAAAAE0AaQBjAHIAbwBzAG8AZgB0AC4AVwBpAG4AZABvAHcAcwBUAGUAcgBtAGkAbgBhAGwAXwA4AHcAZQBrAHkAYgAzAGQAOABiAGIAdwBlAAAAEQAAACcAAAAACwAAAP//AAARAAAADgAAAAATAAAAAgAAABEAAAAZAAAAABMAAAABAAAAhQAAABUAAAAAHwAAADoAAABNAGkAYwByAG8AcwBvAGYAdAAuAFcAaQBuAGQAbwB3AHMAVABlAHIAbQBpAG4AYQBsAF8AMQAuADIANAAuADEAMQAzADIAMQAuADAAXwB4ADYANABfAF8AOAB3AGUAawB5AGIAMwBkADgAYgBiAHcAZQAAAGkAAAAFAAAAAB8AAAAsAAAATQBpAGMAcgBvAHMAbwBmAHQALgBXAGkAbgBkAG8AdwBzAFQAZQByAG0AaQBuAGEAbABfADgAdwBlAGsAeQBiADMAZAA4AGIAYgB3AGUAIQBBAHAAcAAAAMEAAAAPAAAAAB8AAABXAAAAQwA6AFwAUAByAG8AZwByAGEAbQAgAEYAaQBsAGUAcwBcAFcAaQBuAGQAbwB3AHMAQQBwAHAAcwBcAE0AaQBjAHIAbwBzAG8AZgB0AC4AVwBpAG4AZABvAHcAcwBUAGUAcgBtAGkAbgBhAGwAXwAxAC4AMgA0AC4AMQAxADMAMgAxAC4AMABfAHgANgA0AF8AXwA4AHcAZQBrAHkAYgAzAGQAOABiAGIAdwBlAAAAAAAdAAAAIAAAAABIAAAAqdKm1nRMwk2i7C5wcqX78wAAAADNAQAAMVNQU00L1IZpkDxEgZoqVAkNzOxNAAAADAAAAAAfAAAAHQAAAEkAbQBhAGcAZQBzAFwAUwBxAHUAYQByAGUAMQA1ADAAeAAxADUAMABMAG8AZwBvAC4AcABuAGcAAAAAAEkAAAACAAAAAB8AAAAbAAAASQBtAGEAZwBlAHMAXABTAHEAdQBhAHIAZQA0ADQAeAA0ADQATABvAGcAbwAuAHAAbgBnAAAAAABJAAAADQAAAAAfAAAAGwAAAEkAbQBhAGcAZQBzAFwAVwBpAGQAZQAzADEAMAB4ADEANQAwAEwAbwBnAG8ALgBwAG4AZwAAAAAAEQAAAAQAAAAAEwAAAKlNwf8RAAAABQAAAAATAAAA/////z0AAAATAAAAAB8AAAAVAAAASQBtAGEAZwBlAHMAXABMAGEAcgBnAGUAVABpAGwAZQAuAHAAbgBnAAAAAAARAAAADgAAAAATAAAAoQQAACUAAAALAAAAAB8AAAAJAAAAVABlAHIAbQBpAG4AYQBsAAAAAAA9AAAAFAAAAAAfAAAAFQAAAEkAbQBhAGcAZQBzAFwAUwBtAGEAbABsAFQAaQBsAGUALgBwAG4AZwAAAAAAAAAAADEAAAAxU1BTsRZtRK2NcEinSEAupD14jBUAAABkAAAAABUAAABVAwAAAAAAAAAAAABBAAAAMVNQUzDxJbfvRxoQpfECYIye66wlAAAACgAAAAAfAAAACQAAAFQAZQByAG0AaQBuAGEAbAAAAAAAAAAAAC0AAAAxU1BTs3ftDRTGbEWuWyhbONewGxEAAAAHAAAAABMAAAAAAAAAAAAAAAAAAAAAABIAAAArAO++KlybkWrs3AEEBWQAAAAdAO++AgBNAGkAYwByAG8AcwBvAGYAdAAuAFcAaQBuAGQAbwB3AHMAVABlAHIAbQBpAG4AYQBsAF8AOAB3AGUAawB5AGIAMwBkADgAYgBiAHcAZQAhAEEAcABwAAAABAUiAAAAHgDvvgIAVQBzAGUAcgBQAGkAbgBuAGUAZAAAAAQFAAAAoAEAADoAH4DIJzQfEFwQQqoDLuRSh9ZoJgABACYA774SAAAAwNUZUWDs3AFWaGt5YOzcAadxX49q7NwBFABWADEAAAAAALlcW4oRAFRhc2tCYXIAQAAJAAQA7765XNWAuVxbii4AAACWggAAAAAEAAAAAAAAAAAAAAAAAAAAWSGTAFQAYQBzAGsAQgBhAHIAAAAWAA4BMgCXAQAAgVjEOiAARklMRUVYfjEuTE5LAAB8AAkABADvvrlcW4q5XFuKLgAAAHGXAAAAABYAAAAAAAAAAABSAAAAAADb3JEARgBpAGwAZQAgAEUAeABwAGwAbwByAGUAcgAuAGwAbgBrAAAAQABzAGgAZQBsAGwAMwAyAC4AZABsAGwALAAtADIAMgAwADYANwAAABwAEgAAACsA774oDmCPauzcARwAQgAAAB0A774CAE0AaQBjAHIAbwBzAG8AZgB0AC4AVwBpAG4AZABvAHcAcwAuAEUAeABwAGwAbwByAGUAcgAAABwAIgAAAB4A774CAFUAcwBlAHIAUABpAG4AbgBlAGQAAAAcAAAAAFIBAAA6AB+AyCc0HxBcEEKqAy7kUofWaCYAAQAmAO++EgAAAMDVGVFg7NwBVmhreWDs3AEx6x+VauzcARQAVgAxAAAAAAC5XFuKEQBUYXNrQmFyAEAACQAEAO++uVzVgLlcW4ouAAAAloIAAAAABAAAAAAAAAAAAAAAAAAAAFkhkwBUAGEAcwBrAEIAYQByAAAAFgDAADIAjQkAALlcoYAgAE1JQ1JPU34xLkxOSwAAVgAJAAQA7765XGKKuVxiii4AAABYiQIAAAAGAAAAAAAAAAAAAAAAAAAACLEtAE0AaQBjAHIAbwBzAG8AZgB0ACAARQBkAGcAZQAuAGwAbgBrAAAAHAASAAAAKwDvvnI5IJVq7NwBHAAaAAAAHQDvvgIATQBTAEUAZABnAGUAAAAcACIAAAAeAO++AgBVAHMAZQByAFAAaQBuAG4AZQBkAAAAHAAAAABiAQAAOgAfgMgnNB8QXBBCqgMu5FKH1mgmAAEAJgDvvhIAAADoRATUEOrcAfymXfwQ6twBSCi70hXq3AEUAFYAMQAAAAAAtlzOkBEAVGFza0JhcgBAAAkABADvvrZcFIy2XM6QLgAAAPiCAAAAAAQAAAAAAAAAAAAAAAAAAADJxq4AVABhAHMAawBCAGEAcgAAABYA0AAyAM4IAAC2XG2OIABHT09HTEV+MS5MTksAAFQACQAEAO++tlzpkLZc6ZAuAAAAWGgCAAAACAAAAAAAAAAAAAAAAAAAANyOMABHAG8AbwBnAGwAZQAgAEMAaAByAG8AbQBlAC4AbABuAGsAAAAcABIAAAArAO++SCi70hXq3AEcABoAAAAdAO++AgBDAGgAcgBvAG0AZQAAABwAIgAAAB4A774CAFUAcwBlAHIAUABpAG4AbgBlAGQAAAAcABIAAAAsAO++2wdY22Ls3AEcAAAA/w==');
		New-Item -Path 'Registry::HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Force -ErrorAction SilentlyContinue | Out-Null;
		Set-ItemProperty -LiteralPath 'Registry::HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Name 'Favorites' -Value $tbBytes -Type Binary -Force;
	};
	{
		# Start menu More Pins layout + List view for All Apps
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_Layout /t REG_DWORD /d 1 /f;
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Start" /v AllAppsViewMode /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "UnattendedSetup" /t REG_SZ /d "powershell.exe -WindowStyle \""Normal\"" -ExecutionPolicy \""Unrestricted\"" -NoProfile -File \""C:\Windows\Setup\Scripts\UserOnce.ps1\""" /f;
	};
);

& {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Id 0 -Activity 'Running scripts to modify the default user&#x2019;&#x2019;s registry hive. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command &#xAB;{0}&#xBB;.' -f $(
      $script.ToString().Trim() -replace '\s+', ' ' -replace '^(.{99})(.+)$', '$1&#x2026;';
    );
    $start = [datetime]::Now;
    & $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *>&1 | Out-String -Width 1KB -Stream >> "C:\Windows\Setup\Scripts\DefaultUser.log";