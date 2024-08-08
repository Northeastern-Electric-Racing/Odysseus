NRC_CLI_VERSION = v1.5
NRC_CLI_SITE = https://github.com/newracom/nrc7292_sw_pkg
NRC_CLI_SITE_METHOD = git
NRC_CLI_LICENSE = Proprietary

define NRC_CLI_BUILD_CMDS
   $(MAKE) $(TARGET_CONFIGURE_OPTS) all -C $(@D)/package/src/cli_app
endef

define NRC_CLI_INSTALL_TARGET_CMDS
   $(INSTALL) -D -m 0755 $(@D)/package/src/cli_app/cli_app $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
