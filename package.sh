#!/bin/bash

cd deploy

# Rename images
for f in image_*; do
    mv -v $f $(echo $f | sed 's/image_//g')
done

# Add checksums
for i in *.zip;
    do md5sum $i > $i.md5 && sha256sum $i > $i.sha256
done
