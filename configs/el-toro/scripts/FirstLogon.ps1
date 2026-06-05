$scripts = @(
	{
		Set-ItemProperty -LiteralPath 'Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoLogonCount' -Type 'DWord' -Force -Value 0;
	};
	{
		cmd.exe /c "rmdir C:\Windows.old";
	};
	{
		Remove-Item -LiteralPath @(
		  'C:\Windows\Panther\unattend.xml';
		  'C:\Windows\Panther\unattend-original.xml';
		  'C:\Windows\Setup\Scripts\Wifi.xml';
		) -Force -ErrorAction 'SilentlyContinue' -Verbose;
	};
	{
		# Register elevated scheduled task for winget installs
		# Done here (not Specialize) because User account must exist for SID resolution
		$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Normal -ExecutionPolicy Unrestricted -NoProfile -File "C:\Windows\Setup\Scripts\InstallApps.ps1"';
		$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(10);
		$principal = New-ScheduledTaskPrincipal -UserId 'User' -LogonType Interactive -RunLevel Highest;
		$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 2) -StartWhenAvailable;
		Register-ScheduledTask -TaskName 'InstallApps' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null;
	};
);

& {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Id 0 -Activity 'Running scripts to finalize your Windows installation. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command &#xAB;{0}&#xBB;.' -f $(
      $script.ToString().Trim() -replace '\s+', ' ' -replace '^(.{99})(.+)$', '$1&#x2026;';
    );
    $start = [datetime]::Now;
    & $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *>&1 | Out-String -Width 1KB -Stream >> "C:\Windows\Setup\Scripts\FirstLogon.log";