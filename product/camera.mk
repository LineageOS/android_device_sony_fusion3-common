# Camera packages
PRODUCT_PACKAGES += \
    camera.qcom \
    libstlport \
    Snap

# Camera SHIM packages
PRODUCT_PACKAGES += \
    libshim_cald \
    libshim_camera

# Camera properties
PRODUCT_PROPERTY_OVERRIDES += \
    media.stagefright.legacyencoder=true \
    media.stagefright.less-secure=true
