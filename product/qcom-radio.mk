# Telephony permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# QMI properties
PRODUCT_PROPERTY_OVERRIDES += \
    com.qc.hardware=true \
    persist.data.qmi.adb_logmask=0

# Data properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.android.mobiledata=false
