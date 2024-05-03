################################################################################
#
# python-gmqtt
#
################################################################################

PYTHON_GMQTT_VERSION = 0.6.14
PYTHON_GMQTT_SOURCE = gmqtt-$(PYTHON_GMQTT_VERSION).tar.gz
PYTHON_GMQTT_SITE = https://files.pythonhosted.org/packages/da/99/d7bc04b13fba3a83d06e9b3f30b51d2b867917fb0db4a436f7a1995b1ab8
PYTHON_GMQTT_SETUP_TYPE = setuptools
PYTHON_GMQTT_LICENSE = MIT
PYTHON_GMQTT_LICENSE_FILES = LICENSE

$(eval $(python-package))
