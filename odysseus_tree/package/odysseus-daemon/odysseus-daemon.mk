ODYSSEUS_DAEMON_VERSION = 97566ca4cfdab17dd96621a6ce5905a7200b85ee
ODYSSEUS_DAEMON_SITE_METHOD = git
ODYSSEUS_DAEMON_SITE = https://github.com/Northeastern-Electric-Racing/Odysseus-Daemon
ODYSSEUS_DAEMON_DEPENDENCIES += openssl host-pkgconf udev

# all dependencies and support scripts are in the TPU overlay as this package is TPU specifc

$(eval $(cargo-package))
