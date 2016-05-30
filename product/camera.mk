# Camera permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml

# Camera packages
PRODUCT_PACKAGES += \
    Snap \
    camera.qcom

# SHIM packages
PRODUCT_PACKAGES += \
    libshim_camera \
    libshim_cald

# HAL blob compatibility
PRODUCT_PACKAGES += \
    libstlport
