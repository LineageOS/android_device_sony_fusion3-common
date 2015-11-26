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

# Inherit from Sony common
include device/sony/common/BoardConfigCommon.mk

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
TARGET_BOARD_PLATFORM := msm8960
BOARD_VENDOR_PLATFORM := fusion3
BOARD_LIB_DUMPSTATE := libdumpstate.sony

# Bionic
MALLOC_IMPL := dlmalloc

# Kernel information
BOARD_KERNEL_BASE     := 0x80200000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE  := console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3
BOARD_MKBOOTIMG_ARGS  := --ramdisk_offset 0x02000000
TARGET_KERNEL_SOURCE  := kernel/sony/apq8064

# Audio
BOARD_USES_ALSA_AUDIO := true

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_QCOM := true
BLUETOOTH_HCI_USE_MCT := true

# Camera
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
USE_OPENGL_RENDERER := true
TARGET_USES_ION := true
TARGET_USES_C2D_COMPOSITION := true
TARGET_DISPLAY_USE_RETIRE_FENCE := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
OVERRIDE_RS_DRIVER := libRSDriver_adreno.so
HAVE_ADRENO_SOURCE := false

# Healthd
BOARD_CHARGER_ENABLE_SUSPEND := true
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

# RIL
BOARD_PROVIDES_LIBRIL := true
BOARD_RIL_CLASS := ../../../device/sony/fusion3-common/ril/

# Wifi
BOARD_HAS_QCOM_WLAN              := true
BOARD_WLAN_DEVICE                := qcwcn
WPA_SUPPLICANT_VERSION           := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER      := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_HOSTAPD_DRIVER             := NL80211
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WIFI_DRIVER_MODULE_PATH          := "/system/lib/modules/wlan.ko"
WIFI_DRIVER_MODULE_NAME          := "wlan"
WIFI_DRIVER_FW_PATH_STA          := "sta"
WIFI_DRIVER_FW_PATH_AP           := "ap"

BOARD_USE_SONY_MACUPDATE := true

# Filesystem
BOARD_FLASH_BLOCK_SIZE := 131072
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Font expansion
EXTENDED_FONT_FOOTPRINT := true

# Recovery
BOARD_CUSTOM_BOOTIMG_MK := device/sony/fusion3-common/boot/custombootimg.mk
TARGET_RECOVERY_FSTAB := device/sony/fusion3-common/rootdir/fstab.qcom

# Vold
TARGET_USE_CUSTOM_LUN_FILE_PATH := /sys/devices/platform/msm_hsusb/gadget/lun%d/file

# Boot animation
TARGET_BOOTANIMATION_TEXTURE_CACHE := true
TARGET_BOOTANIMATION_USE_RGB565 := true

# SELinux
include device/qcom/sepolicy/sepolicy.mk

BOARD_SEPOLICY_DIRS += \
    device/sony/fusion3-common/sepolicy
