# Gnome demo image

require sakoman-console-image.bb

IMAGE_LINGUAS = "en-gb en-us de-de es-es fr-fr ja-jp"
ROOTFS_POSTPROCESS_COMMAND += 'install_linguas;'
IMAGE_PREPROCESS_COMMAND = "create_etc_timestamp"

IMAGE_LOGIN_MANAGER = "shadow"
IMAGE_SPLASH = "psplash-sakoman"

ANGSTROM_EXTRA_INSTALL ?= ""

IMAGE_INSTALL += " \
  ${ANGSTROM_EXTRA_INSTALL} \
  ${IMAGE_SPLASH} \
  angstrom-task-gnome \
  nfs-utils nfs-utils-client \
  task-gnome-apps \
  task-gnome-sdk \
  ti-msp430-chronos-apps \
  avrdude \
 "

IMAGE_INSTALL_append_omap3-multi += " \
  libgles-omap3-x11demos \
  libgles-omap3-x11trainingcourses \
  "
