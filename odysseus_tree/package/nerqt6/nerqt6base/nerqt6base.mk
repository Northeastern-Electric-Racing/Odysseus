################################################################################
#
# nerqt6base (NER: from buildroot/package/qt6/qt6base/qt6base.mk)
#
################################################################################

NERQT6BASE_VERSION = $(NERQT6_VERSION)
NERQT6BASE_SITE = $(NERQT6_SITE)
NERQT6BASE_SOURCE = qtbase-$(NERQT6_SOURCE_TARBALL_PREFIX)-$(NERQT6BASE_VERSION).tar.xz

NERQT6BASE_CMAKE_BACKEND = ninja

NERQT6BASE_LICENSE = \
	GPL-2.0+ or LGPL-3.0, \
	GPL-3.0 with exception (tools), \
	GFDL-1.3 (docs), \
	Apache-2.0, \
	BSD-3-Clause, \
	BSL-1.0, \
	MIT

NERQT6BASE_LICENSE_FILES = \
	LICENSES/Apache-2.0.txt \
	LICENSES/BSD-3-Clause.txt \
	LICENSES/BSL-1.0.txt \
	LICENSES/GFDL-1.3-no-invariants-only.txt \
	LICENSES/GPL-2.0-only.txt \
	LICENSES/GPL-3.0-only.txt \
	LICENSES/LGPL-3.0-only.txt \
	LICENSES/MIT.txt \
	LICENSES/Qt-GPL-exception-1.0.txt

NERQT6BASE_DEPENDENCIES = \
	host-nerqt6base \
	double-conversion \
	libb2 \
	pcre2 \
	zlib
NERQT6BASE_INSTALL_STAGING = YES

NERQT6BASE_CONF_OPTS = \
	-DQT_HOST_PATH=$(HOST_DIR) \
	-DFEATURE_concurrent=OFF \
	-DFEATURE_xml=OFF \
	-DFEATURE_sql=OFF \
	-DFEATURE_testlib=OFF \
	-DFEATURE_network=OFF \
	-DFEATURE_dbus=OFF \
	-DFEATURE_icu=OFF \
	-DFEATURE_glib=OFF \
	-DFEATURE_system_doubleconversion=ON \
	-DFEATURE_system_pcre2=ON \
	-DFEATURE_system_zlib=ON \
	-DFEATURE_system_libb2=ON

# x86 optimization options. While we have a BR2_X86_CPU_HAS_AVX512, it
# is not clear yet how it maps to all the avx512* options of Qt, so we
# for now keeps them disabled.
NERQT6BASE_CONF_OPTS += \
	-DFEATURE_sse2=$(if $(BR2_X86_CPU_HAS_SSE2),ON,OFF) \
	-DFEATURE_sse3=$(if $(BR2_X86_CPU_HAS_SSE3),ON,OFF) \
	-DFEATURE_sse4_1=$(if $(BR2_X86_CPU_HAS_SSE4),ON,OFF) \
	-DFEATURE_sse4_2=$(if $(BR2_X86_CPU_HAS_SSE42),ON,OFF) \
	-DFEATURE_ssse3=$(if $(BR2_X86_CPU_HAS_SSSE3),ON,OFF) \
	-DFEATURE_avx=$(if $(BR2_X86_CPU_HAS_AVX),ON,OFF) \
	-DFEATURE_avx2=$(if $(BR2_X86_CPU_HAS_AVX2),ON,OFF) \
	-DFEATURE_avx512bw=OFF \
	-DFEATURE_avx512cd=OFF \
	-DFEATURE_avx512dq=OFF \
	-DFEATURE_avx512er=OFF \
	-DFEATURE_avx512f=OFF \
	-DFEATURE_avx512ifma=OFF \
	-DFEATURE_avx512pf=OFF \
	-DFEATURE_avx512vbmi=OFF \
	-DFEATURE_avx512vbmi2=OFF \
	-DFEATURE_avx512vl=OFF \
	-DFEATURE_vaes=OFF

