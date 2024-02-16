RPI_UTILS_VERSION = e65f5ec102e74218cda7da9fdc8b1caa0fd1127d
RPI_UTILS_SITE = $(call github,raspberrypi,utils,$(RPI_UTILS_VERSION))

include $(sort $(wildcard $(BR2_EXTERNAL_ODY_TREE_PATH)/package/rpi-utils/*/*.mk))
