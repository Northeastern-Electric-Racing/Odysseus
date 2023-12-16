NRC_CLI_VERSION = 1.5
NRC_CLI_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7292_sw_pkg/package/src/cli_app
NRC_CLI_SITE_METHOD = local
#NRC7292_DEPENDENCIES = ncurses
NRC_CLI_LICENSE = Proprietary



define NRC_CLI_BUILD_CMDS
   $(MAKE) $(TARGET_CONFIGURE_OPTS) all -C $(@D)
endef
define NRC_CLI_INSTALL_TARGET_CMDS
   $(INSTALL) -D -m 0755 $(@D)/cli_app $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
