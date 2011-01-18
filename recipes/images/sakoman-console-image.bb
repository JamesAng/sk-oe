# console image

inherit image

DEPENDS = "task-base"

RRECOMMENDS_${PN}_append_armv7a = " \
#  libgles-omap3 \
  omap3-writeprom \
 "

IMAGE_EXTRA_INSTALL ?= ""

AUDIO_INSTALL = " \
  alsa-utils \
  alsa-utils-aplay \
  alsa-utils-amixer \
  angstrom-zeroconf-audio \
 "

BASE_INSTALL = " \
  task-base-extended \
 "

FIRMWARE_INSTALL = " \
#  linux-firmware \
  marvell-sdio-fw \
  rt73-firmware \
  zd1211-firmware \
 "

TOOLS_INSTALL = " \
  bash \
  bzip2 \
  ckermit \
  cpufrequtils \
  devmem2 \
  dhcp-client \
  dosfstools \
  ethtool \
  fbgrab \
  fbset \
  fbset-modes \
  fuser \
  i2c-tools \
  iftop \
  ksymoops \
  linux-input \
  lsof \
  memtester \
  mkfs-jffs2 \
  mtd-utils \
  nano \
  ntp ntpdate \
  openssh-misc \
  openssh-scp \
  openssh-ssh \
  procps \
  socat \
  strace \
  sudo \
  syslog-ng \
  task-proper-tools \
  u-boot-sakoman-fw-utils \
  wget \
 "

IMAGE_INSTALL += " \
  ${BASE_INSTALL} \
  ${AUDIO_INSTALL} \
  ${FIRMWARE_INSTALL} \
  ${IMAGE_EXTRA_INSTALL} \
  ${TOOLS_INSTALL} \
 "

IMAGE_PREPROCESS_COMMAND = "create_etc_timestamp"

#ROOTFS_POSTPROCESS_COMMAND += '${@base_conditional("DISTRO_TYPE", "release", "zap_root_password; ", "",d)}'


