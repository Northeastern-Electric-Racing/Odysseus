# must use later version then stable due to build issue with log_err function.
# Fix upon next nanomq release, as the build system is somewhat complicated and often changes
NANOMQ_VERSION = 0.21.1
NANOMQ_SITE_METHOD = git
NANOMQ_SITE = https://github.com/nanomq/nanomq
NANOMQ_GIT_SUBMODULES = YES
NANOMQ_GIT_LFS = YES
NANOMQ_LICENSE = MIT
# Note: this doesn't seem to be in use despite setting it?
NANOMQ_CMAKE_BACKEND = ninja
# so it uses a build subdirectory
NANOMQ_SUPPORTS_IN_SOURCE_BUILD = NO
NANOMQ_INSTALL_STAGING = YES

define NANOMQ_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_ODY_TREE_PATH)/package/nanomq/S75nanomq $(TARGET_DIR)/etc/init.d/S75nanomq
endef

ifeq ($(BR2_PACKAGE_NANOMQ_PLUGIN),y)
NANOMQ_CONF_OPTS += -DENABLE_PLUGIN=ON

define NANOMQ_PLUGIN_INSTALLATION
	$(foreach plugin,$(call qstrip,$(BR2_PACKAGE_NANOMQ_PLUGIN_LIST)), \
                $(TARGET_CC) $(NANOMQ_CFLAGS) -I$(STAGING_DIR)/usr/include/nanomq $(plugin) -fPIC -shared -o $(@D)/$(notdir $(basename $(plugin))).so
	)
        
	$(INSTALL) -d $(TARGET_DIR)/usr/lib/nanomq/
	$(foreach plugin,$(call qstrip,$(BR2_PACKAGE_NANOMQ_PLUGIN_LIST)), \
		$(info, "Installing $(plugin)!") \
                $(INSTALL) -D -m 0755 $(@D)/$(notdir $(basename $(plugin))).so $(TARGET_DIR)/usr/lib/nanomq/
                
        )
endef

NANOMQ_POST_INSTALL_TARGET_HOOKS += NANOMQ_PLUGIN_INSTALLATION

endif

ifeq ($(BR2_PACKAGE_NANOMQ_QUIC), y)
NANOMQ_CONF_OPTS += -DNNG_ENABLE_QUIC=ON
# So cmake doesn't search sysroot for the msquic.h header
NANOMQ_CONF_OPTS += -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=NEVER
# This is all for the QUIC OpenSSL to correctly ID the target arch as it uses custom perl configuration to prepare makefile
# Must remove trailing hyphen
# See https://github.com/microsoft/msquic/blob/93ea72460fd6d7127d8dcfcc7a8b7e2e2acc914b/submodules/CMakeLists.txt#L228
NANOMQ_PRIVATE_ARCH=arm64
$(info Using this toolchain for openssl module-> $(notdir $(TARGET_CROSS:-=)))
$(warning Using $(NANOMQ_PRIVATE_ARCH) for openssl module! Must change via edit!:)
NANOMQ_CONF_OPTS += -DONEBRANCH=YES -DCMAKE_TARGET_ARCHITECTURE=$(NANOMQ_PRIVATE_ARCH) -DGNU_MACHINE=$(notdir $(TARGET_CROSS:-=)) -DFLOAT_ABI_SUFFIX=""
# since nanomq expects ./build for the cmake dir, but buildroot uses ./buildroot-build, symlink them before doing anything
define NANOMQ_OPENSSL_FIXUP
	ln -s $(@D)/buildroot-build $(@D)/build
endef

NANOMQ_PRE_CONFIGURE_HOOKS += NANOMQ_OPENSSL_FIXUP
endif

ifeq ($(BR2_PACKAGE_NANOMQ_AWS_BRIDGE), y)
NANOMQ_CONF_OPTS += -DENABLE_AWS_BRIDGE=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_TLS), y)
NANOMQ_DEPENDENCIES += mbedTLS 
NANOMQ_CONF_OPTS += -DNNG_ENABLE_TLS=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_CLIENT_SUITE), n)
NANOMQ_CONF_OPTS += -DBUILD_CLIENT=OFF
endif

ifeq ($(BR2_PACKAGE_NANOMQ_ZMQ_GATEWAY), y)
NANOMQ_CONF_OPTS += -DBUILD_ZMQ_GATEWAY=ON	
endif

ifeq ($(BR2_PACKAGE_NANOMQ_VSOMEIP_GATEWAY), y)
NANOMQ_CONF_OPTS += -DBUILD_VSOMEIP_GATEWAY=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_NNG_PROXY), y)
NANOMQ_CONF_OPTS += -DBUILD_NNG_PROXY=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_BENCH), y)
NANOMQ_CONF_OPTS += -DBUILD_BENCH=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_JWT), y)
NANOMQ_CONF_OPTS += -DENABLE_JWT=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_SQLITE), y)
NANOMQ_CONF_OPTS += -DNNG_ENABLE_SQLITE=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_STATICLIB), y)
NANOMQ_CONF_OPTS += -DBUILD_WITH_STATIC_LIBS=ON
NANOMQ_CONF_OPTS += -DBUILD_STATIC_LIB=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_DISABLE_SHAREDLIB), y)
NANOMQ_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF
endif

ifeq ($(BR2_PACKAGE_NANOMQ_DEBUG), y)
NANOMQ_CONF_OPTS += -DDEBUG=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_DASAN), y)
NANOMQ_CONF_OPTS += -DASAN=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_LOG), n)
NANOMQ_CONF_OPTS += -DNOLOG=1
endif

ifeq ($(BR2_PACKAGE_NANOMQ_TRACE), y)
NANOMQ_CONF_OPTS += -DDEBUG_TRACE=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_RULE_ENGINE), y)
NANOMQ_CONF_OPTS += -DENABLE_RULE_ENGINE=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_MYSQL), y)
NANOMQ_CONF_OPTS += -DENABLE_MYSQL=ON
endif

ifeq ($(BR2_PACKAGE_NANOMQ_ACL), n)
NANOMQ_CONF_OPTS += -DENABLE_ACL=OFF
endif

ifeq ($(BR2_PACKAGE_NANOMQ_SYSLONG), n)
NANOMQ_CONF_OPTS += -DENABLE_SYSLOG=OFF
endif

ifeq ($(BR2_PACKAGE_NANOMQ_TESTS), y)
NANOMQ_CONF_OPTS += -DNANOMQ_TESTS=ON
endif

$(eval $(cmake-package))
