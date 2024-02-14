MQTTUI_VERSION = 0.19.0
MQTTUI_SITE = $(call github,EdJoPaTo,mqttui,v$(MQTTUI_VERSION))
MQTTUI_LICENSE = GPL-3.0+

$(eval $(cargo-package))
