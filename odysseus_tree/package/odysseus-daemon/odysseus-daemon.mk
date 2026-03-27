ODYSSEUS_DAEMON_VERSION = 40adc7998612350beb174efc442e65da7f0f51a0
ODYSSEUS_DAEMON_SITE_METHOD = git
ODYSSEUS_DAEMON_SITE = https://github.com/Northeastern-Electric-Racing/Odysseus-Daemon
ODYSSEUS_DAEMON_DEPENDENCIES += openssl host-pkgconf udev

# all dependencies and support scripts are in the TPU overlay as this package is TPU specifc

$(eval $(cargo-package))
