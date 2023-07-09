NRC7292_MODULE_VERSION = 1.0
NRC7292_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/src/cli_app
NRC7292_SITE_METHOD = local
NRC7292_DEPENDENCIES = ncurses

define ${PKGNAME}_BUILD_CMDS
   $(MAKE) $(TARGET_CONFIGURE_OPTS) all -C $(@D)
endef
define ${PKGNAME}_INSTALL_TARGET_CMDS
   $(INSTALL) -D -m 0755 $(@D)/cli_app $(TARGET_DIR)/usr/bin
endef
${PKGNAME}_LICENSE = Proprietary

$(eval $(generic-package))
