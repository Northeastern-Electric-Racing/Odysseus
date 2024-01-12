CALYPSO_VERSION = 20ae5443e5e6626fd4bda12131d9e496b9faf34b
CALYPSO_SITE_METHOD = git
CALYPSO_SITE = https://github.com/Northeastern-Electric-Racing/Calypso

define CALYPSO_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/calypso/S71calypso $(TARGET_DIR)/etc/init.d/S71calypso
endef

$(eval $(cargo-package))