HOST_NERQT6BASE_DEPENDENCIES = \
	host-double-conversion \
	host-libb2 \
	host-pcre2 \
	host-zlib
# NER: remove gui, network (see below)
HOST_NERQT6BASE_CONF_OPTS = \
	-DFEATURE_concurrent=OFF \
	-DFEATURE_xml=ON \
	-DFEATURE_sql=OFF \
	-DFEATURE_testlib=OFF \
	-DFEATURE_dbus=OFF \
	-DFEATURE_icu=OFF \
	-DFEATURE_glib=OFF \
	-DFEATURE_system_doubleconversion=ON \
	-DFEATURE_system_libb2=ON \
	-DFEATURE_system_pcre2=ON \
	-DFEATURE_system_zlib=ON

# NER: This is needed to build the qsb binary.from host-qt6shadertools
ifeq ($(BR2_PACKAGE_HOST_NERQT6BASE_GUI),y)
HOST_NERQT6BASE_CONF_OPTS += \
	-DFEATURE_gui=ON \
	-DFEATURE_vulkan=OFF \
	-DINPUT_opengl=no \
	-DFEATURE_linuxfb=ON \
	-DFEATURE_eglfs=OFF \
	-DFEATURE_opengl=OFF \
	-DINPUT_opengl=no
else
HOST_NERQT6BASE_CONF_OPTS += -DFEATURE_gui=OFF
endif

# NER: This is needed to build the network support required by qt6declarative for qmlprofiler
ifeq ($(BR2_PACKAGE_HOST_NERQT6BASE_NETWORK),y)
HOST_NERQT6BASE_CONF_OPTS += -DFEATURE_network=ON
else
HOST_NERQT6BASE_CONF_OPTS += -DFEATURE_network=OFF
endif

# Conditional blocks below are ordered by alphabetic ordering of the
# BR2_PACKAGE_* option.

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_libudev=ON
NERQT6BASE_DEPENDENCIES += udev
else
NERQT6BASE_CONF_OPTS += -DFEATURE_libudev=OFF
endif

ifeq ($(BR2_PACKAGE_ICU),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_icu=ON
NERQT6BASE_DEPENDENCIES += icu
else
NERQT6BASE_CONF_OPTS += -DFEATURE_icu=OFF
endif

ifeq ($(BR2_PACKAGE_LIBGLIB2),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_glib=ON
NERQT6BASE_DEPENDENCIES += libglib2
else
NERQT6BASE_CONF_OPTS += -DFEATURE_glib=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_GUI),y)
NERQT6BASE_CONF_OPTS += \
	-DFEATURE_gui=ON \
	-DFEATURE_freetype=ON \
	-DFEATURE_vulkan=OFF
NERQT6BASE_DEPENDENCIES += freetype

ifeq ($(BR2_PACKAGE_NERQT6BASE_VULKAN),y)
NERQT6BASE_DEPENDENCIES   += vulkan-headers vulkan-loader
NERQT6BASE_CONFIGURE_OPTS += -DFEATURE_vulkan=ON
else
NERQT6BASE_CONFIGURE_OPTS += -DFEATURE_vulkan=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_LINUXFB),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_linuxfb=ON
else
NERQT6BASE_CONF_OPTS += -DFEATURE_linuxfb=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_XCB),y)
NERQT6BASE_CONF_OPTS += \
	-DFEATURE_xcb=ON \
	-DFEATURE_xcb_xlib=ON \
	-DFEATURE_xkbcommon=ON \
	-DFEATURE_xkbcommon_x11=ON
NERQT6BASE_DEPENDENCIES += \
	libxcb \
	libxkbcommon \
	xcb-util-wm \
	xcb-util-image \
	xcb-util-keysyms \
	xcb-util-renderutil \
	xlib_libX11
