NRC_USERSPACE_STA_VERSION = 0.1 
NRC_USERSPACE_STA_SOURCE =

define NRC_USERSPACE_STA_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/nrc-userspace-sta/S98nrc-init-extra $(TARGET_DIR)/etc/init.d/S98nrc-init-extra
endef

define NRC_USERSPACE_STA_INSTALL_TARGET_CMDS
   $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/nrc-userspace-sta/initialize-nrc-extra.sh $(TARGET_DIR)/usr/bin/initialize-nrc-extra
endef

$(eval $(generic-package))
