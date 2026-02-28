TPU_TELEMETRY_VERSON = 0.1
TPU_TELEMETRY_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/base_telemetry
TPU_TELEMETRY_SITE_METHOD = local

define TPU_TELEMETRY_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(TPU_TELEMETRY_PKGDIR)/S98base-telemetry $(TARGET_DIR)/etc/init.d/S98base-telemetry
endef

define TPU_TELEMETRY_INSTALL_TARGET_CMDS
    $(INSTALL) -d $(TARGET_DIR)/usr/lib/base-telemetry/
    cp -r $(@D)/* $(TARGET_DIR)/usr/lib/base-telemetry/
    $(INSTALL) -D -m 0755 $(TPU_TELEMETRY_PKGDIR)/base-telemetry.sh $(TARGET_DIR)/usr/bin/base-telemetry
endef

$(eval $(generic-package))
