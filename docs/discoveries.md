# Hard-won technical findings

Lessons learned building Windows 11 autounattend configurations. Relevant to anyone working with the Schneegans pe.cmd framework or Windows 11 unattended setup in general.

All findings are specific to **Windows 11 25H2 (build 26100)** unless noted otherwise. Earlier builds may behave differently.

---

## pe.cmd / assert.vbs structure (critical)

The Schneegans framework builds `assert.vbs` incrementally via RunSynchronous `echo` commands in pe.cmd. Each `<Order>` adds lines.

**Order dependencies are non-obvious:**
- Order 14 opens `If actual > expected Then` for the disk size check
- Order 15 must close it with `End If` - removing Order 15 entirely breaks the VBScript
- Correct approach: replace Order 15 content but keep the `End If`

**XML escaping:**
- The `>>` operator in Order Path values must be XML-escaped as `&gt;&gt;`
- Bare `>>` in a `<Path>` element causes immediate boot failure - no error message, setup just halts

---

## diskpart sequence

- `SHRINK` before `FORMAT` is valid and intentional - diskpart shrinks raw partitions by adjusting partition table entries, not requiring a formatted filesystem
- `CLEAN` is already in the diskpart layout file - the "no partitions" assertion in `assert.vbs` can be removed safely (just keep the size/type assertions)

---

## Start menu pins (Windows 11 25H2)

