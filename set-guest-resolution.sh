#!/usr/bin/env bash
# ------------------------------------------------------------
# set-guest-resolution.sh
#
#  Usage:
#    ./set-guest-resolution.sh <VM name> [<width> <height> <refresh>]
#
#  If width/height/refresh are omitted, 1920x1080@60Hz is used.
#
#  Requires:
#    • VirtualBox installed & VBoxManage in $PATH
#    • Guest Additions already mounted in the guest
# ------------------------------------------------------------

# ---------- Helper functions ----------
error() { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; }
warn()  { printf '\033[1;33mWARN:\033[0m  %s\n' "$*" >&2; }
info()  { printf '\033[1;32mINFO:\033[0m  %s\n' "$*"; }

# ---------- Sanity checks ----------
if ! command -v VBoxManage &>/dev/null; then
    error "VBoxManage not found – is VirtualBox installed?"
    exit 2
fi

# ---------- Parse arguments ----------
VM_NAME="$1"
if [[ -z "$VM_NAME" ]]; then
    error "No VM name supplied."
    cat <<'EOF'
Usage:  set-guest-resolution.sh <VM name> [<width> <height> <refresh>]

Example:
   set-guest-resolution.sh "My VM" 3440 1440 60
EOF
    exit 3
fi

# Default resolution: 1920x1080 @ 60Hz
WIDTH=${2:-1920}
HEIGHT=${3:-1080}
REFRESH=${4:-60}

# ---------- Check VM existence ----------
if ! VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    error "VM '$VM_NAME' does not exist."
    exit 4
fi

# ---------- Check that VM is running ----------
VM_STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | \
           grep '^VMState=' | cut -d= -f2 | tr -d '"')
if [[ "$VM_STATE" != "running" ]]; then
    error "VM '$VM_NAME' is not running (state: $VM_STATE)."
    exit 5
fi

# ---------- Verify Guest Additions are present ----------
# The most reliable way is to check for the presence of the
# VBoxService process in the guest.  We ask the host to run
# a guestproperty query that is only set by the service.
if ! VBoxManage guestproperty get "$VM_NAME" "/VirtualBox/GuestAdd/Version" \
     &>/dev/null; then
    warn "Guest Additions not detected – resolution change may fail."
fi

# ---------- Apply global setting ----------
info "Enabling unrestricted guest resolution (global)."
VBoxManage setextradata global "GUI/MaxGuestResolution" any

# ---------- Apply per‑VM setting ----------
info "Setting custom video model for '$VM_NAME'."
VBoxManage setextradata "$VM_NAME" "CustomVideoModel" "${WIDTH}x${HEIGHT}x${REFRESH}"

# ---------- Send mode hint ----------
info "Requesting resolution $WIDTH×$HEIGHT @ $REFRESH Hz."
VBoxManage controlvm "$VM_NAME" setvideomodehint "$WIDTH" "$HEIGHT" "$REFRESH"

info "Done – resolution should be applied shortly."

exit 0