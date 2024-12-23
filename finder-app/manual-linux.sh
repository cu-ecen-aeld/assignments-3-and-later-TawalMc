#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
# KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git 
# KERNEL_REPO=https://github.com/TawalMc/linux-stable.git
KERNEL_REPO=https://github.com/TawalMc/linux-stable/archive/coursera.tar.gz
# KERNEL_VERSION=v5.15.163
KERNEL_VERSION=coursera
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
SCRIPTS_FOLDER=$(pwd)

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	#git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
    
    wget -q ${KERNEL_REPO}
    tar -xf coursera.tar.gz
    mv linux-stable-coursera linux-stable
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    # echo "Checking out version ${KERNEL_VERSION}"
    # git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    echo "Building kernel"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "Creating root filesystem"
mkdir ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs

mkdir bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
else
    cd busybox
fi

# TODO: Make and install busybox
echo "Building and configuring busybox"
make distclean
make defconfig
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} CONFIG_PREFIX=${OUTDIR}/rootfs  install

cd ${OUTDIR}/rootfs
echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo "Adding library dependencies to rootfs from sysroot"
SYSROOT=$(aarch64-none-linux-gnu-gcc -print-sysroot)

cp -a ${SYSROOT}/lib/ld-linux-aarch64.so.1 lib

cp -a ${SYSROOT}/lib64/libm.so.6 lib64
cp -a ${SYSROOT}/lib64/libresolv.so.2 lib64
cp -a ${SYSROOT}/lib64/libc.so.6 lib64

# TODO: Make device nodes
echo "Make device nodes"
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

cd ${SCRIPTS_FOLDER}
# TODO: Clean and build the writer utility
echo "Building writer utility" 
${CROSS_COMPILE}gcc writer.c -o writer

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
echo "Copying file to rootfs/home"

cp writer ${OUTDIR}/rootfs/home 
cp finder-test.sh ${OUTDIR}/rootfs/home 
cp finder.sh ${OUTDIR}/rootfs/home 
cp autorun-qemu.sh ${OUTDIR}/rootfs/home 
cp -r ../conf ${OUTDIR}/rootfs/home

# TODO: Chown the root directory
cd ${OUTDIR}/rootfs
echo "Chown the root directory and creating"
find . | cpio -H newc -ov --owner root:root > ../initramfs.cpio

# TODO: Create initramfs.cpio.gz
cd ..
gzip initramfs.cpio