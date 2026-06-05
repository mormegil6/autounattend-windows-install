# Hard-won technical findings

Lessons learned building Windows 11 autounattend configurations. Relevant to anyone working with the Schneegans pe.cmd framework or Windows 11 unattended setup in general.

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
- Deleting `start2.bin` + restarting `StartMenuExperienceHost` regenerates from ConfigureStartPins, but also resets `VisiblePlaces` - re-apply VisiblePlaces **after** the Explorer restart, not before
- `ConfigureTaskbarPins` must be set in HKLM - embed the XML as Base64 to avoid XML-escaping-inside-XML issues

---

## Calculator icon

- `CalculatorApp.exe` exists in the package but contains no embedded icons
- Icon lives in `Assets\CalculatorAppList.scale-200.png` (accessible elevated)
- Convert PNG→ICO at install time via `System.Drawing.Bitmap` → `Icon.FromHandle(GetHicon())` with explicit `[string]` cast to resolve ambiguous overload:

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

## OpenSSH Server port

`sshd_config` only exists after the service first starts. Setting the port must happen after `Start-Service sshd`:

```powershell
Start-Service sshd -ErrorAction SilentlyContinue
# Now sshd_config exists:
(Get-Content $sshdConf) -replace '#?Port 22','Port 41' | Set-Content $sshdConf
Restart-Service sshd
```

---

## Chrome desktop shortcut recreation

Chrome recreates its desktop shortcut after post-install background tasks run. A single `Remove-Item` at install time is not enough. Workaround: register a delayed scheduled task that runs ~2 minutes after install and removes any remaining `.lnk` files.

---

## VisiblePlaces binary (Start menu folder shortcuts)

The binary value written to `HKCU\Software\Microsoft\Windows\CurrentVersion\Start\VisiblePlaces` encodes internal Windows Shell GUIDs. It was extracted from a Windows 11 23H2 reference machine. The GUIDs are stable across minor updates but the binary format could theoretically change in a major Windows revision.

Re-apply VisiblePlaces **after** any Explorer restart - Explorer restart resets this value.

---

## Folder Details view

Setting `Mode=4` and `LogicalViewMode=1` in `HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell` forces Details view for all folders including music/video folders that would otherwise auto-switch to their own column layouts. These DWORD values are not officially documented by Microsoft.

---

## Telemetry level

`AllowTelemetry=0` exists in the registry but Windows 11 Home/Pro silently resets it. Level 1 (Basic) is the lowest achievable on these editions. This behaviour is by design, not a scripting error.

---

## Audio enhancement registry path

Audio enhancements are disabled via `FxProperties` entries per audio device, written at first logon when devices are registered. Devices added or re-registered after first logon will not be covered. Re-run the relevant entries or disable via Sound control panel (Properties → Enhancements → Disable all enhancements).
