MM6108_FIRMWARE_VERSION = ea18605f53387281c1029ea9eb8e0de2bda7bae2
MM6108_FIRMWARE_SITE = https://github.com/MorseMicro/morse-firmware
MM6108_FIRMWARE_SITE_METHOD = git
MM6108_FIRMWARE_LICENSE = GPLv2

#echo $(SRC_FILES)

define MM6108_FIRMWARE_INSTALL_TARGET_CMDS
    BCF_BINS="$$(find $(@D)/bcf -name "*.bin")"; \
    FW_BINS="$$(find $(@D)/firmware -name "*.bin")"; \
    $(INSTALL) -D -t $(TARGET_DIR)/lib/firmware/morse $$BCF_BINS; \
    $(INSTALL) -D -t $(TARGET_DIR)/lib/firmware/morse $$FW_BINS
endef


$(eval $(generic-package))
