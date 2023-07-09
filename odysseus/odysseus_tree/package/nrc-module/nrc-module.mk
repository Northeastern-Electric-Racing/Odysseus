MODNAME=NRC_MODULE

${MODNAME}_MODULE_VERSION = 1.0
${MODNAME}_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/src/nrc
${MODNAME}_SITE_METHOD = local
${MODNAME}_LICENSE = LGPLv2.1/GPLv2

$(eval $(kernel-module))
$(eval $(generic-package))

