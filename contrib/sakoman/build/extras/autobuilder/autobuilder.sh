#!/bin/bash
# Copyright Sakoman Inc. 2010

# edit if necessary to reflect your setup
source $OETOP/build/profile

RELEASE=gnome-r12

# path to feed directory
OE_FEED="/var/www/feeds/$RELEASE/ipk/glibc/armv7a"

#path to store local archive of images
ARCHIVE="/var/www/feeds/$RELEASE/images"

if [ ! -d $OE_FEED ]; then
	mkdir -p $OE_FEED
fi

if [ ! -d $ARCHIVE ]; then
	mkdir -p $ARCHIVE
fi


# list of libc variants to build
BUILD_LIBC=" \
            glibc \
           "

# list of machines to build machine dependent packages for
MACHINES_MACH=" \
                overo \
                beagleboard \
                rockhopper \
                omap4430-panda \
               "
# read list of machine dependent targets
BUILD_TARGETS_MACH=`cat $OETOP/build/extras/autobuilder/targets-mach`

# list of machines to build architecture dependent packages for
MACHINES_ARCH=" \
                omap3-multi \
                omap4-multi \
               "
# list of architecture dependent targets
BUILD_TARGETS_ARCH=" \
                linux-sakoman \
                sakoman-minimal-image \
                sakoman-console-image \
                sakoman-gnome-image \
               "

cd $OETOP/openembedded
git checkout $RELEASE && git fetch && git reset --hard origin/$RELEASE

REVISION=`date +%Y%m%d%H%M`
COMMIT=`git log -1 --pretty=oneline`

BUILD_CLEAN_MACH="x-load-sakoman u-boot-sakoman"
BUILD_CLEAN_ARCH="linux-sakoman omap3-sgx-modules task-base task-boot base-files base-passwd sysvinit angstrom-feed-configs angstrom-task-gnome"

if [ -e $OE_FEED ];
then
  echo "Building revision $REVISION"
  
#  mv $OETOP/tmp $OETOP/tmpdel
#  rm -rf $OETOP/tmpdel &

  mv $OETOP/build/conf/auto.conf $OETOP/build/conf/auto.conf.bak

  for libc in $BUILD_LIBC
  do
    #do machine dependent packages first   
    for machine in $MACHINES_MACH
    do
      if [ -e $OETOP/tmp ]
      then
        ANGSTROMLIBC=$libc MACHINE=$machine bitbake -c clean $BUILD_CLEAN_MACH
      fi

      for target in $BUILD_TARGETS_MACH
      do
        echo "Building $libc $target for $machine"
        ANGSTROMLIBC=$libc MACHINE=$machine bitbake $target
        echo "Completed $libc $target for $machine"
      done
    done

    #do architecture dependent packages next   
    for machine in $MACHINES_ARCH
    do
      if [ -e $OETOP/tmp ]
      then
        ANGSTROMLIBC=$libc MACHINE=$machine bitbake -c clean $BUILD_CLEAN_ARCH
      fi

      for target in $BUILD_TARGETS_ARCH
      do
        echo "Building $libc $target for $machine"
        ANGSTROMLIBC=$libc MACHINE=$machine bitbake $target
        echo "Completed $libc $target for $machine"
      done
    done

  done

  mv $OETOP/build/conf/auto.conf.bak $OETOP/build/conf/auto.conf

# make repo directories
  mkdir -p $OE_FEED/../all
  mkdir -p $OE_FEED/base
  mkdir -p $OE_FEED/debug
  mkdir -p $OE_FEED/gstreamer
  mkdir -p $OE_FEED/perl
  mkdir -p $OE_FEED/python
  for machine in $MACHINES_MACH $MACHINES_ARCH
  do
    mkdir -p $OE_FEED/machine/$machine
  done

