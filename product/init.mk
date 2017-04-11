# Ramdisk packages
PRODUCT_PACKAGES += \
    init.qcom.power.rc \
    init.qcom.rc \
    init.recovery.qcom.rc \
    init.sony.rc

# IO Scheduler
PRODUCT_PROPERTY_OVERRIDES += \
    sys.io.scheduler=bfq
