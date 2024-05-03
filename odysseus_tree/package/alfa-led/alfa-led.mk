ALFA_LED_VERSION = 1.0
ALFA_LED_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/package/alfa-led
ALFA_LED_SITE_METHOD = local

ALFA_LED_SCRIPT_PATH = $(@D)/alfa-led-sta.sh

ifeq ($(BR2_PACKAGE_ALFA_LED_AP), y)
ALFA_LED_SCRIPT_PATH = $(@D)/alfa-led-ap.sh
endif

define ALFA_LED_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(ALFA_LED_SCRIPT_PATH) $(TARGET_DIR)/usr/bin/alfa-led
endef

define ALFA_LED_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(@D)/S99alfa-led $(TARGET_DIR)/etc/init.d/S99alfa-led
endef

$(eval $(generic-package))
