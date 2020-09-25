sudo umount work/*/stage?/rootfs/*
sudo rm -r deploy/* work/* || true 
sudo CLEAN=1 ./build.sh 2>&1 | sudo tee pi-gen.out
