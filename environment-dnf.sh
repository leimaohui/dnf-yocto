#!/bin/sh

export TARGET_ROOTFS=$1
export REPO_DIR=$2
WORKDIR=`pwd`

#Check the parameters
if [ -z "$2" -o $1 = "--help" -o $1 = "-h" -o $1 = "-H" ]; then
    echo ""
    echo "usage:     . $0 rootfs_dir repo_dir"
    echo ""
    echo "#For example: If you want to install rpms from x86_64"
    echo "     #ls /home/yocto/workdir/dnf/oe-repo/rpm"
    echo "     i586  noarch  qemux86"
    echo ""
    echo "#You should use the following command to set your smart environment"
    echo "      . $0 /home/yocto/x86_64_ubinuxv16_rootfs /home/yocto/workdir/dnf/oe-repo"
    echo ""
    exit 0
fi

if [ ! -d $TARGET_ROOTFS ]; then
    echo " $TARGET_ROOTFS is not exist. mkdir $TARGET_ROOTFS. "
    mkdir -p $TARGET_ROOTFS
fi

if [ ! -d $REPO_DIR/rpm ]; then
    echo "Error! $REPO_DIR/rpm is not exist. "
    exit 0
fi

#create repodata for rpm packages.
createrepo_c --update -q $REPO_DIR

# Pseudo Environment
export LD_LIBRARY_PATH=$OECORE_NATIVE_SYSROOT/usr/bin/../lib/pseudo/lib:$OECORE_NATIVE_SYSROOT/usr/bin/../lib/pseudo/lib64
export LD_PRELOAD=libpseudo.so
export PSEUDO_PASSWD=$TARGET_ROOTFS
export PSEUDO_OPTS=
export PSEUDO_LIBDIR=$OECORE_NATIVE_SYSROOT/usr/bin/../lib/pseudo/lib64
export PSEUDO_NOSYMLINKEXP=1
export PSEUDO_DISABLED=0
export PSEUDO_PREFIX=$OECORE_NATIVE_SYSROOT/usr
export PSEUDO_LOCALSTATEDIR=`pwd`/pseudo/

export D=$TARGET_ROOTFS
export OFFLINE_ROOT=$TARGET_ROOTFS
export IPKG_OFFLINE_ROOT=$TARGET_ROOTFS
export OPKG_OFFLINE_ROOT=$TARGET_ROOTFS
export INTERCEPT_DIR=$WORKDIR/intercept_scripts
export NATIVE_ROOT=$OECORE_NATIVE_SYSROOT
export RPM_ETCCONFIGDIR=$TARGET_ROOTFS

#necessary dnf config
if [ ! -d $TARGET_ROOTFS/etc/dnf ]; then
    mkdir -p $TARGET_ROOTFS/etc/dnf
    touch $TARGET_ROOTFS/etc/dnf/dnf.conf
fi

if [ ! -d $TARGET_ROOTFS/etc/dnf/vars ]; then
    mkdir -p $TARGET_ROOTFS/etc/dnf/vars
    echo -n "${MACHINE_ARCH}:${ARCH}:" >> $TARGET_ROOTFS/etc/dnf/vars/arch
    for line in `ls $REPO_DIR/rpm`;do
        if [ "$line" != "all" ] && [ "$line" != "any" ] && [ "$line" != "noarch" ] && [ "$line" != "${ARCH}" ] && [ "$line" != "${MACHINE_ARCH}" ]; then
            echo -n "$line:" >> $TARGET_ROOTFS/etc/dnf/vars/arch
        fi
    done
fi
sed -i "s/:$/\n/g" $TARGET_ROOTFS/etc/dnf/vars/arch

#necessary rpm config
if [ ! -d $TARGET_ROOTFS/etc/rpm ] || [ ! -f $TARGET_ROOTFS/etc/rpm/platform ]; then
    mkdir -p $TARGET_ROOTFS/etc/rpm
    echo "${MACHINE_ARCH}-pc-linux" > $TARGET_ROOTFS/etc/rpm/platform
fi

if [ ! -f $TARGET_ROOTFS/etc/rpmrc ]; then
    echo -n "arch_compat: ${MACHINE_ARCH}: all any noarch ${ARCH} ${MACHINE_ARCH}" > $TARGET_ROOTFS/etc/rpmrc
    for line in `ls $REPO_DIR/rpm`;do
        if [ "$line" != "all" ] && [ "$line" != "any" ] && [ "$line" != "noarch" ] && [ "$line" != "${ARCH}" ] && [ "$line" != "${MACHINE_ARCH}" ]; then
            echo " $line:" >> $TARGET_ROOTFS/etc/rpmrc
        fi
    done
    sed -i "s/:$//g" $TARGET_ROOTFS/etc/rpmrc
fi