else
NERQT6BASE_CONF_OPTS += -DFEATURE_xcb=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_HARFBUZZ),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_harfbuzz=ON
ifeq ($(BR2_TOOLCHAIN_HAS_SYNC_4),y)
# system harfbuzz in case __sync for 4 bytes is supported
NERQT6BASE_CONF_OPTS += -DQT_USE_BUNDLED_BundledHarfbuzz=OFF
NERQT6BASE_DEPENDENCIES += harfbuzz
else #BR2_TOOLCHAIN_HAS_SYNC_4
# qt harfbuzz otherwise (using QAtomic instead)
NERQT6BASE_CONF_OPTS += -DQT_USE_BUNDLED_BundledHarfbuzz=ON
NERQT6BASE_LICENSE += , MIT (harfbuzz)
NERQT6BASE_LICENSE_FILES += src/3rdparty/harfbuzz-ng/COPYING
endif
else
NERQT6BASE_CONF_OPTS += -DFEATURE_harfbuzz=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_PNG),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_png=ON -DFEATURE_system_png=ON
NERQT6BASE_DEPENDENCIES += libpng
else
NERQT6BASE_CONF_OPTS += -DFEATURE_png=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_GIF),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_gif=ON
else
NERQT6BASE_CONF_OPTS += -DFEATURE_gif=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_JPEG),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_jpeg=ON
NERQT6BASE_DEPENDENCIES += jpeg
else
NERQT6BASE_CONF_OPTS += -DFEATURE_jpeg=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_PRINTSUPPORT),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_printsupport=ON
ifeq ($(BR2_PACKAGE_CUPS),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_cups=ON
NERQT6BASE_DEPENDENCIES += cups
else
NERQT6BASE_CONF_OPTS += -DFEATURE_cups=OFF
endif
else
NERQT6BASE_CONF_OPTS += -DFEATURE_printsupport=OFF
endif

ifeq ($(BR2_PACKAGE_LIBDRM),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_kms=ON
NERQT6BASE_DEPENDENCIES += libdrm
else
NERQT6BASE_CONF_OPTS += -DFEATURE_kms=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_FONTCONFIG),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_fontconfig=ON
NERQT6BASE_DEPENDENCIES += fontconfig
else
NERQT6BASE_CONF_OPTS += -DFEATURE_fontconfig=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_WIDGETS),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_widgets=ON

# only enable gtk support if libgtk3 X11 backend is enabled
ifeq ($(BR2_PACKAGE_LIBGTK3)$(BR2_PACKAGE_LIBGTK3_X11),yy)
NERQT6BASE_CONF_OPTS += -DFEATURE_gtk3=ON
NERQT6BASE_DEPENDENCIES += libgtk3
else
NERQT6BASE_CONF_OPTS += -DFEATURE_gtk3=OFF
endif

else
NERQT6BASE_CONF_OPTS += -DFEATURE_widgets=OFF
endif

ifeq ($(BR2_PACKAGE_LIBINPUT),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_libinput=ON
NERQT6BASE_DEPENDENCIES += libinput
else
NERQT6BASE_CONF_OPTS += -DFEATURE_libinput=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_TSLIB),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_tslib=ON
NERQT6BASE_DEPENDENCIES += tslib
else
NERQT6BASE_CONF_OPTS += -DFEATURE_tslib=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_EGLFS),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_egl=ON -DFEATURE_eglfs=ON

# NER: special test option to make qt recognize proper RPI gpu support
ifeq ($(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_VC4),y)
NERQT6BASE_CONF_OPTS += -DTEST_egl_brcm=ON
else ifeq ($(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_V3D),y)
NERQT6BASE_CONF_OPTS += -DTEST_egl_brcm=ON
endif

