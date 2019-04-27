#!/bin/bash

# Rename images
for f in *.zip; do
    mv -v ${f} $(echo ${f} | sed 's/image_//g' | sed 's/-lite//g')
done

# Add checksums
for i in *.zip; do
    md5sum ${i} > ${i}.md5
    sha256sum ${i} > ${i}.sha256
done
