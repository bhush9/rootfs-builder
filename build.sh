#!/bin/sh

set -ex

if [ "$#" -ne 1 ]; then
    echo "At least one argument needed, caf or generic"
    exit 1
fi

export ARCH=armhf

# configure the live-build
lb config \
        --mode ubuntu \
        --distribution xenial \
        --binary-images none \
        --memtest none \
        --source false \
        --archive-areas "main restricted universe multiverse" \
        --apt-source-archives true \
        --architectures armhf \
        --linux-flavours none \
        --bootloader none \
        --initramfs-compression lzma \
        --initsystem none \
        --bootappend-live hostname=ubuntu-phablet \
        --chroot-filesystem plain \
        --apt-options "--yes -o Debug::pkgProblemResolver=true" \
        --compression gzip \
        --system normal \
        --zsync false \
        --linux-packages=none \
        --backports true \
        --apt-recommends false \
        --initramfs=none

# make caf or generic
sed -i "s/VARIANT/$1/g" customization/archives/*.list

# Copy the customization
cp -rf customization/* config/

# build the rootfs
lb build

# live-build itself is meh, it creates the tarball with directory structure of binary/boot/filesystem.dir
# so we pass --binary-images none to lb config and create tarball on our own
if [ -e "binary/boot/filesystem.dir" ]; then
        (cd "binary/boot/filesystem.dir/" && tar -c *) | gzip -9 --rsyncable > "halium-rootfs-$1.tar.gz"
        ls -lah
        chmod 644 "halium-rootfs-$1.tar.gz"
fi
