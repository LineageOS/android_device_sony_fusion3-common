# Power package
PRODUCT_PACKAGES += \
    android.hardware.power@1.0-service-qti

# QCOM-perf properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=libqti-perfd-client.so
