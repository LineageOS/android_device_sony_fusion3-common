# Audio configurations
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/audio/audio_effects.xml:system/vendor/etc/audio_effects.xml \
    $(COMMON_PATH)/audio/audio_platform_info.xml:system/etc/audio_platform_info.xml

# Audio properties
PRODUCT_PROPERTY_OVERRIDES += \
    audio.offload.disable=1 \
    media.aac_51_output_enabled=true \
    persist.audio.fluence.voicecall=true \
    persist.audio.fluence.voicerec=false \
    persist.audio.fluence.speaker=true \
    qcom.hw.aac.encoder=true \
    ro.qc.sdk.audio.fluencetype=fluence \
    ro.config.media_vol_steps=25 \
    ro.config.vc_call_vol_steps=7
