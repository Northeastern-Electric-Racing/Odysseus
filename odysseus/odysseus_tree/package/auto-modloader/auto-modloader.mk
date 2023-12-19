AUTO_MODLOADER_VERSION = 1.0
AUTO_MODLOADER_SOURCE =

define AUTO_MODLOADER_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/auto-modloader/S04modules $(TARGET_DIR)/etc/init.d/S04modules
endef

$(eval $(generic-package))
