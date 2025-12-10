MORSE_VERSION_MAJOR = 1.16
MORSE_VERSION = $(MORSE_VERSION_MAJOR).4

include $(sort $(wildcard $(BR2_EXTERNAL_ODY_TREE_PATH)/package/morse/*/*.mk))
