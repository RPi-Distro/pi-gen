#!/bin/bash -e

# Install MXNet
wget -c -q -O mxnet.tar.gz https://d1onfpft10uf5o.cloudfront.net/greengrass-ml-installers/mxnet/ggc-mxnet-v1.2.1-python-raspi.tar.gz
tar -xzf mxnet.tar.gz -c "${ROOTFS_DIR}/opt"
rm -f mxnet.tar.gz

on_chroot << EOF
cd /opt/ggc-mxnet-v1.2.1-python-raspi
pip install mxnet-1.2.1-py2.py3-none-any.whl
EOF

# Install Tensorflow
wget -c -q -O tensorflow.tar.gz https://d1onfpft10uf5o.cloudfront.net/greengrass-ml-installers/tf/greengrass_ML@Edge_TF_v1_4_0_installer_cp27_raspi3_armv7.tar.gz
tar -xzf tensorflow.tar.gz -c "${ROOTFS_DIR}/opt"
rm -f tensorflow.tar.gz

on_chroot << EOF
cd /opt
pip install tensorflow-1.4.0-cp27-none-linux_armv7l.whl
EOF

# Install DL Framework
wget -c -q -O dlr.tar.gz https://d1onfpft10uf5o.cloudfront.net/greengrass-ml-installers/dlr/dlr-1.0-py2-armv7l.tar.gz
tar -xzf dlr.tar.gz -c "${ROOTFS_DIR}/opt"
rm -f dlr.tar.gz

on_chroot << EOF
cd /opt/dlr-1.0-py2-armv7l
easy_install dlr-1.0-py2.7-linux-armv7l.egg
EOF

### NOT DOING THESE FOR NOW. Not sure what the use case is
# Install Chainer
# wget -c -q -O chainer.tar.gz https://s3.amazonaws.com/chainer-greengrass-packages/chainer-installer-for-raspi-v4.0.0.tar.gz
# tar -xzf chainer.tar.gz
