<#
.SYNOPSIS
    Sets the guest resolution for a running VirtualBox VM.

.DESCRIPTION
    Performs the same operations as the Bash script above:
        • Enables global unlimited resolution
        • Sets per‑VM custom video model
        • Sends a video‑mode hint

.PARAMETER VmName
    Name of the VM.

.PARAMETER Width
    Desired horizontal resolution (default 1920).

.PARAMETER Height
    Desired vertical resolution (default 1080).

.PARAMETER RefreshRate
    Refresh rate in Hz (default 60).

.EXAMPLE
    .\Set-GuestResolution.ps1 -VmName "My VM" -Width 3440 -Height 1440 -RefreshRate 60
#>

param(
    [Parameter(Mandatory = $true)][string]$VmName,
    [int]$Width  = 1920,
    [int]$Height = 1080,
    [int]$RefreshRate = 60
)

function Write-ErrorMsg { param($Msg) Write-Host "`e[31mERROR:`e[0m $Msg" -ForegroundColor Red }
function Write-WarnMsg  { param($Msg) Write-Host "`e[33mWARN:`e[0m  $Msg" -ForegroundColor Yellow }
function Write-InfoMsg  { param($Msg) Write-Host "`e[32mINFO:`e[0m  $Msg" -ForegroundColor Green }

# Verify VBoxManage is available
$vmx = &VBoxManage --version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-ErrorMsg "VBoxManage not found – is VirtualBox installed?"
    exit 2
}

# Check VM exists
$vmInfo = VBoxManage showvminfo "$VmName" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-ErrorMsg "VM '$VmName' does not exist."
    exit 3
}

# Check VM is running
$state = VBoxManage showvminfo "$VmName" --machinereadable | 
         Select-String '^VMState=' | 
         ForEach-Object { $_.Line.Split('=')[1].Trim('"') }

if ($state -ne 'running') {
    Write-ErrorMsg "VM '$VmName' is not running (state: $state)."
    exit 4
}

# Optional: warn if Guest Additions missing
$gaVersion = VBoxManage guestproperty get "$VmName" "/VirtualBox/GuestAdd/Version" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-WarnMsg "Guest Additions not detected – resolution change may fail."
}

# Apply global unlimited resolution
Write-InfoMsg "Enabling unrestricted guest resolution (global)."
VBoxManage setextradata global "GUI/MaxGuestResolution" any

# Apply per‑VM custom video model
Write-InfoMsg "Setting custom video model for '$VmName'."
VBoxManage setextradata "$VmName" "CustomVideoModel" "$Width`x$Height`x$RefreshRate"

# Send mode hint
Write-InfoMsg "Requesting resolution $Width×$Height @ $RefreshRate Hz."
VBoxManage controlvm "$VmName" setvideomodehint $Width $Height $RefreshRate

Write-InfoMsg "Done – resolution should be applied shortly."
exit 0