FROM i386/debian:buster

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        git vim parted \
        quilt coreutils debootstrap zerofree zip dosfstools \
        bsdtar libcap2-bin rsync grep udev xz-utils curl xxd file kmod bc\
        qemu-user-static binfmt-support ca-certificates gnupg\
    && rm -rf /var/lib/apt/lists/*

COPY export-image /pi-gen/export-image
COPY export-noobs /pi-gen/export-noobs
COPY scripts /pi-gen/scripts
COPY build.sh /pi-gen/build.sh
COPY config /pi-gen/config

ENV GIT_HASH=develop

WORKDIR /pi-gen