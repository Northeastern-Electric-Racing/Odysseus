RPI_DTLOADER_VERSION = 1.0
RPI_DTLOADER_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/package/rpi-dtloader
RPI_DTLOADER_SITE_METHOD = local
RPI_DTOVERLAY_DEPENDENCIES += host-dtc

define RPI_DTLOADER_INSTALL_TARGET_CMDS
	$(foreach dts,$(call qstrip,$(BR2_PACKAGE_RPI_DTLOADER_FILES)), \
		$(HOST_DIR)/usr/bin/dtc -@ -I dts -O dtb -o $(@D)/$(notdir $(basename $(dts))).dtbo $(dts) && \
		$(INSTALL) -D -m 0644 $(@D)/$(notdir $(basename $(dts))).dtbo $(BINARIES_DIR)/rpi-firmware/overlays/
	)
endef

$(eval $(generic-package))
