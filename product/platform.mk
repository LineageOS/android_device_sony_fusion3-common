# Ramdisk packages
PRODUCT_PACKAGES += \
    fstab.qcom \
    ueventd.qcom.rc

# Sony TrimArea package
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/bin/tad_static:$(TARGET_COPY_OUT_VENDOR)/bin/tad_static

# Sony MACAddrSetup package
PRODUCT_PACKAGES += \
    macaddrsetup
