# Hardware configurations
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/etc/kickstart_checker.sh:system/etc/kickstart_checker.sh

# Lights package
PRODUCT_PACKAGES += \
    lights.msm8960
