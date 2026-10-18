################################################################################
#
# nerlibzenoh-c
#
################################################################################

NERLIBZENOH_C_VERSION = 1.10.1 # ***
NERLIBZENOH_C_SITE = $(call github,eclipse-zenoh,zenoh-c,$(NERLIBZENOH_C_VERSION))
NERLIBZENOH_C_LICENSE = Apache-2.0 or EPL-2.0
NERLIBZENOH_C_LICENSE_FILES = LICENSE
NERLIBZENOH_C_INSTALL_STAGING = YES

ifeq ($(BR2_ENABLE_DEBUG),y)
NERLIBZENOH_C_LIB_LOCATION = $(@D)/target/$(RUSTC_TARGET_NAME)/debug
else
NERLIBZENOH_C_LIB_LOCATION = $(@D)/target/$(RUSTC_TARGET_NAME)/release
endif

define NERLIBZENOH_C_INSTALL_FILES
	$(INSTALL) -D -m 644 \
		$(NERLIBZENOH_C_LIB_LOCATION)/libzenohc.so \
		$(1)/usr/lib/libzenohc.so
endef

# This package does not provide any binaries or examples, and the
# cargo infra does not provide any possibility to disable the --bins
# option in cargo install step, we have to override the
# INSTALL_STAGING_CMDS and the INSTALL_TARGET_CMDS macros.

define NERLIBZENOH_C_INSTALL_TARGET_CMDS
	$(call NERLIBZENOH_C_INSTALL_FILES,$(TARGET_DIR))
endef

define NERLIBZENOH_C_INSTALL_STAGING_CMDS
	$(call NERLIBZENOH_C_INSTALL_FILES,$(STAGING_DIR))
	mkdir -p $(STAGING_DIR)/usr/include/
	cp -dpfr $(@D)/include/* $(STAGING_DIR)/usr/include/
endef

$(eval $(cargo-package))
