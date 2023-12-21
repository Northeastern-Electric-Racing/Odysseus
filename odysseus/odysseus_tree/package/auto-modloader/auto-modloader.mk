AUTO_MODLOADER_VERSION = 1.0
AUTO_MODLOADER_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/package/auto-modloader
AUTO_MODLOADER_SITE_METHOD = local

define AUTO_MODLOADER_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(@D)/S04modules $(TARGET_DIR)/etc/init.d/S04modules
endef

$(eval $(generic-package))
