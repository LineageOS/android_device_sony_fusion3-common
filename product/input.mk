# Keys layouts
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/apq8064-tabla-snd-card_Button_Jack.kl:system/usr/keylayout/apq8064-tabla-snd-card_Button_Jack.kl \
    $(COMMON_PATH)/configs/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl \
    $(COMMON_PATH)/configs/keypad_8960.kl:system/usr/keylayout/keypad_8960.kl \
    $(COMMON_PATH)/configs/mhl-rcp.kl:system/usr/keylayout/mhl-rcp.kl \
    $(COMMON_PATH)/configs/pmic8xxx_pwrkey.kl:system/usr/keylayout/pmic8xxx_pwrkey.kl

# Touchscreen properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.input.noresample=1
