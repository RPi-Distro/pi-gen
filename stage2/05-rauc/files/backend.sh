#!/bin/bash
# Will be called with the following parameters:
# get-primary: output active slot bootname, return 0 on success, !=0 on error
# set-primary <slot.bootname> -> returns 0 on success, !=0 on error
# get-state <slot.bootname> -> return boot state of specific slot, returns good/bad on stdout, returns 0 on success, !0 on error
# set-state <slot.bootname> <state> (good: last boot was successful, bad: last boot failed). return 0 on success, !0 on error

case $1 in

  "get-primary")
    if [ -f "/mnt/factory_data/rauc/primary" ]; then
       cat /mnt/factory_data/rauc/primary
       exit 0
    fi
    exit 2
    ;;

  "set-primary")
    FDATA=`mktemp -d`
    BOOT=`mktemp -d`
    mount /dev/mmcblk0p5 $FDATA
    mount /dev/mmcblk0p1 $BOOT
    mkdir -p $FDATA/rauc
    # copy boot files and place a tryboot file
    cp -r /boot_factorydefault/* $BOOT/$2/
    cp /boot_factorydefault/config.txt $BOOT/tryboot.txt
    # hack fstab of target system to replace with correct root
    if [ $2 == "system1" ]; then
	ROOT=`mktemp -d`
	mount /dev/mmcblk0p3 $ROOT
        sed -i 's/mmcblk0p2/mmcblk0p3/g' $ROOT/etc/fstab
        sed -i 's/mmcblk0p2/mmcblk0p3/g' $BOOT/system1/cmdline.txt
	umount $ROOT
    fi

    echo "[all]" >> "$BOOT/tryboot.txt"
    echo "gpu_mem=16" >> "$BOOT/tryboot.txt"

    if [ $2 == "system1" ]; then
        cp /boot_factorydefault/start4cd.elf "$BOOT/1strt4cd.elf"
        cp /boot_factorydefault/fixup4cd.dat "$BOOT/1fxup4cd.dat"
        echo "start_file=1strt4cd.elf" >> "$BOOT/tryboot.txt"
        echo "fixup_file=1fxup4cd.dat" >> "$BOOT/tryboot.txt"
    else
        cp /boot_factorydefault/start4cd.elf "$BOOT/0strt4cd.elf"
        cp /boot_factorydefault/fixup4cd.dat "$BOOT/0fxup4cd.dat"
        echo "start_file=0strt4cd.elf" >> "$BOOT/tryboot.txt"
        echo "fixup_file=0fxup4cd.dat" >> "$BOOT/tryboot.txt"
    fi

    echo "os_prefix=/$2/" >> "$BOOT/tryboot.txt"
    echo $2>$FDATA/rauc/primary
    umount $FDATA
    umount $BOOT
    exit 0
    ;;

  "get-state")
    if [ -f "/mnt/factory_data/rauc/$2" ]; then
       cat /mnt/factory_data/rauc/$2
       exit 0
    fi
    exit 3
    ;;

  "set-state")
    FDATA=`mktemp -d`
    mount /dev/mmcblk0p5 $FDATA
    echo $3>$FDATA/rauc/$2
    umount $FDATA
    exit 0
    ;;

  none | *)
    echo Invalid argument.
    exit 1
    ;;
esac
