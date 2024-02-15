USBIP_AUTORECONF = YES
USBIP_CONF_OPTS = --without-tcp-wrappers
USBIP_DEPENDENCIES = linux udev

USBIP_SRC_DIR = $(wildcard \
  $(LINUX_DIR)/tools/usb/usbip \
  $(LINUX_DIR)/drivers/staging/usbip/userspace)

define USBIP_EXTRACT_CMDS
	rsync -au --chmod=u=rwX,go=rX $(RSYNC_VCS_EXCLUSIONS) $(USBIP_SRC_DIR)/ $(@D)
endef

define USBIP_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(USBIP_PKGDIR)/S09usbipd $(TARGET_DIR)/etc/init.d/S09usbipd
endef

$(eval $(autotools-package))

