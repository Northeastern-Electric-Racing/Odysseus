################################################################################
#
# qt6 (from buildroot/package/qt6/qt6.mk)
#
################################################################################

# NER: version changed
NERQT6_VERSION_MAJOR = 6.5
NERQT6_VERSION = $(NERQT6_VERSION_MAJOR).3
NERQT6_SOURCE_TARBALL_PREFIX = everywhere-src
NERQT6_SITE = https://download.qt.io/archive/qt/$(NERQT6_VERSION_MAJOR)/$(NERQT6_VERSION)/submodules

# NER: added external path
include $(sort $(wildcard $(BR2_EXTERNAL_ODY_TREE_PATH)/package/nerqt6/*/*.mk))
