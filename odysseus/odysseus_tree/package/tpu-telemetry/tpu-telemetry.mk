TPU_TELEMETRY_VERSON = 0.1
TPU_TELEMETRY_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/tpu_telemetry
TPU_TELEMETRY_SITE_METHOD = local
TPU_TELEMETRY_SETUP_TYPE = setuptools

define TPU_TELEMETRY_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(TPU_TELEMETRY_PKGDIR)/S98tpu-telemetry $(TARGET_DIR)/etc/init.d/S98tpu-telemetry
endef

$(eval $(python-package))
