CALYPSO_VERSION = 14e484ca7c5d15273a44391f609aaa335094837d
CALYPSO_SITE_METHOD = git
CALYPSO_SITE = https://github.com/Northeastern-Electric-Racing/Calypso
CALYPSO_GIT_SUBMODULES = YES
CALYPSO_DEPENDENCIES += openssl

define CALYPSO_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/calypso/S76calypso $(TARGET_DIR)/etc/init.d/S76calypso
	$(SED) 's,^BROKER_IP=.*,BROKER_IP=$(BR2_PACKAGE_CALYPSO_BROKER_IP),' $(TARGET_DIR)/etc/init.d/S76calypso
endef

$(eval $(cargo-package))
