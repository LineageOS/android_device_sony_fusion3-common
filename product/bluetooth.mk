# Bluetooth packages
PRODUCT_PACKAGES += \
    init.qcom.bt.sh

# Bluetooth properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.bt.bdaddr_path=/data/misc/bluetooth/bdaddr \
    ro.qualcomm.bt.hci_transport=smd
