PKGNAME = nrc-cli
#_PKGNAME = cli_app

${PKGNAME}_VERSION = 1.5
${PKGNAME}_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7292_sw_pkg/src/cli_app
${PKGNAME}_SITE_METHOD = local
#NRC7292_DEPENDENCIES = ncurses
${PKGNAME}_LICENSE = Proprietary



define ${PKGNAME}_BUILD_CMDS
   $(MAKE) $(TARGET_CONFIGURE_OPTS) all -C $(@D)
endef
define ${PKGNAME}_INSTALL_TARGET_CMDS
   $(INSTALL) -D -m 0755 $(@D)/cli_app $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
