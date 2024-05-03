TPU_TELEMETRY_VERSON = 0.1
TPU_TELEMETRY_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/tpu_telemetry
TPU_TELEMETRY_SITE_METHOD = local

define TPU_TELEMETRY_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(TPU_TELEMETRY_PKGDIR)S98tpu-telemetry $(TARGET_DIR)/etc/init.d/S98tpu-telemetry
endef

define TPU_TELEMETRY_INSTALL_TARGET_CMDS
    $(INSTALL) -d $(TARGET_DIR)/usr/lib/tpu-telemetry/telemetry
    cp -r $(@D)/telemetry/* $(TARGET_DIR)/usr/lib/tpu-telemetry/telemetry
    $(INSTALL) -D -m 0755 $(TPU_TELEMETRY_PKGDIR)tpu-telemetry.sh $(TARGET_DIR)/usr/bin/tpu-telemetry
endef

$(eval $(generic-package))
