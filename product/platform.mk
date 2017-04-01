# Platform configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/fstab.qcom:root/fstab.qcom \
    $(COMMON_PATH)/rootdir/fstab.qcom:recovery/root/fstab.qcom \
    $(COMMON_PATH)/rootdir/ueventd.qcom.rc:root/ueventd.qcom.rc

# TAD package
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/bin/tad_static:system/bin/tad_static

# Sony MACAddrSetup package
PRODUCT_PACKAGES += \
    macaddrsetup

# I/O scheduler
PRODUCT_PROPERTY_OVERRIDES += \
    sys.io.scheduler=bfq

# Bootlogo
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/boot/logos/$(TARGET_SCREEN_WIDTH)x$(TARGET_SCREEN_HEIGHT).rle:root/logo.rle
