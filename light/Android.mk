#
# Copyright (C) 2018-2019 The LineageOS Project
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

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

ifneq ($(strip $(TARGET_DISPLAY_GAMMA_DISABLED)),true)
    LOCAL_CFLAGS += -DENABLE_GAMMA_CORRECTION
endif
ifneq ($(TARGET_USES_SECONDARY_BACKLIGHT),)
    LOCAL_CFLAGS += -DSECONDARY_BACKLIGHT
endif

LOCAL_MODULE := android.hardware.light@2.0-service.fusion3
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_MODULE_TAGS := optional
LOCAL_INIT_RC := android.hardware.light@2.0-service.fusion3.rc
LOCAL_SRC_FILES := service.cpp Light.cpp
LOCAL_SHARED_LIBRARIES := \
    libbase \
    libcutils \
    libhardware \
    libhidlbase \
    libhidltransport \
    libhwbinder \
    libutils \
    android.hardware.light@2.0
LOCAL_PROPRIETARY_MODULE := true

include $(BUILD_EXECUTABLE)
