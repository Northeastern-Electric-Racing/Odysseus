AJAX_VERSION = cd5a674dbfd578c5aeff391d2e67dd7ff2ba9f5c
AJAX_SITE_METHOD = git
AJAX_SITE = https://github.com/Northeastern-Electric-Racing/Ajax
AJAX_GIT_SUBMODULES = YES

define AJAX_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/ajax/S77ajax $(TARGET_DIR)/etc/init.d/S77ajax
endef

$(eval $(cargo-package))
