MORSE_CLI_VERSION = $(MORSE_VERSION)
MORSE_CLI_SITE = https://github.com/MorseMicro/morse_cli
MORSE_CLI_SITE_METHOD = git
MORSE_CLI_GIT_SUBMODULES = YES
MORSE_CLI_LICENSE = GPLv2
MORSE_CLI_DEPENDENCIES = pkg-config libnl libusb

define MORSE_CLI_BUILD_CMDS
    $(MAKE) -C $(@D) CONFIG_MORSE_TRANS_NL80211=1 all
endef

define MORSE_CLI_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/morse_cli $(TARGET_DIR)/usr/bin
endef


$(eval $(generic-package))
