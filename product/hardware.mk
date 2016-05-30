# Hardware configurations
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/hw_config.sh:system/etc/hw_config.sh

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/kickstart_checker.sh:system/etc/kickstart_checker.sh

# Lights package
PRODUCT_PACKAGES += \
    lights.msm8960
