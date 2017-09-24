LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    graphic-buffer.cpp \
    utils/Looper.cpp

LOCAL_SHARED_LIBRARIES := libui libutils liblog
LOCAL_MODULE := libshim_camera
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    gui/SensorManager.cpp \
    parcel.cpp

LOCAL_SHARED_LIBRARIES := libcutils libgui libbinder libutils liblog
LOCAL_MODULE := libshim_cald
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    accept.c

LOCAL_MODULE := libshim_illumination_service
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)