- `packagedAppID` in `ConfigureStartPins` is unreliable for existing profiles
- `desktopAppLink` with `.lnk` files works reliably for installed apps
- For UWP apps (Calculator, Notepad, Terminal): use `LayoutModification.json` placed in `C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\` - this is read at profile creation time

### ConfigureStartPins consumed flag

Once `ConfigureStartPins` has been read by `StartMenuExperienceHost`, it is marked as consumed. Subsequent `start2.bin` deletions will **not** re-apply the pins - the policy is ignored after first use. To force re-application, write to the `ConfigureStartPins` registry key again from SYSTEM context; this resets the consumed flag and triggers a fresh read on the next `StartMenuExperienceHost` restart.

### ConfigureTaskbarPins does not work on non-MDM machines (25H2)

`ConfigureTaskbarPins` set in HKLM is silently ignored on Windows 11 25H2 machines not enrolled in MDM (Intune/SCCM). Embedding the XML as Base64 does not help - the policy is simply not honoured on unmanaged devices regardless of encoding. The only reliable approach for unmanaged machines is writing the `Taskband\Favorites` binary directly to the user registry hive (`HKCU` or `HKU\DefaultUser`).

### VisiblePlaces and start2.bin regeneration

Deleting `start2.bin` and restarting `StartMenuExperienceHost` regenerates Start from ConfigureStartPins (if not yet consumed), but the regeneration process **overwrites** `VisiblePlaces` with a default value. The correct sequence is:

1. Write `VisiblePlaces` to `HKCU` (current user) **before** deleting `start2.bin` - StartMenuExperienceHost reads it and encodes it into the regenerated binary during the restart
2. Write `VisiblePlaces` again after the Explorer restart as a safety net

Setting it only after the restart is not sufficient - the value gets encoded into the binary during regeneration, not read from the registry at display time.

**RDP sessions** cause StartMenuExperienceHost to reinitialize and reset VisiblePlaces from `start2.bin`. The only durable fix is encoding it correctly into `start2.bin` at generation time (step 1 above).

---

## Calculator icon

- `CalculatorApp.exe` exists in the package but contains no embedded icons
- Icon source: `Assets\CalculatorAppList.targetsize-32.png` - already 32x32, no downsampling needed. Do **not** use `scale-200.png` - it is a larger image that gets downsampled, producing visible stripes/artifacts in the `.ico`
- Convert PNG to ICO at install time via `System.Drawing.Bitmap` → `Icon.FromHandle(GetHicon())` with explicit `[string]` cast to resolve ambiguous overload:

```powershell
$bmp = [System.Drawing.Bitmap]::new([string]$png.FullName)
$ico = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
```

---

## UserOnce.ps1 brace structure

The Schneegans script uses `@( { }; { }; ... )` block arrays. An unclosed brace causes PowerShell to silently refuse to parse the entire file - nothing in UserOnce runs, no error shown. The log file for UserOnce doesn't exist by design (it runs via RunOnce, not pe.cmd).

---

## HWiNFO shortcut naming

HWiNFO's winget install creates a shortcut containing the registered trademark character (®). This breaks Start menu pinning via `.lnk` path. Workaround: copy the shortcut to an ASCII-named path:

```powershell
$hwReg = [char]0x00ae
$hwSrc = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\HWiNFO$hwReg 64\HWiNFO$hwReg 64.lnk"
$hwDst = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\HWiNFO64.lnk"
if (Test-Path $hwSrc) { Copy-Item $hwSrc $hwDst -Force }
```

---

## OpenSSH Server - run post-logon, not in Specialize

`Add-WindowsCapability -Online` for OpenSSH.Server hangs for approximately one hour during the Specialize phase because networking is not fully initialised at that point. It must run post-logon (e.g. in `InstallApps.ps1`).

Once installed, `sshd_config` only exists after the service has started for the first time. Port configuration must happen after `Start-Service sshd`:

```powershell
Start-Service sshd -ErrorAction SilentlyContinue
# sshd_config now exists:
(Get-Content $sshdConf) -replace '#?Port 22','Port 41' | Set-Content $sshdConf
Restart-Service sshd
```

---

## Chrome desktop shortcut recreation

Chrome recreates its desktop shortcut after post-install background tasks run. A single `Remove-Item` at install time is not enough. The approach used in `InstallApps.ps1`: wait ~30 seconds after all installs complete, then remove any remaining `.lnk` files from the user and public desktops at the very end of the script.

---

## VisiblePlaces binary (Start menu folder shortcuts)

The binary value written to `HKCU\Software\Microsoft\Windows\CurrentVersion\Start\VisiblePlaces` encodes internal Windows Shell GUIDs. It was extracted from the live 25H2 EL TORO system. The GUIDs are stable across minor updates but the binary format could change in a major Windows revision.

See the [Start menu pins](#start-menu-pins-windows-11-25h2) section for the correct timing of VisiblePlaces writes relative to `start2.bin` regeneration and RDP sessions.

---

## Windows Terminal icon

The App Execution Alias path (`%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe`) does not work reliably as an icon source for `.lnk` shortcuts - it resolves to a stub that may return no icon depending on context. Extract the icon from the package Assets directory at install time and save it to a stable path (e.g. `C:\Windows\Setup\Scripts\TerminalIcon.ico`), then point the shortcut at that path.

---

## InstallApps scheduled task - StartWhenAvailable flag

The `InstallApps` scheduled task is registered with a one-time trigger set 10 minutes in the future. If the machine reboots within that window (e.g. Windows Update forcing a restart), the trigger fires while the machine is offline and the task silently expires without running.

Set `StartWhenAvailable = $true` in `New-ScheduledTaskSettingsSet`:

```powershell
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 2) -StartWhenAvailable
```

Without this flag the task will not run after a reboot, and no error is logged.

---

## Folder Details view

Setting `Mode=4` and `LogicalViewMode=1` in `HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell` forces Details view for all folders including music/video folders that would otherwise auto-switch to their own column layouts. These DWORD values are not officially documented by Microsoft.

---

## Telemetry level

`AllowTelemetry=0` exists in the registry but Windows 11 Home/Pro silently resets it. Level 1 (Basic) is the lowest achievable on these editions. This behaviour is by design, not a scripting error.

---

## Audio enhancement registry path

Audio enhancements are disabled via `FxProperties` entries per audio device, written at first logon when devices are registered. Devices added or re-registered after first logon will not be covered. Re-run the relevant entries or disable via Sound control panel (Properties → Enhancements → Disable all enhancements).
