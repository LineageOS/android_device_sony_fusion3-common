LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    graphic-buffer.cpp

LOCAL_SHARED_LIBRARIES := liblog libcutils libui libgui libbinder libutils
LOCAL_MODULE := libshim_camera
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    gui/Sensor.cpp \
    gui/SensorManager.cpp \
    parcel.cpp

LOCAL_SHARED_LIBRARIES := liblog libcutils libgui libbinder libutils
LOCAL_MODULE := libshim_cald
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)
