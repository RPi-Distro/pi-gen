#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration Variables (from user's device_config) ---
GADGET_NAME="Raspberry Pi USB Gadget"
GADGET_VID="0x1201"
GADGET_PID="0x7211"
GADGET_MANUFACTURER=""

# Assume there is only one UDC driver available.
UDC_DEVICE=`ls /sys/class/udc | head -1`

# USB Device Descriptor fields
USB_VER="0x0200"    # USB 2.0
DEV_CLASS="0x02"    # Communications Device Class

DEVICE_BCD="0x3000" # Device Release Number

GADGET_PRODUCT_NAME=${GADGET_NAME}
# If empty, script will construct one from /proc/cpuinfo.
GADGET_SERIAL_NUMBER=

# Configuration Descriptor fields
BM_ATTRIBUTES="0x80" # Bus powered, no remote wakeup (0xC0 for self-powered)
MAX_POWER_MA=500     # Max power in mA
MAX_POWER_CONFIGFS=$((MAX_POWER_MA / 2)) # Convert to 2mA units for configfs

# Configuration names
CFG1_NAME="CDC"  # For NCM
CFG2_NAME="RNDIS" # For RNDIS

# MAC addresses (leave empty to let the kernel auto-generate)
DEV_MAC_CDC=""   # e.g., "02:00:00:00:00:01"
HOST_MAC_CDC=""  # e.g., "12:00:00:00:00:01"
DEV_MAC_RNDIS="" # e.g., "22:00:00:00:00:01"
HOST_MAC_RNDIS="" # e.g., "32:00:00:00:00:01"

# Microsoft OS Descriptors for RNDIS
MS_VENDOR_CODE="0xcd" # Typically 1 byte, often the an arbitrary value or USB-IF registered vendor ID's first byte
MS_QW_SIGN="MSFT100"
MS_COMPAT_ID_RNDIS="RNDIS"
MS_SUBCOMPAT_ID_RNDIS="5162001" # For RNDIS 6.0 driver on Windows

# --- Script Variables ---
CONFIGFS_BASE="/sys/kernel/config"
GADGET_BASE_DIR="${CONFIGFS_BASE}/usb_gadget"
# Create a potentially unique gadget name to avoid conflicts if script is run with minor changes
# or if other gadgets exist.
GADGET_INSTANCE_NAME="${GADGET_NAME_PREFIX}_dev"
GADGET_PATH="${GADGET_BASE_DIR}/${GADGET_INSTANCE_NAME}"

# --- Functions ---

