ODYSSEUS_DAEMON_VERSION = cc7b0c20be991c83d4f238386a9bdf5d2ee12bf6
ODYSSEUS_DAEMON_SITE_METHOD = git
ODYSSEUS_DAEMON_SITE = https://github.com/Northeastern-Electric-Racing/Odysseus-Daemon
ODYSSEUS_DAEMON_DEPENDENCIES += openssl

# all dependencies and support scripts are in the TPU overlay as this package is TPU specifc

$(eval $(cargo-package))
