#!/usr/bin/env bash


# VERSION=$(grep 'Kernel Configuration' < config | awk '{print $3}')
sudo apt update
sudo apt install gpg python3-pyquery -y

python3 get-newest-version.py 0
VERSION=`cat /tmp/kernelversion.txt`
URL=`cat /tmp/kernelurl.txt`
MAINVERSION=`expr substr $VERSION 1 1`
SHOWVERSION=$VERSION

# add deb-src to sources.list
sed -i "/deb-src/s/# //g" /etc/apt/sources.list

# install dep
sudo apt update
sudo apt install -y wget xz-utils make gcc flex bison dpkg-dev bc rsync kmod cpio libssl-dev git lsb vim libelf-dev neofetch python3-pip python3-tk
pip3 install requests

sudo apt build-dep -y linux
neofetch


# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

wget $URL  
if [[ -f linux-"$VERSION".tar.xz ]]; then
    tar -xvf linux-"$VERSION".tar.xz
fi
if [[ -f linux-"$VERSION".tar.gz ]]; then
    tar -xvf linux-"$VERSION".tar.gz
fi
if [[ -f linux-"$VERSION".tar ]]; then
    tar -xvf linux-"$VERSION".tar
fi
if [[ -f linux-"$VERSION".bz2 ]]; then
    tar -xvf linux-"$VERSION".tar.bz2
fi
cd linux-"$VERSION" || exit



# download kernel source
# wget http://www.kernel.org/pub/linux/kernel/v6.x/linux-6.4.tar.gz  
# tar -xf linux-"$VERSION".tar.gz
# cd linux-"$VERSION" || exit

# copy config file
cp ../config .config
#
# disable DEBUG_INFO to speedup build
# scripts/config --disable DEBUG_INFO 
scripts/config --set-str SYSTEM_TRUSTED_KEYS ""
scripts/config --set-str SYSTEM_REVOCATION_KEYS ""
scripts/config --undefine DEBUG_INFO
scripts/config --undefine DEBUG_INFO_COMPRESSED
scripts/config --undefine DEBUG_INFO_REDUCED
scripts/config --undefine DEBUG_INFO_SPLIT
scripts/config --undefine GDB_SCRIPTS
scripts/config --set-val  DEBUG_INFO_DWARF5     n
scripts/config --set-val  DEBUG_INFO_NONE       y
# apply patches
# shellcheck source=src/util.sh
# source ../patch.d/*.sh



# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
sudo make bindeb-pkg -j"$CPU_CORES"

# move deb packages to artifact dir
cd ..


VERSIONS=`cat get_latest_kernel.txt`

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

wget http://www.kernel.org/pub/linux/kernel/v6.x/linux-"$VERSIONS".tar.gz    
if [[ -f linux-"$VERSIONS".tar.xz ]]; then
    tar -xvf linux-"$VERSIONS".tar.xz
fi
if [[ -f linux-"$VERSIONS".tar.gz ]]; then
    tar -xvf linux-"$VERSIONS".tar.gz
fi
if [[ -f linux-"$VERSIONS".tar ]]; then
    tar -xvf linux-"$VERSIONS".tar
fi
if [[ -f linux-"$VERSIONS".bz2 ]]; then
    tar -xvf linux-"$VERSIONS".tar.bz2
fi
cd linux-"$VERSIONS" || exit



# download kernel source
# wget http://www.kernel.org/pub/linux/kernel/v6.x/linux-6.4.tar.gz  
# tar -xf linux-"$VERSION".tar.gz
# cd linux-"$VERSION" || exit

# copy config file
cp ../config .config
#
# disable DEBUG_INFO to speedup build
# scripts/config --disable DEBUG_INFO 
scripts/config --set-str SYSTEM_TRUSTED_KEYS ""
scripts/config --set-str SYSTEM_REVOCATION_KEYS ""
scripts/config --undefine DEBUG_INFO
scripts/config --undefine DEBUG_INFO_COMPRESSED
scripts/config --undefine DEBUG_INFO_REDUCED
scripts/config --undefine DEBUG_INFO_SPLIT
scripts/config --undefine GDB_SCRIPTS
scripts/config --set-val  DEBUG_INFO_DWARF5     n
scripts/config --set-val  DEBUG_INFO_NONE       y

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
sudo make bindeb-pkg -j"$CPU_CORES"

# move deb packages to artifact dir
cd ..




mkdir "artifact"
mkdir kernel/$SHOWVERSION
rm -rfv *dbg*.deb
mv ./*.deb kernel/$SHOWVERSION
cd kernel/$SHOWVERSION
#mv ./* ../artifact/
mv ./*.deb artifact/
