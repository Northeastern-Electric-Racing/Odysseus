MORSE_CLI_VERSION = 1.17.8
MORSE_CLI_SITE = https://github.com/MorseMicro/morse_cli
MORSE_CLI_SITE_METHOD = git
MORSE_CLI_GIT_SUBMODULES = YES
MORSE_CLI_LICENSE = GPLv2
MORSE_CLI_DEPENDENCIES = libnl libusb

define MORSE_CLI_BUILD_CMDS

    $(MAKE) -C $(@D) CC=$(TARGET_CC) CFLAGS="$(TARGET_CLFAGS) -I$(STAGING_DIR)/usr/include/libnl3 -I$(STAGING_DIR)/usr/include/libusb-1.0" LD=$(TARGET_LD) LDFLAGS="$(TARGET_LDFLAGS) -L $(STAGING_DIR)/usr/lib" CONFIG_MORSE_TRANS_NL80211=1 V=1 all
endef

define MORSE_CLI_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/morse_cli $(TARGET_DIR)/usr/bin
endef


$(eval $(generic-package))
