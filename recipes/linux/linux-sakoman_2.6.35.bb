require linux.inc

DESCRIPTION = "Linux kernel for OMAP processors"
KERNEL_IMAGETYPE = "uImage"

COMPATIBLE_MACHINE = "beagleboard|omap3-multi|overo|omap4-multi|omap4430-panda|omap4430-sdp"

BOOT_SPLASH ?= "logo_linux_clut224-generic.ppm"
PV = "2.6.35"

S = "${WORKDIR}/git"

SRCREV = ${AUTOREV}
SRC_URI = "git://www.sakoman.com/git/linux-omap-2.6.git;branch=omap3-2.6.35;protocol=git \
	   file://defconfig \
           file://${BOOT_SPLASH} \
           "

SRCREV_omap4430-panda = ${AUTOREV}
SRC_URI_omap4430-panda = "git://www.sakoman.com/git/ubuntu-maverick.git;branch=omap-2.6.35;protocol=git \
	   file://defconfig \
           file://${BOOT_SPLASH} \
           "

SRCREV_omap4430-sdp = ${AUTOREV}
SRC_URI_omap4430-sdp = "git://www.sakoman.com/git/ubuntu-maverick.git;branch=omap-2.6.35;protocol=git \
	   file://defconfig \
           file://${BOOT_SPLASH} \
           "

SRCREV_omap4-multi = ${AUTOREV}
SRC_URI_omap4-multi = "git://www.sakoman.com/git/ubuntu-maverick.git;branch=omap-2.6.35;protocol=git \
	   file://defconfig \
           file://${BOOT_SPLASH} \
           "


