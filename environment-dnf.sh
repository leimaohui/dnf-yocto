#!/bin/sh

#export TARGET_ROOTFS=$1
#export REPO_DIR=$2


TARGETROOTFS=$1
REPODIR=$2
SPDXREPODIR=$3
SPDXDIR=$4
SRPMREPODIR=$5
SRPMDIR=$6
WORKDIR=`pwd`

echo "export TARGET_ROOTFS=$TARGETROOTFS" > $WORKDIR/.env-dnf
echo "export REPO_DIR=$REPODIR" >> $WORKDIR/.env-dnf
echo "export SPDX_REPO_DIR=$SPDXREPODIR" >> $WORKDIR/.env-dnf
echo "export SPDX_DESTINATION_DIR=$SPDXDIR" >> $WORKDIR/.env-dnf
echo "export SRPM_REPO_DIR=$SRPMREPODIR" >> $WORKDIR/.env-dnf
echo "export SRPM_DESTINATION_DIR=$SRPMDIR" >> $WORKDIR/.env-dnf
echo "export LD_LIBRARY_PATH=$OECORE_NATIVE_SYSROOT/usr/bin/../lib/pseudo/lib:$OECORE_NATIVE_SYSROOT/usr/bin/../lib/pseudo/lib64" >> $WORKDIR/.env-dnf
echo "export LD_PRELOAD=libpseudo.so" >> $WORKDIR/.env-dnf
echo "export PSEUDO_PASSWD=$TARGETROOTFS" >> $WORKDIR/.env-dnf 
echo "export PSEUDO_OPTS=" >> $WORKDIR/.env-dnf
echo "export PSEUDO_LIBDIR=$OECORE_NATIVE_SYSROOT/usr/bin/../lib/pseudo/lib64" >> $WORKDIR/.env-dnf
echo "export PSEUDO_NOSYMLINKEXP=1" >> $WORKDIR/.env-dnf
echo "export PSEUDO_DISABLED=0" >> $WORKDIR/.env-dnf
echo "export PSEUDO_PREFIX=$OECORE_NATIVE_SYSROOT/usr" >> $WORKDIR/.env-dnf
echo "export PSEUDO_LOCALSTATEDIR=$WORKDIR/pseudo/" >> $WORKDIR/.env-dnf
echo "export D=$TARGETROOTFS" >> $WORKDIR/.env-dnf
echo "export OFFLINE_ROOT=$TARGETROOTFS" >> $WORKDIR/.env-dnf
echo "export IPKG_OFFLINE_ROOT=$TARGETROOTFS" >> $WORKDIR/.env-dnf
echo "export OPKG_OFFLINE_ROOT=$TARGETROOTFS" >> $WORKDIR/.env-dnf
echo "export INTERCEPT_DIR=$WORKDIR/intercept_scripts" >> $WORKDIR/.env-dnf
echo "export NATIVE_ROOT=$OECORE_NATIVE_SYSROOT" >> $WORKDIR/.env-dnf
echo "export RPM_ETCCONFIGDIR=$TARGETROOTFS" >> $WORKDIR/.env-dnf

source $WORKDIR/.env-dnf 

#Check the parameters
if [ -z "${REPO_DIR}" -o ${TARGET_ROOTFS} = "--help" -o ${TARGET_ROOTFS} = "-h" -o ${TARGET_ROOTFS} = "-H" ]; then
    echo ""
    echo "usage:     . $0 rootfs_dir repo_dir"
    echo ""
    echo "#For example: If you want to install rpms from x86_64"
    echo "     #ls /home/yocto/workdir/dnf/oe-repo/rpm"
    echo "     i586  noarch  qemux86"
    echo ""
    echo "#You should use the following command to set your dnf environment"
    echo "      . $0 /home/yocto/x86_64_ubinuxv16_rootfs /home/yocto/workdir/dnf/oe-repo"
    echo ""
    exit 0
fi

if [ ! -d $TARGET_ROOTFS ]; then
    echo " $TARGET_ROOTFS is not exist. mkdir $TARGET_ROOTFS. "
    mkdir -p $TARGET_ROOTFS
fi

#create repodata for rpm packages.
if [ ${REPODIR:0:4} = "http" ];then
    echo "This is a remote repo!"
else
    if [ ! -d $REPO_DIR/rpm ]; then
        echo "Error! $REPO_DIR/rpm is not exist. "
        exit 0
    fi
    createrepo_c.real --update -q $REPO_DIR
fi

# Pseudo Environment
#export LD_LIBRARY_PATH=$OECORE_NATIVE_SYSROOT/usr/bin/../lib/pseudo/lib:$OECORE_NATIVE_SYSROOT/usr/bin/../lib/pseudo/lib64
#export LD_PRELOAD=libpseudo.so
#export PSEUDO_PASSWD=$TARGET_ROOTFS
#export PSEUDO_OPTS=
#export PSEUDO_LIBDIR=$OECORE_NATIVE_SYSROOT/usr/bin/../lib/pseudo/lib64
#export PSEUDO_NOSYMLINKEXP=1
#export PSEUDO_DISABLED=0
#export PSEUDO_PREFIX=$OECORE_NATIVE_SYSROOT/usr
#export PSEUDO_LOCALSTATEDIR=$WORKDIR/pseudo/

#export D=$TARGET_ROOTFS
#export OFFLINE_ROOT=$TARGET_ROOTFS
#export IPKG_OFFLINE_ROOT=$TARGET_ROOTFS
#export OPKG_OFFLINE_ROOT=$TARGET_ROOTFS
#export INTERCEPT_DIR=$WORKDIR/intercept_scripts
#export NATIVE_ROOT=$OECORE_NATIVE_SYSROOT
#export RPM_ETCCONFIGDIR=$TARGET_ROOTFS


#necessary dnf config
if [ ! -d $TARGET_ROOTFS/etc/dnf ]; then
    mkdir -p $TARGET_ROOTFS/etc/dnf
    touch $TARGET_ROOTFS/etc/dnf/dnf.conf
fi

#clean the original content in dnf.conf file
echo "[main]" > $TARGET_ROOTFS/etc/dnf/dnf.conf
#Add config_path in dnf.conf file
echo "spdx_repodir=$SPDXREPODIR" >> $TARGET_ROOTFS/etc/dnf/dnf.conf
echo "spdx_download=$SPDXDIR" >> $TARGET_ROOTFS/etc/dnf/dnf.conf
echo "srpm_repodir=$SRPMREPODIR" >> $TARGET_ROOTFS/etc/dnf/dnf.conf
echo "srpm_download=$SRPMDIR" >> $TARGET_ROOTFS/etc/dnf/dnf.conf

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

