#!/bin/bash -e

for fl in /usr/src/linux-headers-*; do
	lh=$(basename "${fl}")
	kv="${lh#"linux-headers-"}"
	apt-get -y install sd8887-mrvl-modules-"${kv}"
	depmod -a "${kv}"
done
