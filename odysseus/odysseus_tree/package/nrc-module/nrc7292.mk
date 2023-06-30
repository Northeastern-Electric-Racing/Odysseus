NRC7292_MODULE_VERSION = 1.0
NRC7292_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/src/nrc7292_sw_pkg/package/src/nrc
NRC7292_SITE_METHOD = local
NRC7292_LICENSE = LGPLv2.1/GPLv2 
#NRC7292_MODULES_MAKE_OPTS = CONFIG_DUMMY1 \
#			    CONFIG_DUMMY2=y

define KERNEL_MODULE_BUILD_CMDS
	$(MAKE) -C '$(@D)' LINUX_DIR='$(LINUX_DIR)'

endef

$(eval $(kernel-module))
$(eval $(generic-package))

