# Bluetooth configurations
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/etc/init.qcom.bt.sh:system/etc/init.qcom.bt.sh

# Bluetooth properties
PRODUCT_PROPERTY_OVERRIDES += \
    qcom.bluetooth.soc=smd \
    ro.qualcomm.bt.hci_transport=smd \
    ro.bt.bdaddr_path=/data/misc/bluetooth/bdaddr
