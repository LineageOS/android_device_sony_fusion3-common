LOCAL_SCRIPTS_PATH := device/sony/fusion3-common/prebuilts
PRODUCT_COPY_FILES += \
    $(LOCAL_SCRIPTS_PATH)/bin/init.qcom.bt.sh:system/bin/init.qcom.bt.sh \
    $(LOCAL_SCRIPTS_PATH)/bin/init.qcom.fm.sh:system/bin/init.qcom.fm.sh \
    $(LOCAL_SCRIPTS_PATH)/bin/kickstart_checker.sh:system/bin/kickstart_checker.sh

PRODUCT_COPY_FILES += \
    $(LOCAL_SCRIPTS_PATH)/etc/init/init.scripts.sony.rc:system/etc/init/init.scripts.sony.rc
