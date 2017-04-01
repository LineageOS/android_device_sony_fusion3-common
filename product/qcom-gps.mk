# GPS permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml

# GPS configurations
PRODUCT_COPY_FILES += \
   $(COMMON_PATH)/gps/gps.conf:system/etc/gps.conf

# GPS packages
PRODUCT_PACKAGES += \
    libgps.utils \
    libloc_core \
    libloc_eng \
    gps.msm8960
