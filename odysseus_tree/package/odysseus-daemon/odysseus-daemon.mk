ODYSSEUS_DAEMON_VERSION = 55d03e596fac6b8601d93fb996072c1973a4d89f
ODYSSEUS_DAEMON_SITE_METHOD = git
ODYSSEUS_DAEMON_SITE = https://github.com/Northeastern-Electric-Racing/Odysseus-Daemon
ODYSSEUS_DAEMON_DEPENDENCIES += openssl host-pkgconf udev

# all dependencies and support scripts are in the TPU overlay as this package is TPU specifc

$(eval $(cargo-package))
