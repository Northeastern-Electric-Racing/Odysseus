MICROCHIP_T1S_VERSION = 3.0.0
MICROCHIP_T1S_SOURCE_BASE = EVB-LAN8670-USB_Linux_Driver_3v0
MICROCHIP_T1S_SOURCE = $(MICROCHIP_T1S_SOURCE_BASE).zip
MICROCHIP_T1S_SITE = https://ww1.microchip.com/downloads/aemDocuments/documents/AIS/ProductDocuments/CodeExamples
MICROCHIP_T1S_LICENSE = LGPLv2.1/GPLv2

MICROCHIP_T1S_MODULE_SUBDIRS = "$(MICROCHIP_T1S_SOURCE_BASE)/lan867x-linux-driver-3v0/linux-v6.14-support/"
# set the makefile KDIR to buildroot kernel, as otherwise it will use host headers
MICROCHIP_T1S_MODULE_MAKE_OPTS = KDIR=$(LINUX_DIR)

define MICROCHIP_T1S_EXTRACT_CMDS
    $(UNZIP) $(MICROCHIP_T1S_DL_DIR)/$(MICROCHIP_T1S_SOURCE) -d $(@D)
endef


$(eval $(kernel-module))
$(eval $(generic-package))
