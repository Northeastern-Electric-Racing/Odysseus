NERO2_VERSION = 1.0
NERO2_SITE = $(BR2_EXTERNAL_ODY_TREE_PATH)/sources/Nero-2.0/NERODevelopment
NERO2_SITE_METHOD = local
NERO2_CMAKE_BACKEND = ninja
NERO2_DEPENDENCIES += nerqt6base nerqt6declarative nerqt6mqtt nerqt6grpc nerqt6core5compat

define NERO2_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/nero2/S99nero2 $(TARGET_DIR)/etc/init.d/S99nero2
endef


$(eval $(cmake-package))
