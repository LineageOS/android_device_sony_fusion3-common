# Power package
PRODUCT_PACKAGES += \
    power.qcom

# Mpdecision SHIM packages
PRODUCT_PACKAGES += \
    libshim_mpdecision

# QCOM-perf properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=libqti-perfd-client.so
