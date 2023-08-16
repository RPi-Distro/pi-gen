ARG BASE_IMAGE=debian:bullseye
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        git vim parted \
        quilt coreutils qemu-user-static debootstrap zerofree zip dosfstools \
        libarchive-tools libcap2-bin rsync grep udev xz-utils curl xxd file kmod bc\
        binfmt-support ca-certificates qemu-utils kpartx fdisk gpg pigz\
    && rm -rf /var/lib/apt/lists/*

COPY . /mq-pi-gen/

VOLUME [ "/mq-pi-gen/work", "/mq-pi-gen/deploy"]
