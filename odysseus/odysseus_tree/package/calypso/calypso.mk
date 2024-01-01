CALYPSO_VERSION = 0.1.0
CALYPSO_SITE_METHOD = git
CALYPSO_SITE = https://github.com/Northeastern-Electric-Racing/Calypso

define CALYPSO_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/calypso/S74calypso $(TARGET_DIR)/etc/init.d/S74calypso
endef

$(eval $(cargo-package))
