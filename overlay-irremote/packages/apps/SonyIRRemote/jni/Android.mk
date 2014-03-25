LOCAL_PATH := $(call my-dir)
 
include $(CLEAR_VARS)
 
LOCAL_SRC_FILES := irjni.c \
                   libsonyir.c

LOCAL_SHARED_LIBRARIES := \
    liblog \
    libnativehelper \

LOCAL_MODULE := libjni_sonyopenir

include $(BUILD_SHARED_LIBRARY)
