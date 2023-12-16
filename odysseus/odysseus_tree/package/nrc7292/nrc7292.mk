NRC7292_PROVIDER_PROVIDES = nrc-module
NRC7292_VERSION = 1.5
NRC7292_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7292_sw_pkg/package/src/nrc
NRC7292_SITE_METHOD = local
NRC7292_LICENSE = LGPLv2.1/GPLv2
NRC7292_DEPENDENCIES += host-dtc

#NRC7292_MODULE_SUBDIRS = ./package/src/nrc

#define NRC7292_MODULE_LINUX_CONFIG_FIXUPS
#   $(call KCONFIG_ENABLE_OPT, CONFIG_OBJTOOL)
#endef

define NRC7292_MODULE_LINUX_OBJTOOL_FIX
   $(MAKE) -C $(LINUX_DIR)/tools/objtool
endef

define NRC7292_BUILD_DTO
	$(HOST_DIR)/usr/bin/dtc -@ -I dts -O dtb -o $(@D)/newracom.dtbo $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7292_sw_pkg/dts/newracom_for_5.16_or_later.dts
	$(INSTALL) -D -m 0644 $(@D)/newracom.dtbo $(BINARIES_DIR)/rpi-firmware/overlays/newracom.dtbo
endef


NRC7292_PRE_BUILD_HOOKS += NRC7292_BUILD_DTO

NRC7292_PRE_BUILD_HOOKS += NRC7292_MODULE_LINUX_OBJTOOL_FIX

NRC7292_MODULE_MAKE_OPTS = KDIR=$(LINUX_DIR)

$(eval $(kernel-module))
$(eval $(generic-package))

