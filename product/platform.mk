# Ramdisk packages
PRODUCT_PACKAGES += \
    fstab.qcom \
    ueventd.qcom.rc

# Sony TrimArea package
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/bin/tad_static:system/bin/tad_static

# Sony MACAddrSetup package
PRODUCT_PACKAGES += \
    macaddrsetup
