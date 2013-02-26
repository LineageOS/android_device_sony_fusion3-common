$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

COMMON_PATH := device/sony/fusion3-common

DEVICE_PACKAGE_OVERLAYS += $(COMMON_PATH)/overlay

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:system/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:system/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml

# Bootsplash
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/prebuilt/logo_1080x1920.rle:root/logo.rle

# GPS
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/gps.conf:system/etc/gps.conf

# WPA supplicant config
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf

PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/fstab.sony:root/fstab.sony

# QCOM Display
PRODUCT_PACKAGES += \
    libgenlock \
    liboverlay \
    hwcomposer.msm8960 \
    gralloc.msm8960 \
    copybit.msm8960

# NFC Support
PRODUCT_PACKAGES += \
    libnfc \
    libnfc_jni \
    Nfc \
    Tag \
    com.android.nfc_extras

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/com.android.nfc_extras.xml:system/etc/permissions/com.android.nfc_extras.xml

# NFCEE access control
ifeq ($(TARGET_BUILD_VARIANT),user)
    NFCEE_ACCESS_PATH := $(COMMON_PATH)/config/nfcee_access.xml
else
    NFCEE_ACCESS_PATH := $(COMMON_PATH)/config/nfcee_access_debug.xml
endif

PRODUCT_COPY_FILES += \
    $(NFCEE_ACCESS_PATH):system/etc/nfcee_access.xml

# Recovery
PRODUCT_PACKAGES += \
    extract_elf_ramdisk

# Audio
PRODUCT_PACKAGES += \
    alsa.msm8960 \
    audio_policy.msm8960 \
    audio.primary.msm8960 \
    audio.a2dp.default \
    audio.usb.default \
    audio.r_submix.default \
    libaudio-resampler \
    tinymix

# BT
PRODUCT_PACKAGES += \
    hci_qcomm_init

PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/audio_policy.conf:system/etc/audio_policy.conf \
    $(COMMON_PATH)/config/media_codecs.xml:system/etc/media_codecs.xml \
    $(COMMON_PATH)/config/audio_effects.conf:system/etc/audio_effects.conf

# Omx
PRODUCT_PACKAGES += \
    mm-vdec-omx-test \
    mm-venc-omx-test720p \
    libdivxdrmdecrypt \
    libOmxVdec \
    libOmxVenc \
    libOmxCore \
    libstagefrighthw \
    libc2dcolorconvert

# GPS
PRODUCT_PACKAGES += \
    libloc_adapter \
    libloc_eng \
    libloc_api_v02 \
    libgps.utils \
    gps.msm8960

# Light
PRODUCT_PACKAGES += \
    lights.msm8960

# Power
PRODUCT_PACKAGES += \
    power.qcom

# QRNGD
PRODUCT_PACKAGES += \
    qrngd

# WIFI MAC update
PRODUCT_PACKAGES += \
    mac-update

# FmRadio
PRODUCT_PACKAGES += \
    FmRadioReceiver

# FM Radio
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/init.qcom.fm.sh:system/etc/init.qcom.fm.sh \
    frameworks/native/data/etc/com.stericsson.hardware.fm.receiver.xml:system/etc/permissions/com.stericsson.hardware.fm.receiver.xml

# Misc
PRODUCT_PACKAGES += \
    librs_jni \
    com.android.future.usb.accessory

# Live Wallpapers
PRODUCT_PACKAGES += \
    LiveWallpapers \
    LiveWallpapersPicker \
    VisualizationWallpapers \

# Filesystem management tools
PRODUCT_PACKAGES += \
    e2fsck

# We have enough storage space to hold precise GC data
PRODUCT_TAGS += dalvik.gc.type-precise

# Custom init / uevent
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/init.qcom.bt.sh:system/etc/init.qcom.bt.sh \
    $(COMMON_PATH)/config/init.qcom.rc:root/init.qcom.rc \
    $(COMMON_PATH)/config/ueventd.qcom.rc:root/ueventd.qcom.rc

# Post recovery script
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/recovery/postrecoveryboot.sh:recovery/root/sbin/postrecoveryboot.sh

# Additional sbin stuff
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/prebuilt/charger:root/charger \
    $(COMMON_PATH)/prebuilt/wait4tad_static:root/sbin/wait4tad_static \
    $(COMMON_PATH)/prebuilt/tad_static:root/sbin/tad_static

# CNE config
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/OperatorPolicy.xml:system/etc/OperatorPolicy.xml \
    $(COMMON_PATH)/config/UserPolicy.xml:system/etc/UserPolicy.xml

# ALSA configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/snd_soc_msm_2x_Fusion3:system/etc/snd_soc_msm/snd_soc_msm_2x_Fusion3

# Thermal monitor configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/thermald-8064.conf:system/etc/thermald.conf

# Set default USB interface
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp

# QCOM
PRODUCT_PROPERTY_OVERRIDES += \
    com.qc.hardware=true \
    dev.pm.dyn_samplingrate=1

# QC Perf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=/system/lib/libqc-opt.so

# Radio and Telephony
PRODUCT_PROPERTY_OVERRIDES += \
    telephony.lteOnCdmaDevice=0 \
    ro.ril.transmitpower=true \
    persist.radio.add_power_save=1

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    rild.libpath=/system/lib/libril-qc-qmi-1.so

# GPS
PRODUCT_PROPERTY_OVERRIDES += \
    persist.gps.qmienabled=true

# QCOM Display
PRODUCT_PROPERTY_OVERRIDES += \
    debug.sf.hw=1 \
    debug.egl.hw=1 \
    debug.composition.type=dyn \
    debug.mdpcomp.maxlayer=3 \
    debug.enable.wl_log=1 \
    debug.mdpcomp.logs=0

PRODUCT_PROPERTY_OVERRIDES += \
    ro.hwui.texture_cache_size=128.0f \
    ro.hwui.text_small_cache_width=2048

# External Display
PRODUCT_PROPERTY_OVERRIDES += \
    hw.trueMirrorSupported=1 \
    ro.hwui.external_width=1920 \
    ro.hwui.external_height=1080

# Audio
PRODUCT_PROPERTY_OVERRIDES += \
    persist.audio.fluence.mode=endfire \
    persist.audio.vr.enable=false \
    persist.audio.handset.mic=analog \
    persist.audio.lowlatency.rec=false \
    persist.audio.hp=true \
    af.resampler.quality=255 \
    mpq.audio.decode=true

# Audio LPA
PRODUCT_PROPERTY_OVERRIDES += \
    lpa.decode=false \
    lpa.use-stagefright=true

# Bluetooth
PRODUCT_PROPERTY_OVERRIDES += \
    ro.qualcomm.bt.hci_transport=smd

# OpenglES
PRODUCT_PROPERTY_OVERRIDES += \
    ro.opengles.version=131072

# Wifi
PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=wlan0 \
    wifi.supplicant_scan_interval=15

# Do not power down SIM card when modem is sent to Low Power Mode.
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.apm_sim_not_pwdn=1

# Ril sends only one RIL_UNSOL_CALL_RING, so set call_ring.multiple to false
PRODUCT_PROPERTY_OVERRIDES += \
    ro.telephony.call_ring.multiple=0

PRODUCT_PROPERTY_OVERRIDES += \
    debug.egl.recordable.rgba8888=1

# Include non-opensource parts if available
$(call inherit-product-if-exists, vendor/sony/qcom-common/common-vendor.mk)

# Include non-opensource parts if available
$(call inherit-product-if-exists, vendor/sony/fusion3-common/common-vendor.mk)
