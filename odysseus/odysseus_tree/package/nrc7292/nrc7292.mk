NRC7292_PROVIDER_PROVIDES = nrc-module
# match upstream sw_pkg version
NRC7292_VERSION = 1.5
NRC7292_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7292_sw_pkg/package/src/nrc
NRC7292_SITE_METHOD = local
NRC7292_LICENSE = LGPLv2.1/GPLv2
# require dtc for overlay compilation
NRC7292_DEPENDENCIES += host-dtc
# set the makefile KDIR to buildroot kernel, as otherwise it will use host headers
NRC7292_MODULE_MAKE_OPTS = KDIR=$(LINUX_DIR)

# set custom bd file to default (evk) if unset, also set firmware file (unchainging)
BR2_PACKAGE_NRC7292_CUSTOM_BD_FILE ?=  $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7292_sw_pkg/package/evk/binary/nrc7292_bd.dat
NRC7292_FIRMWARE_FILE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7292_sw_pkg/package/evk/binary/nrc7292_cspi.bin

define NRC7292_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(BR2_PACKAGE_NRC7292_CUSTOM_BD_FILE) $(TARGET_DIR)/lib/firmware/nrc7292_bd.dat
	$(INSTALL) -D -m 0644 $(NRC7292_FIRMWARE_FILE) $(TARGET_DIR)/lib/firmware/nrc7292_cspi.bin
endef

NRC7292_POST_BUILD_HOOKS += NRC7292_BUILD_DTO


$(eval $(kernel-module))
$(eval $(generic-package))

