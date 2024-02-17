################################################################################
#
# ifenslave
#
################################################################################

NERIFENSLAVE_VERSION = debian/2.14
NERIFENSLAVE_SITE_METHOD = git
NERIFENSLAVE_SITE = https://salsa.debian.org/debian/ifenslave
NERIFENSLAVE_LICENSE = GPL-3.0+
NERIFENSLAVE_LICENSE_FILES = debian/copyright
NERIFENSLAVE_DEPENDENCIES = ifupdown-scripts

# install ifup scripts

define NERIFENSLAVE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/debian/ifenslave.if-pre-up $(TARGET_DIR)/etc/network/if-pre-up.d/
	$(INSTALL) -D -m 0755 $(@D)/debian/ifenslave.if-pre-up $(TARGET_DIR)/etc/network/if-up.d/
	$(INSTALL) -D -m 0755 $(@D)/debian/ifenslave.if-pre-up $(TARGET_DIR)/etc/network/if-post-down.d/
endef

$(eval $(generic-package))
