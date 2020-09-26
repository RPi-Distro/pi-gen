for MNT in $(mount | grep pi-gen | cut -d ' ' -f 3) ; do
    sudo umount ${MNT}
done
sudo rm -r deploy/* work/* 2&>1 > /dev/null || true 
sudo CONTINUE=1 ./build.sh -c "${1}" 2>&1 | sudo tee pi-gen.out
sudo umount /media/carl/* 2&>1 > /dev/null || true
sudo dd if=deploy/2020-09-26-RPiOS-buster-arm64-lite.img of=/dev/sdb bs=500M status=progress && sudo sync && sudo eject /dev/sdb