cleanup_gadget() {
    echo "Cleaning up USB gadget: ${GADGET_INSTANCE_NAME}..."

    # Disable the gadget by unbinding from UDC
    if [ -d "${GADGET_PATH}" ] && [ -n "$(ls /sys/class/udc)" ] && [ -f "${GADGET_PATH}/UDC" ] && [ -n "$(cat "${GADGET_PATH}/UDC")" ]; then
        echo "Unbinding from UDC..."
        echo "" > "${GADGET_PATH}/UDC" || echo "Failed to unbind UDC, was it bound?"
    fi

    if [ -d "${GADGET_PATH}" ]; then
        echo "Removing configuration links and functions..."
        # Configuration 1 (NCM)
        if [ -L "${GADGET_PATH}/configs/c.1/ncm.0" ]; then
            rm "${GADGET_PATH}/configs/c.1/ncm.0"
        fi
        if [ -d "${GADGET_PATH}/configs/c.1/strings/0x409" ]; then
            rmdir "${GADGET_PATH}/configs/c.1/strings/0x409"
        fi
        if [ -d "${GADGET_PATH}/configs/c.1" ]; then
            rmdir "${GADGET_PATH}/configs/c.1"
        fi

        # Configuration 2 (RNDIS)
        if [ -L "${GADGET_PATH}/configs/c.2/rndis.0" ]; then
            rm "${GADGET_PATH}/configs/c.2/rndis.0"
        fi
        if [ -d "${GADGET_PATH}/configs/c.2/strings/0x409" ]; then
            rmdir "${GADGET_PATH}/configs/c.2/strings/0x409"
        fi
        if [ -d "${GADGET_PATH}/configs/c.2" ]; then
            rmdir "${GADGET_PATH}/configs/c.2"
        fi

        # OS Descriptors link
        if [ -L "${GADGET_PATH}/os_desc/config" ]; then
             rm "${GADGET_PATH}/os_desc/config"
        fi
         if [ -L "${GADGET_PATH}/os_desc/c.1" ]; then # Older naming
             rm "${GADGET_PATH}/os_desc/c.1"
        fi


        # Functions
        if [ -d "${GADGET_PATH}/functions/ncm.0" ]; then
            rmdir "${GADGET_PATH}/functions/ncm.0"
        fi
        if [ -d "${GADGET_PATH}/functions/rndis.0/os_desc/interface.rndis" ]; then
            rmdir "${GADGET_PATH}/functions/rndis.0/os_desc/interface.rndis"
        fi
        if [ -d "${GADGET_PATH}/functions/rndis.0/os_desc" ]; then
            rmdir "${GADGET_PATH}/functions/rndis.0/os_desc"
        fi
        if [ -d "${GADGET_PATH}/functions/rndis.0" ]; then
            rmdir "${GADGET_PATH}/functions/rndis.0"
        fi

        # Strings and OS descriptor base
        if [ -d "${GADGET_PATH}/strings/0x409" ]; then
            rmdir "${GADGET_PATH}/strings/0x409"
        fi
        if [ -d "${GADGET_PATH}/os_desc" ]; then
            # Ensure 'use' is 0 before attempting to rmdir if needed, though not strictly required for rmdir
            # echo 0 > "${GADGET_PATH}/os_desc/use" 2>/dev/null || true
            rmdir "${GADGET_PATH}/os_desc" 2>/dev/null || true # May fail if linked
        fi


        # Remove gadget directory
        echo "Removing gadget directory ${GADGET_PATH}..."
        cd "${GADGET_BASE_DIR}" # Go to parent dir before rmdir
        rmdir "${GADGET_INSTANCE_NAME}" || echo "Failed to remove gadget directory ${GADGET_PATH}."
    else
        echo "Gadget ${GADGET_INSTANCE_NAME} not found."
    fi
    echo "Cleanup finished."
}

