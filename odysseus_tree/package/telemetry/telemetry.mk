TPU_TELEMETRY_VERSON = 0.1
TPU_TELEMETRY_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/telemetry
TPU_TELEMETRY_SITE_METHOD = local


define TPU_TELEMETRY_INSTALL_TARGET_CMDS
    $(INSTALL) -d $(TARGET_DIR)/usr/lib/telemetry
    cp -r $(@D)/* $(TARGET_DIR)/usr/lib/telemetry
endef

$(eval $(generic-package))
