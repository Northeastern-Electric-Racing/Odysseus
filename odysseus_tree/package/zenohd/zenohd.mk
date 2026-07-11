ZENOHD_VERSION = 1.9.0
ZENOHD_SITE_METHOD = git
ZENOHD_SITE = https://github.com/eclipse-zenoh/zenoh

define ZENOHD_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/zenohd/S76zenohd $(TARGET_DIR)/etc/init.d/S76zenohd
endef

$(eval $(cargo-package))
