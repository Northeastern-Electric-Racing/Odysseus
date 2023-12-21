NRC_INIT_EXTRA_VERSION = 0.1 
NRC_INIT_EXTRA_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/package/nrc-init-extra
NRC_INIT_EXTRA_SITE_METHOD = local

define NRC_INIT_EXTRA_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(@D)/S98nrc-init-extra $(TARGET_DIR)/etc/init.d/S98nrc-init-extra
endef

define NRC_INIT_EXTRA_INSTALL_TARGET_CMDS
   $(INSTALL) -D -m 0755 $(@D)/initialize-nrc-extra.sh $(TARGET_DIR)/usr/bin/initialize-nrc-extra
endef

$(eval $(generic-package))
