NRC7394_PROVIDER_PROVIDES = nrc-module
# match upstream sw_pkg version
NRC7394_VERSION = 1.2
NRC7394_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7394_sw_pkg/package/src/nrc
NRC7394_SITE_METHOD = local
NRC7394_LICENSE = LGPLv2.1/GPLv2

# set the makefile KDIR to buildroot kernel, as otherwise it will use host headers
NRC7394_MODULE_MAKE_OPTS = KDIR=$(LINUX_DIR)

# set custom bd file to default (evk) if unset, also set firmware file (unchainging)
BR2_PACKAGE_NRC7394_CUSTOM_BD_FILE ?=  $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7394_sw_pkg/package/evk/binary/nrc7394_bd.dat
NRC7394_FIRMWARE_FILE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7394_sw_pkg/package/evk/binary/nrc7394_cspi.bin

define NRC7394_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(BR2_PACKAGE_NRC7394_CUSTOM_BD_FILE) $(TARGET_DIR)/lib/firmware/nrc7394_bd.dat
	$(INSTALL) -D -m 0644 $(NRC7394_FIRMWARE_FILE) $(TARGET_DIR)/lib/firmware/nrc7394_cspi.bin
endef

NRC7394_POST_BUILD_HOOKS += NRC7394_BUILD_DTO


$(eval $(kernel-module))
$(eval $(generic-package))
