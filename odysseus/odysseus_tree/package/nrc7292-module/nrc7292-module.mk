MODNAME=NRC7292_MODULE

${MODNAME}_PROVIDER_PROVIDES = nrc-module
${MODNAME}_MODULE_VERSION = 1.5
${MODNAME}_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/nrc7292_sw_pkg/package/src/nrc
${MODNAME}_SITE_METHOD = local
${MODNAME}_LICENSE = LGPLv2.1/GPLv2

#${MODANME}_MODULE_SUBDIRS = ./package/src/nrc

#define ${MODNAME}_LINUX_CONFIG_FIXUPS
#   $(call KCONFIG_ENABLE_OPT, CONFIG_OBJTOOL)
#endef

define ${MODNAME}_LINUX_OBJTOOL_FIX
   make -C $(@D)/../linux-custom/tools/objtool
endef

${MODNAME}_PRE_BUILD_HOOKS += ${MODNAME}_LINUX_OBJTOOL_FIX

$(eval $(kernel-module))
$(eval $(generic-package))

