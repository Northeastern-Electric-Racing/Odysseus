CALYPSO_VERSION = 3f3a12834838448458cc47a21b904eca80daf3d4
CALYPSO_SITE_METHOD = git
CALYPSO_SITE = https://github.com/Northeastern-Electric-Racing/Calypso
CALYPSO_DEPENDENCIES += openssl

define CALYPSO_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/calypso/S76calypso $(TARGET_DIR)/etc/init.d/S76calypso
endef

$(eval $(cargo-package))
