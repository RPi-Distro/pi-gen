FROM debian:stretch-backports

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update \
    && apt-get -y install \
        git vim parted \
        quilt realpath qemu-user-static debootstrap zerofree pxz zip dosfstools \
        bsdtar libcap2-bin rsync grep udev xz-utils curl xxd file \
        build-essential cmake python3 ant sudo \
    && apt-get -y -t stretch-backports install openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*
