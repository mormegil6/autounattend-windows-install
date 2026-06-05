[![Windows 11](https://img.shields.io/badge/Windows%2011-25H2-0078D4?logo=windows11&logoColor=white)]()
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)]()
[![winget](https://img.shields.io/badge/winget-apps-blue)]()
[![Based on Schneegans](https://img.shields.io/badge/based%20on-Schneegans%20generator-lightgrey)](https://schneegans.de/windows/unattend-generator/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

# AutoUnattend Windows Install

Fully automated Windows 11 unattended installer based on the [Schneegans pe.cmd framework](https://schneegans.de/windows/unattend-generator/). Drop `autounattend.xml` into the root of a bootable USB drive - Windows Setup does the rest without user interaction.

This repository is structured to host multiple machine configs alongside a planned interactive generator tool.

## Repository structure

```
autounattend/
├── README.md                    # This file - project overview + generator spec
├── docs/
│   └── discoveries.md           # Hard-won technical findings
├── configs/
│   └── el-toro/
│       ├── README.md            # EL_TORO hardware, what works, known issues
│       ├── autounattend.xml     # Main answer file - copy to USB root before install
│       ├── Greenshot.ini        # Pre-configured Greenshot settings (seeded before first logon)
│       └── scripts/             # Extracted from autounattend.xml for inspection/editing
│           ├── Specialize.ps1           # System config: bloatware, theme, registry tweaks, WoL, drive letters
│           ├── InstallApps.ps1          # App installs via winget + Python; runs ~10 min after first logon
│           ├── UserOnce.ps1             # Per-user settings: theme, taskbar, folder view, Greenshot, Terminal
│           ├── DefaultUser.ps1          # Applied to Default user hive before any profile is created
│           ├── FirstLogon.ps1           # Registers InstallApps scheduled task; runs at first logon as SYSTEM
│           ├── SetStartPins.ps1         # Applies ConfigureStartPins JSON; called from InstallApps
│           ├── RemoveCapabilities.ps1   # Windows capabilities to remove (Steps Recorder, IE, OneSync)
│           ├── RemoveFeatures.ps1       # Windows optional features to remove
│           ├── RemovePackages.ps1       # Provisioned AppX packages to remove (bloatware)
│           ├── SetColorTheme.ps1        # Applies Captured Motion desktop theme (themeA)
│           └── ShowAllTrayIcons.xml     # NotificationSettings XML - forces all tray icons visible
└── generator/
    └── .gitkeep                 # Placeholder for future web tool
```

## Adding a new machine config

1. Duplicate `configs/el-toro/` as `configs/<machine-name>/`
2. Edit `autounattend.xml` - update disk number, computer name, locale, password
3. Update scripts as needed for your hardware
4. Document in `configs/<machine-name>/README.md`

---

## What it does

> Hardware notes and per-config specifics: [configs/el-toro/README.md](configs/el-toro/README.md)

### Disk layout
- GPT partition scheme (UEFI only - no legacy BIOS support)
- 300 MB EFI partition, 16 MB MSR, Windows partition, 1 GB recovery partition
- Targets **Disk 1** - verify this matches your intended drive before use. Boot from the USB, press Shift+F10 to open a command prompt, run `diskpart` then `list disk` to confirm disk numbering before proceeding. Change `SELECT DISK=1` and `<DiskID>1</DiskID>` in the XML if your target drive has a different number. **The script runs `CLEAN` on the selected disk - wrong disk number means data loss.**

### Language and locale
- UI language: **English (US)**
- Regional settings (date format, decimal separator, units): **Polish (pl-PL)**
- Keyboard: **Polish (programmers)** - single layout, no switcher
- Timezone: **Central European Standard Time** (Warsaw, UTC+1/+2)

### Bloatware removed
Provisioned packages removed at install time (not reinstallable via Store without effort):
Bing Search, Clipchamp, Cortana, Family Safety, Feedback Hub, Internet Explorer, Mixed Reality Portal, News, Office Hub, OneDrive, OneNote, OneSync, Outlook, People, Skype, Solitaire, Steps Recorder, Teams (classic and new), Get Started, Wallet, all Xbox apps, Your Phone.

Windows capabilities removed: Internet Explorer, OneSync, Steps Recorder.

### Privacy and telemetry
- Telemetry set to level 1 (Basic) - lowest available on Home/Pro; level 0 is Enterprise-only and silently ignored on other editions
- Advertising ID disabled
- Bing search results removed from Start menu and Search (four registry keys covering all known suppression paths)
- Copilot disabled system-wide and removed from taskbar
- Windows Consumer Features / silent app reinstall prevention (three CloudContent policy keys)
- Suggested Actions (clipboard auto-suggestions) disabled
- GameDVR disabled
- Content Delivery Manager suggestions disabled (15 keys)
- Cortana consent set to off

### Desktop and taskbar
- Dark theme (system and apps)
- Accent color: `#0078D4` (Windows blue) on title bars, window borders, and Start
- Transparency enabled
- Taskbar aligned **left** (not centered)
- Search shows as **icon** (not search bar)
- Task View (virtual desktops) button shown
- Widgets disabled
- Copilot button hidden
- Language bar hidden (single keyboard layout, no switcher needed)
- All system tray icons always visible - no overflow/hidden icons
- Taskbar buttons: **combine only when taskbar is full** (not always combined)
- Multi-monitor: apps shown only on the taskbar of the monitor they're on
- "End Task" option enabled in taskbar right-click

### Explorer and file management
- File extensions shown
- Hidden files shown
- Explorer opens to **This PC** (not Quick Access)
- All folders default to **Details view** with generic column layout (Name, Date Modified, Type, Size) - prevents music/audio folders auto-switching to the Music layout with different columns
- Desktop icons: **This PC**, **User's Files**, **Recycle Bin** - no Network, no Control Panel shortcut

### Start menu
- Empty pinned list replaced with a custom 16-pin layout (2 rows of 8):

| | | | | | | | |
|---|---|---|---|---|---|---|---|
| This PC | Control Panel | Calculator | Notepad | Notepad++ | PowerToys | Terminal | 7-Zip |
| NVIDIA Control Panel | Realtek Audio Console | HWiNFO64 | WinDirStat | VS Code | VLC | Chrome | Edge |

- All folder shortcuts enabled (Settings, File Explorer, Documents, Downloads, Music, Pictures, Videos, Network, Personal folder)
- **Start layout toggle** ("More pins" vs "More recommendations"): set manually after install via Settings → Personalization → Start - the registry key for this setting was not reliably identifiable across builds

### System configuration
- Computer name: **EL_TORO**
- Local account: **User** / `CHANGE_ME_PASSWORD` *(set before use - see [Customisation](#customisation))*
- Password never expires
- **Remote Desktop enabled** with NLA (Network Level Authentication) - compatible with the Windows App on macOS
- RDP firewall rule opened
- Developer Mode enabled
- Long file paths enabled (>260 chars)
- PowerShell execution policy: **RemoteSigned** (local scripts run freely; downloaded scripts require signing)
- NumLock on at boot
- **Hibernation disabled** entirely
- **Fast startup disabled** (prevents USB device issues and WSL2 shutdown problems)
- Power: never sleep, never turn off display (suitable for always-on tower; adjust if needed)
- Windows Update active hours: 8:00–23:00 (no forced restarts during work hours)
- Edge: first-run experience hidden, background mode disabled, startup boost disabled
- **Wake-on-LAN** enabled via registry (`*WakeOnMagicPacket`)
- Drive letters: Disk 2 -> D: (render NVMe), Disk 0 -> E: (data SATA)

### Audio
- Audio enhancements disabled on all playback devices (applied at first logon when devices are registered)
- Exclusive mode left at default (available for DAW use)

### Development
- **WSL2** Windows components pre-installed (no distro - install your preferred distro with `wsl --install Ubuntu` or similar)
- WSL2 set as default version at first logon
- **Git** installed via winget
- **OpenSSH Server** installed post-logon (in `InstallApps.ps1`), configured on port 41, firewall rule opened. Port 41 is hardcoded - change the `sshd_config` patch in `InstallApps.ps1` and the firewall rule name if you want a different port.

### Pre-installed applications (via winget)
All installed silently during setup, no interaction required:

| App | winget ID |
|---|---|
| Greenshot | `Greenshot.Greenshot` |
| WinDirStat | `WinDirStat.WinDirStat` |
| Microsoft PowerToys | `Microsoft.PowerToys` |
| Git | `Git.Git` |
| Notepad++ | `Notepad++.Notepad++` |
| 7-Zip | `7zip.7zip` |
| Visual Studio Code | `Microsoft.VisualStudioCode` (system-wide install) |
| VLC | `VideoLAN.VLC` |
| Google Chrome | `Google.Chrome` |
| PowerShell 7 | `Microsoft.PowerShell` |
| HWiNFO64 | `REALiX.HWiNFO` |

Python installs (direct download - winget `--scope machine` unreliable for Python):
- **Python 3.13** - `InstallAllUsers=1 PrependPath=1`
- **Python 2.7** - installed to `C:\Python27`, `python2` alias added

`InstallApps.ps1` runs as an elevated scheduled task 10 minutes after first logon (`StartWhenAvailable` is set, so it fires even if the machine reboots during the trigger window). A `winget upgrade --all` runs at the end.

**Greenshot** gets a pre-configured `Greenshot.ini` seeded into the default user profile before first logon, so it launches already configured with your preferred hotkeys, output format, and save location.

---

## Prerequisites

- **UEFI-capable machine** - GPT layout only; no legacy BIOS/CSM support
- **Internet connection during setup** - winget installs require network during the specialize pass. WSL2 (`Microsoft-Windows-Subsystem-Linux` and `VirtualMachinePlatform`) are offline Windows components from the ISO and do not require internet.
- **Windows 11 25H2 ISO** - English International, 64-bit
    - SHA256: `66B7B4B71763ED6F9B2CE29326ED9284544DA6F5283D00329921540C01AAAEEA`
- **Bootable USB** created with [WinDiskWriter](https://github.com/TechUnRestricted/WinDiskWriter) in ExFAT mode - required, modern Win11 ISOs have `install.wim` > 4 GB (FAT32 can't hold it)

---

## How to use

1. Download Windows 11 25H2 ISO from [microsoft.com/software-download/windows11](https://www.microsoft.com/software-download/windows11) - **English International**, **64-bit**
2. Write ISO to USB with WinDiskWriter (ExFAT, UEFI boot, no Legacy BIOS sector)
3. **Customise** - at minimum set your password (search `CHANGE_ME_PASSWORD` in the XML)
4. Copy `configs/el-toro/autounattend.xml` to the **root** of the USB drive
5. Boot from USB, press `Shift+F10` → `diskpart` → `list disk` to confirm disk numbering before proceeding
6. Reboot from USB - setup completes unattended
7. Wait ~10 minutes after first logon for `InstallApps.ps1` to complete
8. Check `C:\Windows\Setup\Scripts\InstallApps.log` for status

---

## Customisation

These values are hardcoded and **must be changed** before use on a different machine:

| Value | Location | Default |
|-------|----------|---------|
| Password | `autounattend.xml` | `CHANGE_ME_PASSWORD` |
| Username | `autounattend.xml` | `User` |
| Computer name | `autounattend.xml` | `EL_TORO` |
| Target disk | pe.cmd / assert.vbs | Disk 1 (100–4000 GiB NVMe) |
| Timezone | `autounattend.xml` | `Central European Standard Time` |
| UI language | `autounattend.xml` | `en-US` |
| Locale | `autounattend.xml` | `pl-PL` |
| Keyboard | `autounattend.xml` | Polish Programmers |

### Password
```xml
<Password>
    <Value>CHANGE_ME_PASSWORD</Value>
    <PlainText>true</PlainText>
</Password>
```
⚠️ The password is stored in plaintext. Use a throwaway password for setup and change it afterwards, or use `<PlainText>false</PlainText>` with a Base64-encoded value.

### Computer name
```xml
<Path>Rename-Computer -NewName 'EL_TORO' ...</Path>
```
Max 15 characters, no spaces, hyphens and underscores allowed.

### Username
`User` also appears in file paths - `C:\Users\User\Pictures\Screenshots` (Greenshot save location in `Greenshot.ini` and `UserOnce.ps1`). Search and replace all occurrences if you change it.

### Locale and timezone
Full timezone name list: [Microsoft docs](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones)

### Greenshot save path
```ini
OutputFilePath=C:\Users\User\Pictures\Screenshots
```
Update `Greenshot.ini` to match your username.

---

## Post-install manual steps

A small number of settings could not be fully automated:

| Setting | Where | Why not automated |
|---|---|---|
| Start layout toggle ("More pins" vs "More recommendations") | Settings → Personalization → Start | Registry key not reliably identifiable across Windows builds |
| Taskbar: unpin Store, pin Terminal | Right-click taskbar | Taskbar pin registry policy (`ConfigureTaskbarPins`) is only honoured on MDM-enrolled machines in 25H2 |
| 7-Zip file associations | 7-Zip → Tools → Options → System tab | Windows 11 protects file association changes with a cryptographic hash tied to username/SID |
| WSL2 distro | `wsl --install Ubuntu` (or your choice) | Distro is intentionally not pre-selected |

---

## Known limitations

- **Start menu pins** may silently fail for apps whose `.lnk` path doesn't match expectations. PowerToys has changed shortcut names between releases - check `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\`.
- **VisiblePlaces binary** (Start menu folder shortcuts) was extracted from the live 25H2 EL_TORO system. Shell GUIDs are stable across minor updates but the format could change in a major revision.
- **Audio enhancements** are disabled at first logon. Devices added later are not covered - re-run the relevant registry entries or use the Sound control panel.
- **Folder Details view** (`Mode=4`, `LogicalViewMode=1`) works on tested builds but the DWORD values are undocumented.
- **Telemetry level 1** is the minimum on Home/Pro. Level 0 silently resets on these editions - not a bug.

See [docs/discoveries.md](docs/discoveries.md) for detailed technical findings and pe.cmd internals.

---

## Generator Tool Specification

> Build target: static site at `bmroz.eu/tools/autounattend`. No backend - pure client-side JavaScript. Stack: vanilla JS or React, Tailwind CSS.

### Problem being solved

The [Schneegans generator](https://schneegans.de/windows/unattend-generator/) produces valid XML but embeds silent assumptions (disk assertions, Order dependencies, diskpart sequencing) that are easy to break and impossible to debug without deep knowledge of pe.cmd internals. This tool should make those assumptions explicit and configurable.

### Core features

#### 1. Disk configuration
- Disk number input (0–9) with size/type hint shown
- Auto-generates correct `assert.vbs` checks for that disk
- Auto-generates GPT diskpart layout (EFI + Windows + Recovery)

#### 2. User account
- Username, password, computer name
- Autologon on first boot (yes/no)

#### 3. Language & locale
- UI language (dropdown), regional format, keyboard layout, timezone

#### 4. App installation
- Checkbox list of winget packages (pre-populated with common tools)
- Custom winget IDs field
- Python 3 (yes/no) - uses direct python.org download
- Python 2.7 (yes/no)

#### 5. Start menu pins
- Drag-and-drop reorderable pin list
- Supports `desktopAppLink` (installed apps) and `packagedAppId` (UWP apps)
- Preview of approximate Start menu layout

#### 6. Taskbar pins
- Checklist: Explorer, Edge, Terminal, Chrome, others
- **Note:** `ConfigureTaskbarPins` via registry is not supported on non-MDM machines in Windows 11 25H2. Taskbar pin configuration on unmanaged machines requires writing the `Taskband\Favorites` binary directly to the user hive, or a Provisioning Package.

#### 7. Tweaks (checkboxes)
- Dark/Light theme, taskbar alignment (left/center), search box style
- Combine taskbar buttons, fast startup, RDP, Developer Mode
- WSL2, long paths, bloatware removal checklist, Edge hardening, Wake-on-LAN

#### 8. Drive letters
- Optional: remap specific disks to specific letters
- Generates `Set-Partition` commands in Specialize.ps1

### Output
- Single downloadable `autounattend.xml`
- Optional ZIP with `autounattend.xml` + extracted `.ps1` scripts for inspection
- Validation panel: disk assertion preview, pin list, app list

### Architecture notes

Critical XML constraints:

```
windowsPE pass:
    - RunSynchronous Orders 1–33 build pe.cmd incrementally
    - Orders 8–16 build assert.vbs inside a pe.cmd redirect block
    - Order 15 MUST output "End If" (closes Order 14's If block)
    - All >> in Order Path values must be &gt;&gt;
    - No <?xml?> declarations inside File element content

specialize pass:
    - File elements contain PowerShell scripts
    - < and > inside File content must be &lt; &gt;
    - Embed XML-within-PS1 as Base64 to avoid double-escaping

oobeSystem pass:
    - LocalAccount Password/Value must contain the plaintext password
        or Base64 of password+"Password" if PlainText=false
```

See [docs/discoveries.md](docs/discoveries.md) for full pe.cmd internals and other hard-won findings.

**Winget installs** require internet during the specialize pass. `InstallApps.ps1` runs `winget source update` at startup to handle stale source caches on older ISOs.

---

## Acknowledgements

Base answer file generated with [Schneegans Unattend Generator](https://schneegans.de/windows/unattend-generator/) - a well-maintained, thorough tool that handles the XML boilerplate and Schneegans extension mechanism correctly.

---

## License

MIT - see [LICENSE](./LICENSE).

---

## Contact

Bartłomiej Mróz · bartlomiej.mroz@pg.edu.pl · Department of Multimedia Systems, Gdańsk University of Technology
