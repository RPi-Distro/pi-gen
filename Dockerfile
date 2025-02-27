ARG BASE_IMAGE=debian:bullseye
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

COPY . /pi-gen/

RUN apt-get -y update && \
    apt-get install -y $(sed "s/.*://g" /pi-gen/depends) && \
    && rm -rf /var/lib/apt/lists/*

VOLUME [ "/pi-gen/work", "/pi-gen/deploy"]
