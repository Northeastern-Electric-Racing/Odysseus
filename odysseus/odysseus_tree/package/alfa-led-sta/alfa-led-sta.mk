PKGNAME=ALFA_LED_STA

${PKGNAME}_VERSION = 1.0
#${PKGNAME}_SOURCE = https://github.com/Northeastern-Electric-Racing/Siren
${PKGNAME}_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/package/alfa-led-sta
${PKGNAME}_SITE_METHOD = local

define ${PKGNAME}_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/nrc-led-sta.sh $(TARGET_DIR)/usr/bin/nrc-led-sta
endef

define ${PKGNAME}_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(@D)/S99alfa-led $(TARGET_DIR)/etc/init.d/S99alfa-led
endef

$(eval $(generic-package))
