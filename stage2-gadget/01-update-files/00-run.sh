set -e

# Update config.txt to remove otg_mode=1 and add dr_mode=peripheral
# and update cmdline.txt to load usb ethernet modules.
CONFIG="${ROOTFS_DIR}/boot/firmware/config.txt"
CMDLINE="${ROOTFS_DIR}/boot/firmware/cmdline.txt"
if grep -q "otg_mode=1" ${CONFIG}; then
    echo "Updating dwc2 overlay to remove otg mode"
    sed -i.bak -e '/otg_mode=/d' ${CONFIG}
fi
if ! grep -q "dr_mode=peripheral" ${CONFIG}; then
    echo "Updating dwc2 overlay for peripheral mode"
    sed -i.bak -e '/dtoverlay=dwc2/d' -e '1s/^/dtoverlay=dwc2,dr_mode=peripheral\n/' ${CONFIG}
fi
if ! grep -q "enable_uart=" ${CONFIG}; then
    echo "Enabling UART"
    sed -i.bak '1s/^/enable_uart=1\n/' ${CONFIG}
fi

if ! grep -q "modules-load=dwc2" ${CMDLINE}; then
    echo "Updating cmdline.txt to load usb ethernet modules"
    sed -i.bak -e 's/rootwait/rootwait modules-load=dwc2,usb_f_ncm,usb_f_rndis/' ${CMDLINE}
fi

on_chroot << EOF
   systemctl enable usb-gadget.service
EOF
