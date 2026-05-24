include $(sort $(wildcard $(BR2_EXTERNAL_ODY_TREE_PATH)/package/*/*.mk))

# Morse Hostap override
WPA_SUPPLICANT_VERSION = 1.17.9
WPA_SUPPLICANT_SITE_METHOD = git
WPA_SUPPLICANT_SITE = https://github.com/MorseMicro/hostap
