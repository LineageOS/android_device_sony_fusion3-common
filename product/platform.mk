# Ramdisk packages
PRODUCT_PACKAGES += \
    fstab.qcom \
    init.qcom.power.rc \
    init.qcom.rc \
    init.recovery.qcom.rc \
    init.sony.rc \
    ueventd.qcom.rc

# Sony TrimArea package
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/bin/tad_static:system/bin/tad_static

# Sony MACAddrSetup package
PRODUCT_PACKAGES += \
    macaddrsetup
