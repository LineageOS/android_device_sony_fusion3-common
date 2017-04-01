#
# Copyright (C) 2013 The CyanogenMod Project
#           (C) 2017 The LineageOS Project
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

# Board common path
COMMON_PATH := device/sony/fusion3-common

# Board common headers
TARGET_SPECIFIC_HEADER_PATH += $(COMMON_PATH)/include

# Board common elements
include $(COMMON_PATH)/PlatformConfig.mk
include $(COMMON_PATH)/board/*.mk

# Board common vendor
-include vendor/sony/fusion3-common/BoardConfigVendor.mk
