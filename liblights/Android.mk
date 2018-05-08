# Copyright (C) 2008 The Android Open Source Project
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

ifeq ($(TARGET_PROVIDES_LIBLIGHT),true)

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

ifneq ($(strip $(TARGET_DISPLAY_GAMMA_DISABLED)),true)
    LOCAL_CFLAGS += -DENABLE_GAMMA_CORRECTION
endif
ifneq ($(SECONDARY_BACKLIGHT_PATH),)
    LOCAL_CFLAGS += -DSECONDARY_BACKLIGHT
endif

LOCAL_SRC_FILES := lights.c
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_PROPRIETARY_MODULE := true
LOCAL_SHARED_LIBRARIES := libcutils liblog
LOCAL_CLANG  := true
LOCAL_MODULE := lights.msm8960
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)

endif
