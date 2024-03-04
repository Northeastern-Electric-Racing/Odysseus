################################################################################
#
# nerqt6svg
#
################################################################################

NERQT6SVG_VERSION = $(NERQT6_VERSION)
NERQT6SVG_SITE = $(NERQT6_SITE)
NERQT6SVG_SOURCE = qtsvg-$(NERQT6_SOURCE_TARBALL_PREFIX)-$(NERQT6SVG_VERSION).tar.xz
NERQT6SVG_INSTALL_STAGING = YES
NERQT6SVG_SUPPORTS_IN_SOURCE_BUILD = NO

NERQT6SVG_CMAKE_BACKEND = ninja

NERQT6SVG_LICENSE = \
	GPL-2.0+ or LGPL-3.0, \
	GPL-3.0 with exception (tools), \
	GFDL-1.3 (docs), \
	BSD-3-Clause

NERQT6SVG_LICENSE_FILES = \
	LICENSES/BSD-3-Clause.txt \
	LICENSES/GFDL-1.3-no-invariants-only.txt \
	LICENSES/GPL-2.0-only.txt \
	LICENSES/GPL-3.0-only.txt \
	LICENSES/LGPL-3.0-only.txt \
	LICENSES/Qt-GPL-exception-1.0.txt

NERQT6SVG_CONF_OPTS = \
	-DQT_HOST_PATH=$(HOST_DIR) \
	-DBUILD_WITH_PCH=OFF \
	-DQT_BUILD_EXAMPLES=OFF \
	-DQT_BUILD_TESTS=OFF

NERQT6SVG_DEPENDENCIES = \
	host-pkgconf \
	nerqt6base

$(eval $(cmake-package))