# archive images
  for machine in $MACHINES_MACH
  do
    mkdir -p $ARCHIVE/$machine/$REVISION
    cp --update $OETOP/tmp/deploy/glibc/images/$machine/MLO-$machine		$ARCHIVE/$machine/$REVISION/MLO-$machine-$REVISION
    cp --update $OETOP/tmp/deploy/glibc/images/$machine/u-boot-$machine.bin	$ARCHIVE/$machine/$REVISION/u-boot-$machine-$REVISION.bin

    cd $ARCHIVE/$machine/$REVISION
    echo $COMMIT > sakoman-oe-commit-id.txt
    md5sum MLO-$machine-$REVISION > md5sum.txt
    md5sum u-boot-$machine-$REVISION.bin >> md5sum.txt

    rm -rf $ARCHIVE/$machine/current
    mkdir -p $ARCHIVE/$machine/current
    echo $REVISION > $ARCHIVE/$machine/current/current-is-$REVISION
    ln -s $ARCHIVE/$machine/$REVISION/md5sum.txt $ARCHIVE/$machine/current/md5sum.txt
    ln -s $ARCHIVE/$machine/$REVISION/sakoman-oe-commit-id.txt $ARCHIVE/$machine/current/sakoman-oe-commit-id.txt
    ln -s $ARCHIVE/$machine/$REVISION/MLO-$machine-$REVISION $ARCHIVE/$machine/current/MLO
    ln -s $ARCHIVE/$machine/$REVISION/u-boot-$machine-$REVISION.bin $ARCHIVE/$machine/current/u-boot.bin

  done

  for machine in $MACHINES_ARCH
  do
    mkdir -p $ARCHIVE/$machine/$REVISION
    cp --update $OETOP/tmp/deploy/glibc/images/$machine/uImage-$machine.bin	$ARCHIVE/$machine/$REVISION/uImage-$machine-$REVISION.bin
    cp --update $OETOP/tmp/deploy/glibc/images/$machine/sakoman-minimal-image-$machine.tar.bz2	$ARCHIVE/$machine/$REVISION/sakoman-minimal-image-$machine-$REVISION.tar.bz2
    cp --update $OETOP/tmp/deploy/glibc/images/$machine/sakoman-console-image-$machine.tar.bz2	$ARCHIVE/$machine/$REVISION/sakoman-console-image-$machine-$REVISION.tar.bz2
    cp --update $OETOP/tmp/deploy/glibc/images/$machine/sakoman-gnome-image-$machine.tar.bz2	$ARCHIVE/$machine/$REVISION/sakoman-gnome-image-$machine-$REVISION.tar.bz2
    cp --update $OETOP/tmp/deploy/glibc/images/$machine/modules-*-*-$machine.tgz $ARCHIVE/$machine/$REVISION/modules-$machine-$REVISION.tgz
    cp --update $OETOP/openembedded/contrib/sakoman/mksdcard.sh $ARCHIVE/$machine/$REVISION/

    cd $ARCHIVE/$machine/$REVISION
    echo $COMMIT > sakoman-oe-commit-id.txt
    md5sum uImage-$machine-$REVISION.bin >> md5sum.txt
    md5sum sakoman-console-image-$machine-$REVISION.tar.bz2 >> md5sum.txt
    md5sum sakoman-minimal-image-$machine-$REVISION.tar.bz2 >> md5sum.txt
    md5sum sakoman-gnome-image-$machine-$REVISION.tar.bz2 >> md5sum.txt
    md5sum modules-$machine-$REVISION.tgz >> md5sum.txt
    md5sum mksdcard.sh >> md5sum.txt

    rm -rf $ARCHIVE/$machine/current
    mkdir -p $ARCHIVE/$machine/current
    echo $REVISION > $ARCHIVE/$machine/current/current-is-$REVISION
    ln -s $ARCHIVE/$machine/$REVISION/md5sum.txt $ARCHIVE/$machine/current/md5sum.txt
    ln -s $ARCHIVE/$machine/$REVISION/sakoman-oe-commit-id.txt $ARCHIVE/$machine/current/sakoman-oe-commit-id.txt
    ln -s $ARCHIVE/$machine/$REVISION/uImage-$machine-$REVISION.bin $ARCHIVE/$machine/current/uImage
    ln -s $ARCHIVE/$machine/$REVISION/sakoman-minimal-image-$machine-$REVISION.tar.bz2 $ARCHIVE/$machine/current/sakoman-minimal-image.tar.bz2
    ln -s $ARCHIVE/$machine/$REVISION/sakoman-console-image-$machine-$REVISION.tar.bz2 $ARCHIVE/$machine/current/sakoman-console-image.tar.bz2
    ln -s $ARCHIVE/$machine/$REVISION/sakoman-gnome-image-$machine-$REVISION.tar.bz2 $ARCHIVE/$machine/current/sakoman-gnome-image.tar.bz2
    ln -s $ARCHIVE/$machine/$REVISION/modules-$machine-$REVISION.tgz $ARCHIVE/$machine/current/modules.tgz
    ln -s $ARCHIVE/$machine/$REVISION/mksdcard.sh $ARCHIVE/$machine/current/mksdcard.sh

  done

# now we construct a local feed
# copy package files
  cp --update $OETOP/tmp/deploy/glibc/ipk/all/*    $OE_FEED/../all
  cp --update $OETOP/tmp/deploy/glibc/ipk/armv7a/* $OE_FEED/base
  for machine in $MACHINES_MACH $MACHINES_ARCH
  do
      cp --update $OETOP/tmp/deploy/glibc/ipk/$machine/* $OE_FEED/machine/$machine
  done

# get rid of unneeded files
  rm -rf $OE_FEED/base/morgue

# place package files in appropriate feed directory
  mv -u $OE_FEED/../all/*-dbg_*     	$OE_FEED/debug
  mv -u $OE_FEED/base/*-dbg_*    	$OE_FEED/debug
  mv -u $OE_FEED/base/gst-*      	$OE_FEED/gstreamer
  mv -u $OE_FEED/base/gstreamer* 	$OE_FEED/gstreamer
  mv -u $OE_FEED/base/perl*      	$OE_FEED/perl
  mv -u $OE_FEED/base/python*    	$OE_FEED/python

# Create Packages.gz for feeds
  cd $OE_FEED/../all
  $OETOP/build/extras/autobuilder/ipkg-utils/ipkg-make-index . > Packages
  gzip -f Packages

  cd $OE_FEED/base
  $OETOP/build/extras/autobuilder/ipkg-utils/ipkg-make-index . > Packages
  gzip -f Packages

  for machine in $MACHINES_MACH $MACHINES_ARCH
  do
    cd $OE_FEED/machine/$machine
    $OETOP/build/extras/autobuilder/ipkg-utils/ipkg-make-index . > Packages
    gzip -f Packages
  done

  cd $OE_FEED/debug
  $OETOP/build/extras/autobuilder/ipkg-utils/ipkg-make-index . > Packages
  gzip -f Packages

  cd $OE_FEED/gstreamer
  $OETOP/build/extras/autobuilder/ipkg-utils/ipkg-make-index . > Packages
  gzip -f Packages

  cd $OE_FEED/perl
  $OETOP/build/extras/autobuilder/ipkg-utils/ipkg-make-index . > Packages
  gzip -f Packages

  cd $OE_FEED/python
  $OETOP/build/extras/autobuilder/ipkg-utils/ipkg-make-index . > Packages
  gzip -f Packages

fi

