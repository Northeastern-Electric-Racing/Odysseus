################################################################################
#
# nerqt6shadertools (NER: new package!)
#
################################################################################

NERQT6SHADERTOOLS_VERSION = $(NERQT6_VERSION)
NERQT6SHADERTOOLS_SITE = $(NERQT6_SITE)
NERQT6SHADERTOOLS_SOURCE = qtshadertools-$(NERQT6_SOURCE_TARBALL_PREFIX)-$(NERQT6SHADERTOOLS_VERSION).tar.xz
NERQT6SHADERTOOLS_INSTALL_STAGING = YES
NERQT6SHADERTOOLS_SUPPORTS_IN_SOURCE_BUILD = NO

NERQT6SHADERTOOLS_CMAKE_BACKEND = ninja

NERQT6SHADERTOOLS_LICENSE = \
	GPL-3.0-only WITH Qt-GPL-exception-1.0, \
	GPL-2.0-only or LGPL-3.0-only, \
	GFDL-1.3-no-invariants-only, \
	Apache-2.0 or MIT, \
	BSD-3-Clause, \
	BSD-2-Clause, \
	Apache-2.0, \
	GPL-3.0-or-later WITH Bison-Exception-2.2

NERQT6SHADERTOOLS_LICENSE_FILES = \
	LICENSES/BSD-3-Clause.txt \
	LICENSES/GFDL-1.3-no-invariants-only.txt \
	LICENSES/GPL-2.0-only.txt \
	LICENSES/GPL-3.0-only.txt \
	LICENSES/LGPL-3.0-only.txt \
	LICENSES/Qt-GPL-exception-1.0.txt \
	src/3rdparty/SPIRV-Cross/KHRONOS-LICENSE.txt \
	src/3rdparty/SPIRV-Cross/LICENSE \
	src/3rdparty/glslang/LICENSE.txt

NERQT6SHADERTOOLS_CONF_OPTS = \
	-DBUILD_WITH_PCH=OFF \
	-DQT_BUILD_EXAMPLES=OFF \
	-DQT_BUILD_TESTS=OFF

NERQT6SHADERTOOLS_DEPENDENCIES = \
	host-pkgconf \
	nerqt6base \
	host-nerqt6shadertools

HOST_NERQT6SHADERTOOLS_DEPENDENCIES = host-nerqt6base

$(eval $(cmake-package))
$(eval $(host-cmake-package))
