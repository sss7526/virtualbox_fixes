# VirtualBox Clipboard Fix

Add the following to your .bashrc or equivalent on your VM to fix clipboard issues between your host and vm.
```bash
pkill -f VBoxClient; VBoxClient --clipboard
```


# VirtualBox Guest Resolution Fixer

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Bash (Linux / macOS)](#bash-linux--macos)
  - [PowerShell (Windows)](#powershell-windows)
- [Command‑Line Options](#command-line-options)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## Overview

`set-guest-resolution.sh` and `Set-GuestResolution.ps1` are lightweight host‑side utilities that set a VirtualBox VM’s screen resolution and refresh rate.  
They:

1. Enable unrestricted guest resolution globally.
2. Set a per‑VM custom video model.
3. Send a video‑mode hint to the running VM.

The scripts are designed for quick, repeatable use on any VM that already has VirtualBox Guest Additions installed.

---

## Prerequisites

| Item | Requirement |
|------|-------------|
| VirtualBox | Version 6.0 or newer. `VBoxManage` must be in the system `PATH`. |
| Guest Additions | Must be installed and running in the guest OS. |
| Host OS | Linux / macOS (Bash script) **or** Windows (PowerShell script). |
| Shell | Bash (or a Bash‑compatible shell) for the Bash script; PowerShell 5.1+ for the PowerShell script. |

---

## Installation

```bash
# Clone the repository
git clone https://github.com/sss7526/virtualbox_fixes.git
cd virtualbox_fixes

# (Optional) Make the Bash script executable
chmod +x set-guest-resolution.sh
```

---

## Usage

### Bash (Linux / macOS)

```bash
./set-guest-resolution.sh "<VM name>" [<width> <height> <refresh>]
```

### PowerShell (Windows)

```powershell
.\Set-GuestResolution.ps1 -VmName "<VM name>" -Width <width> -Height <height> -RefreshRate <refresh>
```

> **Note:**  
> - The VM must be **running** when the script is executed.  
> - The script only operates on the host; no changes are made inside the guest.

---

## Command‑Line Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **VM name** | `string` | *required* | The exact name of the VirtualBox VM. |
| **width** | `int` | 1920 | Desired horizontal resolution. |
| **height** | `int` | 1080 | Desired vertical resolution. |
| **refresh** | `int` | 60 | Desired refresh rate (Hz). |

If `width`, `height`, or `refresh` are omitted, the script defaults to `1920x1080@60 Hz`.

---

## Examples

```bash
# Bash
./set-guest-resolution.sh "My VM" 3440 1440 60

# PowerShell
.\Set-GuestResolution.ps1 -VmName "My VM" -Width 3440 -Height 1440 -RefreshRate 60
```

Both commands will:

1. Set the global unrestricted resolution flag.
2. Assign `3440x1440x60` as the custom video model for the VM.
3. Tell the running VM to switch to that resolution.

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| **VM is not running** | The script is executed while the VM is paused or powered off. | Start the VM before running the script. |
| **Guest Additions not detected** | Additions are missing or the `VBoxService` process is not running inside the guest. | Install Guest Additions and reboot the guest. |
| **Resolution change fails** | The guest OS may not support the requested mode. | Verify the resolution is supported by the guest display driver. |
| **`VBoxManage` not found** | VirtualBox is not installed or not in the `PATH`. | Install VirtualBox or add its installation directory to the system `PATH`. |

---

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---