setup_gadget() {
    echo "Setting up USB gadget: ${GADGET_INSTANCE_NAME}..."

    # 0. Ensure configfs is mounted and libcomposite is loaded
    if ! grep -q "configfs /sys/kernel/config" /proc/mounts; then
        echo "ConfigFS not mounted. Mounting now..."
        mount -t configfs none /sys/kernel/config
    fi
    if ! lsmod | grep -q "libcomposite"; then
        echo "libcomposite module not loaded. Loading now..."
        modprobe libcomposite
    fi
     if ! lsmod | grep -q "usb_f_ncm"; then
        echo "usb_f_ncm module not loaded. Loading now..."
        modprobe usb_f_ncm
    fi
    if ! lsmod | grep -q "usb_f_rndis"; then
        echo "usb_f_rndis module not loaded. Loading now..."
        modprobe usb_f_rndis
    fi

    # 1. Create gadget directory
    if [ -d "${GADGET_PATH}" ]; then
        echo "Gadget directory ${GADGET_PATH} already exists. Consider running cleanup first."
        # exit 1 # Or try to continue / clean up selectively
    else
        mkdir -p "${GADGET_PATH}"
    fi
    cd "${GADGET_PATH}"

    # 2. Set USB Device Descriptor fields
    echo "${GADGET_VID}" > idVendor
    echo "${GADGET_PID}" > idProduct
    echo "${DEVICE_BCD}" > bcdDevice
    echo "${USB_VER}" > bcdUSB
    echo "${DEV_CLASS}" > bDeviceClass
    # echo "0x00" > bDeviceSubClass # Usually 0x00 if bDeviceClass is non-zero and not EFh
    # echo "0x00" > bDeviceProtocol # Usually 0x00 if bDeviceClass is non-zero and not EFh

    # 3. Create String Descriptors (typically 0x409 for English)
    mkdir -p strings/0x409
    echo "${GADGET_MANUFACTURER}" > strings/0x409/manufacturer
    echo "${GADGET_PRODUCT_NAME}" > strings/0x409/product
    if [ -n "${GADGET_SERIAL_NUMBER}" ]; then
        echo "${GADGET_SERIAL_NUMBER}" > strings/0x409/serialnumber
    else
        # Attempt to read from /proc/cpuinfo's Serial field (common on Raspberry Pi)
        # This is a basic attempt; a more robust method might be needed for other systems.
        CPU_SERIAL=$(grep -Po '^Serial\s*:\s*\K[0-9a-fA-F]+' /proc/cpuinfo || echo "00000000")
        if [ -n "${CPU_SERIAL}" ]; then
             echo "Using CPU serial for USB serial: ${CPU_SERIAL}"
             echo "${CPU_SERIAL}" > strings/0x409/serialnumber
        else
            echo "No GADGET_SERIAL_NUMBER provided and couldn't read from /proc/cpuinfo. Kernel will assign one."
            # Let kernel assign one
        fi
    fi

    # 4. Create NCM (CDC NMC) function (ncm.0)
    echo "Creating NCM function (ncm.0)..."
    mkdir -p functions/ncm.0
    if [ -n "${DEV_MAC_CDC}" ]; then echo "${DEV_MAC_CDC}" > functions/ncm.0/dev_addr; fi
    if [ -n "${HOST_MAC_CDC}" ]; then echo "${HOST_MAC_CDC}" > functions/ncm.0/host_addr; fi
    # For NCM, specific class/subclass/protocol are handled by the function driver

    # 5. Create RNDIS function (rndis.0)
    echo "Creating RNDIS function (rndis.0)..."
    mkdir -p functions/rndis.0
    if [ -n "${DEV_MAC_RNDIS}" ]; then echo "${DEV_MAC_RNDIS}" > functions/rndis.0/dev_addr; fi
    if [ -n "${HOST_MAC_RNDIS}" ]; then echo "${HOST_MAC_RNDIS}" > functions/rndis.0/host_addr; fi

    # RNDIS specific interface class/subclass/protocol for IAD (Interface Association Descriptor)
    # These values help Windows identify the RNDIS function correctly sometimes.
    # Class EFh (Misc), SubClass 04h, Protocol 01h for RNDIS IAD is common.
    # However, RNDIS main interfaces are CDC Control (02h/02h/FFh) & CDC Data (0Ah/00h/00h)
    # The OS Descriptors are the more robust way for Windows.
    # Some f_rndis versions expose these; if not, they are set by the function driver.
    # echo "0xEF" > functions/rndis.0/class # Example, may not be needed if OS desc are primary
    # echo "0x04" > functions/rndis.0/subclass
    # echo "0x01" > functions/rndis.0/protocol


    # 6. Configure Microsoft OS Descriptors for RNDIS
    echo "Configuring Microsoft OS Descriptors for RNDIS..."
    mkdir -p os_desc
    echo "1" > os_desc/use              # Enable OS Descriptors
    echo "${MS_VENDOR_CODE}" > os_desc/b_vendor_code
    echo "${MS_QW_SIGN}" > os_desc/qw_sign

    # Per-interface OS Descriptors for RNDIS function
    # The path might be just functions/rndis.0/os_desc/interface/ for some kernels
    # or more specifically functions/rndis.0/os_desc/interface.rndis/
    # We will try a common one. Check kernel docs if this fails.
    mkdir -p functions/rndis.0/os_desc/interface.rndis
    echo "${MS_COMPAT_ID_RNDIS}" > functions/rndis.0/os_desc/interface.rndis/compatible_id
    echo "${MS_SUBCOMPAT_ID_RNDIS}" > functions/rndis.0/os_desc/interface.rndis/sub_compatible_id


    # 7. Create Configuration 1 (c.1 - for NCM)
    echo "Creating Configuration 1 (CDC/NCM)..."
    mkdir -p configs/c.1
    mkdir -p configs/c.1/strings/0x409
    echo "${CFG1_NAME}" > configs/c.1/strings/0x409/configuration
    echo "${BM_ATTRIBUTES}" > configs/c.1/bmAttributes
    echo "${MAX_POWER_CONFIGFS}" > configs/c.1/MaxPower
    # Link NCM function to this configuration
    ln -s "${GADGET_PATH}/functions/ncm.0" "${GADGET_PATH}/configs/c.1/f1" # Using 'f1' as link name

    # 8. Create Configuration 2 (c.2 - for RNDIS)
    echo "Creating Configuration 2 (RNDIS)..."
    mkdir -p configs/c.2
    mkdir -p configs/c.2/strings/0x409
    echo "${CFG2_NAME}" > configs/c.2/strings/0x409/configuration
    echo "${BM_ATTRIBUTES}" > configs/c.2/bmAttributes # Can be same or different
    echo "${MAX_POWER_CONFIGFS}" > configs/c.2/MaxPower
    # Link RNDIS function to this configuration
    ln -s "${GADGET_PATH}/functions/rndis.0" "${GADGET_PATH}/configs/c.2/f1" # Using 'f1' as link name

    # Link RNDIS configuration (c.2) to OS Descriptors
    # This tells Windows which configuration to use for OS specific descriptors.
    # The link name inside os_desc can be 'config' or 'c1' or match the config name.
    # Using 'config' as it's a common convention.
    ln -s "${GADGET_PATH}/configs/c.2" "${GADGET_PATH}/os_desc/config"


    # 9. Bind gadget to UDC
    echo "Looking for UDC: ${UDC_DEVICE}..."
    AVAILABLE_UDCS=$(ls /sys/class/udc/ 2>/dev/null || true)
    if [ -z "${AVAILABLE_UDCS}" ]; then
        echo "Error: No UDC drivers found in /sys/class/udc/. Cannot bind gadget."
        echo "Ensure your UDC kernel driver is loaded (e.g., dwc2 for Raspberry Pi)."
        cleanup_gadget # Attempt to clean up partially created gadget
        exit 1
    fi

    UDC_TO_USE=""
    for UDC_CTRL in $AVAILABLE_UDCS; do
        if [ "$UDC_CTRL" == "$UDC_DEVICE" ]; then
            UDC_TO_USE=$UDC_CTRL
            break
        fi
    done

    if [ -z "$UDC_TO_USE" ]; then
         # If specific UDC not found, try the first available one
        UDC_TO_USE=$(ls /sys/class/udc/ | head -n1)
        echo "Warning: UDC '${UDC_DEVICE}' not found. Using first available UDC: '${UDC_TO_USE}'."
        if [ -z "$UDC_TO_USE" ]; then # Should not happen if AVAILABLE_UDCS was not empty
             echo "Error: No UDC could be selected."
             cleanup_gadget
             exit 1
        fi
    fi

    echo "Binding gadget to UDC: ${UDC_TO_USE}..."
    echo "${UDC_TO_USE}" > UDC

    echo "USB Gadget ${GADGET_INSTANCE_NAME} setup complete."
    echo "Device should now be active."
    echo "To disable, run: echo \"\" > ${GADGET_PATH}/UDC"
    echo "To completely remove, run this script with the 'cleanup' argument."
}


# --- Main Script Logic ---
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

case "$1" in
    cleanup|stop)
        cleanup_gadget
        ;;
    setup|start|"")
        # Optional: cleanup before setup if you want to ensure a fresh start
        # cleanup_gadget
        setup_gadget
        ;;
    *)
        echo "Usage: $0 [setup|cleanup]"
        exit 1
        ;;
esac

exit 0
