USBIP_AUTORECONF = YES
USBIP_CONF_OPTS = --without-tcp-wrappers
USBIP_DEPENDENCIES = linux udev

USBIP_SRC_DIR = $(LINUX_DIR)/tools/usb/usbip

# not best practice, but dont remove this line or a rsync infinite recursion would be triggered
USBIP_EXTRACT_DEPENDENCIES = linux


# overwrite autotools extraction infra
define USBIP_EXTRACT_CMDS
	# rip usbip from linux source to avoid double clone, put it where autotools expects
	rsync -au --chmod=u=rwX,go=rX $(RSYNC_VCS_EXCLUSIONS) $(USBIP_SRC_DIR)/ $(@D)
endef

define USBIP_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(USBIP_PKGDIR)/S09usbipd $(TARGET_DIR)/etc/init.d/S09usbipd
endef

$(eval $(autotools-package))

