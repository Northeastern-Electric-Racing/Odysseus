################################################################################
#
# nerqt6grpc (NER: new package!)
#
################################################################################

NERQT6GRPC_VERSION = $(NERQT6_VERSION)
NERQT6GRPC_SITE = $(NERQT6_SITE)
NERQT6GRPC_SOURCE = qtgrpc-$(NERQT6_SOURCE_TARBALL_PREFIX)-$(NERQT6GRPC_VERSION).tar.xz
NERQT6GRPC_INSTALL_STAGING = YES
NERQT6GRPC_SUPPORTS_IN_SOURCE_BUILD = NO

NERQT6GRPC_CMAKE_BACKEND = ninja

NERQT6GRPC_LICENSE = \
	GPL-3.0-only WITH Qt-GPL-exception-1.0, \
	GPL-2.0-only or LGPL-3.0-only, \
	GFDL-1.3-no-invariants-only, \
	Apache-2.0 or MIT, \
	BSD-3-Clause, \
	BSD-2-Clause, \
	Apache-2.0, \
	GPL-3.0-or-later WITH Bison-Exception-2.2

NERQT6GRPC_LICENSE_FILES = \
	LICENSES/BSD-3-Clause.txt \
	LICENSES/GFDL-1.3-no-invariants-only.txt \
	LICENSES/GPL-2.0-only.txt \
	LICENSES/GPL-3.0-only.txt \
	LICENSES/LGPL-3.0-only.txt \
	LICENSES/Qt-GPL-exception-1.0.txt \
	src/3rdparty/SPIRV-Cross/KHRONOS-LICENSE.txt \
	src/3rdparty/SPIRV-Cross/LICENSE \
	src/3rdparty/glslang/LICENSE.txt

NERQT6GRPC_CONF_OPTS = \
	-DBUILD_WITH_PCH=OFF \
	-DQT_BUILD_EXAMPLES=OFF \
	-DQT_BUILD_TESTS=OFF

NERQT6GRPC_DEPENDENCIES = \
	host-pkgconf \
	nerqt6base \
	host-nerqt6grpc \
	
HOST_NERQT6GRPC_DEPENDENCIES = host-nerqt6base host-protobuf

$(eval $(cmake-package))
$(eval $(host-cmake-package))