NERQT6BASE_DEPENDENCIES += libegl libgbm
else
NERQT6BASE_CONF_OPTS += -DFEATURE_eglfs=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_OPENGL_DESKTOP),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_opengl=ON -DFEATURE_opengl_desktop=ON
NERQT6BASE_DEPENDENCIES += libgl
else ifeq ($(BR2_PACKAGE_NERQT6BASE_OPENGL_ES2),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_opengl=ON -DFEATURE_opengles2=ON
NERQT6BASE_DEPENDENCIES += libgles
else
NERQT6BASE_CONF_OPTS += -DFEATURE_opengl=OFF -DINPUT_opengl=no
endif

else
NERQT6BASE_CONF_OPTS += -DFEATURE_gui=OFF
endif

NERQT6BASE_DEFAULT_QPA = $(call qstrip,$(BR2_PACKAGE_NERQT6BASE_DEFAULT_QPA))
NERQT6BASE_CONF_OPTS += $(if $(NERQT6BASE_DEFAULT_QPA),-DQT_QPA_DEFAULT_PLATFORM=$(NERQT6BASE_DEFAULT_QPA))

ifeq ($(BR2_PACKAGE_OPENSSL),y)
NERQT6BASE_CONF_OPTS += -DINPUT_openssl=yes
NERQT6BASE_DEPENDENCIES += openssl
else
NERQT6BASE_CONF_OPTS += -DINPUT_openssl=no
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_CONCURRENT),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_concurrent=ON
else
NERQT6BASE_CONF_OPTS += -DFEATURE_concurrent=OFF
endif

# We need host-qt6base with D-Bus support, otherwise: "the tool
# "Qt6::qdbuscpp2xml" was not found in the Qt6DBusTools package."
ifeq ($(BR2_PACKAGE_NERQT6BASE_DBUS),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_dbus=ON -DINPUT_dbus=linked
NERQT6BASE_DEPENDENCIES += dbus
HOST_NERQT6BASE_CONF_OPTS += -DFEATURE_dbus=ON
HOST_NERQT6BASE_DEPENDENCIES += host-dbus
else
NERQT6BASE_CONF_OPTS += -DFEATURE_dbus=OFF
HOST_NERQT6BASE_CONF_OPTS += -DFEATURE_dbus=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_NETWORK),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_network=ON
else
NERQT6BASE_CONF_OPTS += -DFEATURE_network=OFF
endif

# Qt6 SQL Plugins
ifeq ($(BR2_PACKAGE_NERQT6BASE_SQL),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_sql=ON
NERQT6BASE_CONF_OPTS += -DFEATURE_sql_db2=OFF -DFEATURE_sql_ibase=OFF -DFEATURE_sql_oci=OFF -DFEATURE_sql_odbc=OFF

ifeq ($(BR2_PACKAGE_NERQT6BASE_MYSQL),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_sql_mysql=ON
NERQT6BASE_DEPENDENCIES += mariadb
else
NERQT6BASE_CONF_OPTS += -DFEATURE_sql_mysql=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_PSQL),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_sql_psql=ON
NERQT6BASE_DEPENDENCIES += postgresql
else
NERQT6BASE_CONF_OPTS += -DFEATURE_sql_psql=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_SQLITE),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_sql_sqlite=ON -DFEATURE_system_sqlite=ON
NERQT6BASE_DEPENDENCIES += sqlite
else
NERQT6BASE_CONF_OPTS += -DFEATURE_sql_sqlite=OFF
endif

else
NERQT6BASE_CONF_OPTS += -DFEATURE_sql=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_SYSLOG),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_syslog=ON
else
NERQT6BASE_CONF_OPTS += -DFEATURE_syslog=OFF
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_journald=ON
NERQT6BASE_DEPENDENCIES += systemd
else
NERQT6BASE_CONF_OPTS += -DFEATURE_journald=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_TEST),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_testlib=ON
else
NERQT6BASE_CONF_OPTS += -DFEATURE_testlib=OFF
endif

ifeq ($(BR2_PACKAGE_NERQT6BASE_XML),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_xml=ON
else
NERQT6BASE_CONF_OPTS += -DFEATURE_xml=OFF
endif

ifeq ($(BR2_PACKAGE_ZSTD),y)
NERQT6BASE_CONF_OPTS += -DFEATURE_zstd=ON
NERQT6BASE_DEPENDENCIES += zstd
else
NERQT6BASE_CONF_OPTS += -DFEATURE_zstd=OFF
endif

$(eval $(cmake-package))
$(eval $(host-cmake-package))
