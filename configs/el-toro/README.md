# EL TORO - Machine Config

Windows 11 25H2 unattended install configuration for the EL TORO workstation.

---

## Hardware

| Component | Spec |
|-----------|------|
| CPU | AMD Ryzen 9 7950X (16C/32T) |
| GPU | NVIDIA GeForce RTX 4090 |
| Motherboard | MSI B650-P WiFi |
| RAM | 96 GB DDR5 |
| Boot drive | NVMe SSD (Disk 1, ~4 TB) |
| Render NVMe | Disk 2 → remapped to D: |
| Data SATA | Disk 0 → remapped to E: |

Boot from USB (F11 → UEFI Patriot).

---

## Pre-install checklist

- [ ] Confirm target disk is Disk 1 in diskpart (`Shift+F10` from installer → `diskpart` → `list disk`)
- [ ] Change password in `autounattend.xml` - search `CHANGE_ME_PASSWORD` and replace
- [ ] Update `Greenshot.ini` `OutputFilePath` if username was changed
- [ ] Verify USB is bootable ExFAT (WinDiskWriter)
- [ ] Internet available on the machine during setup

### Disk assertion values
The `assert.vbs` checks Disk 1 for:
- Interface type: `IDE` or `SCSI` (NVMe shows as SCSI in WMI)
- Media type: `Fixed hard disk media`
- Size: 100–4000 GiB

If your target drive is different, update Orders 9–15 in the `windowsPE` pass.

---

## What works (automated)

Everything in this config runs without user interaction:

**During Windows Setup (Specialize phase - runs as SYSTEM)**
- Bloatware removal (Xbox, Teams, Cortana, Bing News, etc.)
- Dark theme, left-aligned taskbar, search icon only
- Edge hardening (40+ policy keys, Copilot disabled)
- Chrome desktop shortcut suppression
- RDP enabled, NLA required
- Fast startup disabled, long paths enabled, Developer Mode on
- Wake-on-LAN registry (`*WakeOnMagicPacket`)
- Drive letter remapping (D: and E:)
- Taskbar layout: Explorer + Edge + Terminal, Store removed
- `LayoutModification.json` written to Default user profile → Calculator, Notepad, Terminal pinned at first logon
- Start menu pins (16 pins) via `ConfigureStartPins`

**At First Logon (UserOnce.ps1 - runs via RunOnce)**
- Taskbar: combine when full, active monitor only
- Details view in Explorer, language bar hidden
- Keyboard layout cleanup (removes US-International)
- `Greenshot.ini` seeded (Screenshots folder, hotkeys)
- Start menu folder shortcuts (VisiblePlaces binary)
- WSL2 set as default version

**6 Minutes After First Logon (InstallApps.ps1 - elevated scheduled task)**
- Apps installed via winget: Greenshot, WinDirStat, PowerToys, Git, Notepad++, 7-Zip, VS Code, VLC, Chrome, HWiNFO64, PowerShell 7
- Python 3.13 - direct download, system-wide
- Python 2.7 - direct download, `C:\Python27`, `python2` alias
- OpenSSH Server installed and configured on port 41
- Start menu pins re-applied (all 16 with icons)
- Windows Terminal configured: PS7 default, AtlasEngine, acrylic tabs, 80×20
- Desktop shortcut cleanup (Chrome delayed task included)
- `winget upgrade --all` at the end

---

## What doesn't work (manual steps required)

| Setting | Where | Why not automated |
|---------|-------|-------------------|
| Start menu "More pins" layout | Settings → Personalization → Start | Registry key not identifiable across Windows builds |
| 7-Zip file associations | 7-Zip → Tools → Options → System tab | Windows 11 protects associations with a cryptographic hash tied to username/SID |
| WSL2 distro | `wsl --install Ubuntu` (or your choice) | Distro is intentionally not pre-selected |

---

## Known issues

- **Start menu pins** - if a pin appears broken, check `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\` for the actual `.lnk` name. PowerToys has changed shortcut names between releases.
- **VisiblePlaces** - re-apply after any Explorer restart; Explorer resets this value on restart.
- **Audio enhancements** - disabled at first logon for devices present at that time. Devices added later need manual treatment (Sound control panel → Properties → Enhancements).
- **Verified on 25H2** - settings like `TaskbarGlomLevel` and the `VisiblePlaces` binary format were verified on 25H2; earlier or future builds are untested.
