# Platform configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/fstab.qcom:root/fstab.qcom \
    $(COMMON_PATH)/rootdir/fstab.qcom:recovery/root/fstab.qcom \
    $(COMMON_PATH)/rootdir/ueventd.qcom.rc:root/ueventd.qcom.rc

# Sony TrimArea package
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/bin/tad_static:system/bin/tad_static

# Sony MACAddrSetup package
PRODUCT_PACKAGES += \
    macaddrsetup
