#!/bin/bash

suffix=".deb"

if [[ ! -n "$1"  ]]; then
    echo 'deb file must not be empty!'
    exit
fi
if [[ "$1" != *"$suffix"  ]]; then
    echo 'file type must be deb!'
    exit
fi
echo "Extract $1 from the archive"
ar x $1
echo "Uncompress zstd $1 an re-compress them using xz"
zstd -d < control.tar.zst | xz > control.tar.xz
zstd -d < data.tar.zst | xz > data.tar.xz
echo "Re-create the Debian package in /tmp/$1"
ar -m -c -a sdsd /tmp/$1 debian-binary control.tar.xz data.tar.xz
echo 'Clean up'
rm debian-binary control.tar.xz data.tar.xz control.tar.zst data.tar.zst

echo "install $1"
sudo apt install /tmp/$1