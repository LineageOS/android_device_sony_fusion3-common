# Hardware permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml

# Hardware configurations
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/etc/kickstart_checker.sh:system/etc/kickstart_checker.sh

# Lights package
PRODUCT_PACKAGES += \
    lights.msm8960 \
    libshim_illumination_service
