ALFA_LED_STA_VERSION = 1.0
#ALFA_LED_STA_SOURCE = https://github.com/Northeastern-Electric-Racing/Siren
ALFA_LED_STA_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/package/alfa-led-sta
ALFA_LED_STA_SITE_METHOD = local

define ALFA_LED_STA_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/alfa-led-sta.sh $(TARGET_DIR)/usr/bin/alfa-led-sta
endef

define ALFA_LED_STA_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(@D)/S99alfa-led $(TARGET_DIR)/etc/init.d/S99alfa-led
endef

$(eval $(generic-package))
