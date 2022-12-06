### Copy in dennisdebel's small screen skin into Mixxx
### See https://github.com/dennisdebel/pi_dj for more info
git clone https://github.com/dennisdebel/pi_dj.git files/pi_dj/
cp -r files/pi_dj/mixxx/skin/* "${ROOTFS_DIR}/usr/share/mixxx/skins/"

### Copy in pioneered skin
### See https://github.com/timewasternl/Pioneered for more info
git clone https://github.com/timewasternl/Pioneered files/Pioneered/
cp -r files/Pioneered "${ROOTFS_DIR}/usr/share/mixxx/skins/"
