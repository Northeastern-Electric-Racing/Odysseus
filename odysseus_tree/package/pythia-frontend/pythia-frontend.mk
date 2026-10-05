PYTHIA_FRONTEND_VERSION = 5a8cc6b47afde7cf94a32b11a97ddeb862ae6c3a
PYTHIA_FRONTEND_SITE_METHOD = git
PYTHIA_FRONTEND_SITE = https://github.com/Northeastern-Electric-Racing/Pythia
PYTHIA_FRONTEND_DEPENDENCIES += host-nodejs nginx

PYTHIA_FRONTEND_SRC = $(@D)/pythia-frontend
PYTHIA_FRONTEND_NPM_ENV = $(HOST_MAKE_ENV) CI=true NG_CLI_ANALYTICS=false \
	npm_config_cache=$(DL_DIR)/pythia-frontend/npm-cache

# npm fetches node_modules here, buildroot cannot vendor them at download time
define PYTHIA_FRONTEND_BUILD_CMDS
	cd $(PYTHIA_FRONTEND_SRC) && $(PYTHIA_FRONTEND_NPM_ENV) npm ci --no-audit --no-fund
	cd $(PYTHIA_FRONTEND_SRC) && $(PYTHIA_FRONTEND_NPM_ENV) npx ng build --configuration production
endef

define PYTHIA_FRONTEND_INSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/usr/share/pythia-frontend
	mkdir -p $(TARGET_DIR)/usr/share/pythia-frontend
	cp -r $(PYTHIA_FRONTEND_SRC)/dist/pythia-frontend/browser/. $(TARGET_DIR)/usr/share/pythia-frontend/
	$(INSTALL) -D -m 0644 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/pythia-frontend/pythia.conf $(TARGET_DIR)/etc/nginx/pythia.conf
endef

# installed without an S prefix so rcS does not start it at boot,
# and nginx's own init script is dropped since pythia is its only user
define PYTHIA_FRONTEND_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/pythia-frontend/pythia-frontend $(TARGET_DIR)/etc/init.d/pythia-frontend
	ln -sf /etc/init.d/pythia-frontend $(TARGET_DIR)/usr/bin/pythia-frontend
	rm -f $(TARGET_DIR)/etc/init.d/S50nginx
endef

$(eval $(generic-package))
