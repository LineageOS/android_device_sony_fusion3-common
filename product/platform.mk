# Platform configuration
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/fstab.qcom:root/fstab.qcom \
    $(LOCAL_PATH)/rootdir/fstab.qcom:recovery/root/fstab.qcom \
    $(LOCAL_PATH)/rootdir/ueventd.qcom.rc:root/ueventd.qcom.rc

# Trim area daemon
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/sbin/tad_static:root/sbin/tad_static

# WIFI MAC update
PRODUCT_PACKAGES += \
    macaddrsetup

# I/O scheduler
PRODUCT_PROPERTY_OVERRIDES += \
    sys.io.scheduler=bfq

# Bootlogo
PRODUCT_COPY_FILES += \
     $(LOCAL_PATH)/boot/logos/$(TARGET_SCREEN_WIDTH)x$(TARGET_SCREEN_HEIGHT).rle:root/logo.rle
