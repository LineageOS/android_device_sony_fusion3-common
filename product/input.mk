# Touchscreen permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml

# Keys layouts
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/apq8064-tabla-snd-card_Button_Jack.kl:system/usr/keylayout/apq8064-tabla-snd-card_Button_Jack.kl \
    $(LOCAL_PATH)/configs/clearpad.kl:system/usr/keylayout/clearpad.kl \
    $(LOCAL_PATH)/configs/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl \
    $(LOCAL_PATH)/configs/keypad_8960.kl:system/usr/keylayout/keypad_8960.kl \
    $(LOCAL_PATH)/configs/mhl-rcp.kl:system/usr/keylayout/mhl-rcp.kl \
    $(LOCAL_PATH)/configs/pmic8xxx_pwrkey.kl:system/usr/keylayout/pmic8xxx_pwrkey.kl

# Touchscreen
PRODUCT_PROPERTY_OVERRIDES += \
    ro.input.noresample=1
