# Recovery configurations
TARGET_RECOVERY_FSTAB := $(COMMON_PATH)/rootdir/fstab.qcom

# TWRP Support (Optional)
ifeq ($(WITH_TWRP),true)
-include $(COMMON_PATH)/board/twrp.mk
endif
