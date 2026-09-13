PROBE_RS_VERSION = v0.32.0
PROBE_RS_SITE_METHOD = git
PROBE_RS_SITE = https://github.com/probe-rs/probe-rs
PROBE_RS_GIT_SUBMODULES = YES
PROBE_RS_DEPENDENCIES = host-rustc libusb udev
PROBE_RS_CARGO_BUILD_OPTS = -p probe-rs-tools --features remote
PROBE_RS_CARGO_INSTALL_OPTS = -p probe-rs-tools


define PROBE_RS_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/probe-rs/S96probe-rs $(TARGET_DIR)/etc/init.d/S96probe-rs
endef

$(eval $(cargo-package))
