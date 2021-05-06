# Install tailscale
# https://tailscale.com/kb/1025/install-rpi/
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/buster.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/buster.list | sudo tee /etc/apt/sources.list.d/tailscale.list

apt-get update

# Install n and node(lts)
# https://zenn.dev/mactkg/articles/5adc624787666c
curl -L https://raw.githubusercontent.com/tj/n/v7.2.2/bin/n -o n
echo "1a6492df162f66131c291260a2e9fd8e64288729 n" | sha1sum -c - || exit 1
chmod +x n
mkdir -p "${ROOTFS_DIR}/usr/local/bin"
mv n "${ROOTFS_DIR}/usr/local/bin"
N_NODE_MIRROR=https://unofficial-builds.nodejs.org/download/release/ N_PREFIX=${ROOTFS_DIR}/usr/local ${ROOTFS_DIR}/usr/local/bin/n lts

# Install Node RED
npm install -g --unsafe-perm node-red