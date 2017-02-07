# Copyright (C) 2013 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Include path
TARGET_SPECIFIC_HEADER_PATH += device/sony/fusion3-common/include

# Architecture
TARGET_ARCH := arm
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_VARIANT := krait

# Board overrides
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := MSM8960

# Platform
BOARD_VENDOR := sony
TARGET_BOARD_PLATFORM := msm8960
BOARD_VENDOR_PLATFORM := fusion3
BOARD_LIB_DUMPSTATE := libdumpstate.sony

# Kernel information
BOARD_KERNEL_BASE     := 0x80200000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE  := console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3
BOARD_MKBOOTIMG_ARGS  := --ramdisk_offset 0x02000000
TARGET_KERNEL_SOURCE  := kernel/sony/apq8064

# Audio
BOARD_USES_ALSA_AUDIO := true
AUDIO_USE_LL_AS_PRIMARY_OUTPUT := true
USE_CUSTOM_AUDIO_POLICY := 1

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_QCOM := true
BLUETOOTH_HCI_USE_MCT := true

# Camera
TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS := true
TARGET_HAS_LEGACY_CAMERA_HAL1 := true
TARGET_PROVIDES_CAMERA_HAL := true
USE_DEVICE_SPECIFIC_CAMERA := true

# CM Hardware
BOARD_USES_CYANOGEN_HARDWARE := true
BOARD_HARDWARE_CLASS := hardware/cyanogen/cmhw
TARGET_TAP_TO_WAKE_NODE := "/sys/devices/virtual/input/clearpad/wakeup_gesture"

# GPS
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := $(TARGET_BOARD_PLATFORM)
BOARD_VENDOR_QCOM_LOC_PDK_FEATURE_SET := true
TARGET_NO_RPC := true

# Graphics
TARGET_USES_ION := true
TARGET_USES_C2D_COMPOSITION := true
TARGET_DISPLAY_USE_RETIRE_FENCE := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
OVERRIDE_RS_DRIVER := libRSDriver_adreno.so
HAVE_ADRENO_SOURCE := false

# Healthd
BOARD_CHARGER_ENABLE_SUSPEND := true
BOARD_CHARGER_DISABLE_INIT_BLANK := true
RED_LED_PATH := /sys/class/leds/lm3533-red/brightness
GREEN_LED_PATH := /sys/class/leds/lm3533-green/brightness
BLUE_LED_PATH := /sys/class/leds/lm3533-blue/brightness

# Lights HAL
TARGET_PROVIDES_LIBLIGHT := true

# Power HAL
TARGET_POWERHAL_VARIANT := qcom
CM_POWERHAL_EXTENSION := qcom

# QCOM hardware
BOARD_USES_QCOM_HARDWARE := true

# FM RADIO
BOARD_HAVE_QCOM_FM := true

# RIL
BOARD_PROVIDES_LIBRIL := true
TARGET_RIL_VARIANT := caf

# Wifi
BOARD_HAS_QCOM_WLAN              := true
BOARD_WLAN_DEVICE                := qcwcn
WPA_SUPPLICANT_VERSION           := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER      := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_HOSTAPD_DRIVER             := NL80211
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WIFI_DRIVER_FW_PATH_STA          := "sta"
WIFI_DRIVER_FW_PATH_AP           := "ap"

# Partition types
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Partition blocks
BOARD_FLASH_BLOCK_SIZE := 131072

# Partition sizes
BOARD_BOOTIMAGE_PARTITION_SIZE := 20971520
BOARD_CACHEIMAGE_PARTITION_SIZE := 576716800
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 16777216
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2147483648

# Recovery
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_BOOTIMG_MK := device/sony/fusion3-common/boot/custombootimg.mk
TARGET_RECOVERY_FSTAB := device/sony/fusion3-common/rootdir/fstab.qcom

# Boot animation
TARGET_BOOTANIMATION_TEXTURE_CACHE := true
TARGET_BOOTANIMATION_USE_RGB565 := true

# TWRP Support - Optional
ifeq ($(WITH_TWRP),true)
-include device/sony/fusion3-common/twrp.mk
endif

# SELinux
include device/qcom/sepolicy/sepolicy.mk

BOARD_SEPOLICY_DIRS += \
    device/sony/fusion3-common/sepolicy