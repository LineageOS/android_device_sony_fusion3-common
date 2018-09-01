# Camera packages
PRODUCT_PACKAGES += \
    camera.qcom \
    Snap

# Camera SHIM packages
PRODUCT_PACKAGES += \
    libshim_cald \
    libshim_camera

# Camera configurations
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml

# Camera properties
PRODUCT_PROPERTY_OVERRIDES += \
    media.stagefright.legacyencoder=true \
    media.stagefright.less-secure=true
