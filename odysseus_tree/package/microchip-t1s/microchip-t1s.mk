MICROCHIP_T1S_PROVIDER_PROVIDES = nrc-module
# match upstream sw_pkg version
MICROCHIP_T1S_VERSION = 1ac663c2f62a2c88ced004d961885019ab2e304b
MICROCHIP_T1S_SITE = https://github.com/Northeastern-Electric-Racing/nrc7292_sw_pkg
MICROCHIP_T1S_SITE_METHOD = git
MICROCHIP_T1S_LICENSE = LGPLv2.1/GPLv2

MICROCHIP_T1S_MODULE_SUBDIRS = "package/src/nrc"
# set the makefile KDIR to buildroot kernel, as otherwise it will use host headers
MICROCHIP_T1S_MODULE_MAKE_OPTS = KDIR=$(LINUX_DIR)


$(eval $(kernel-module))
$(eval $(generic-package))
