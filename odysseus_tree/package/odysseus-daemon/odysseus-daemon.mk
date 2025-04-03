ODYSSEUS_DAEMON_VERSION = da32a5b07f15bfbeb7ff2b06f51b1f78d9a19490
ODYSSEUS_DAEMON_SITE_METHOD = git
ODYSSEUS_DAEMON_SITE = https://github.com/Northeastern-Electric-Racing/Odysseus-Daemon
ODYSSEUS_DAEMON_DEPENDENCIES += openssl

# all dependencies and support scripts are in the TPU overlay as this package is TPU specifc

$(eval $(cargo-package))
