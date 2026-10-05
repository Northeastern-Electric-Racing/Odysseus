PYTHIA_BACKEND_VERSION = 5a8cc6b47afde7cf94a32b11a97ddeb862ae6c3a
PYTHIA_BACKEND_SITE_METHOD = git
PYTHIA_BACKEND_SITE = https://github.com/Northeastern-Electric-Racing/Pythia
PYTHIA_BACKEND_SUBDIR = pythia-backend
PYTHIA_BACKEND_DEPENDENCIES += sqlite host-pkgconf
# diesel links the target libsqlite3 via pkg-config
PYTHIA_BACKEND_CARGO_ENV = PKG_CONFIG_ALLOW_CROSS=1

define PYTHIA_BACKEND_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/pythia-backend/S95pythia-backend $(TARGET_DIR)/etc/init.d/S95pythia-backend
endef

$(eval $(cargo-package))
