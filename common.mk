#
# Copyright (C) 2017 The LineageOS Project
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
#

# Common path
COMMON_PATH := device/sony/fusion3-common

# Common specific overlays
DEVICE_PACKAGE_OVERLAYS += $(COMMON_PATH)/overlay

# Common radio specific elements
ifneq ($(BOARD_HAVE_RADIO),false)
DEVICE_PACKAGE_OVERLAYS += $(COMMON_PATH)/radio/overlay
$(call inherit-product, $(COMMON_PATH)/radio/radio.mk)
endif

# Common product elements
include $(COMMON_PATH)/product/*.mk

# Vendor common configurations
$(call inherit-product, vendor/sony/fusion3-common/fusion3-common-vendor.mk)
