LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    graphic-buffer.cpp \
    utils/Looper.cpp \
    utils/VectorImpl.cpp

LOCAL_C_INCLUDES := \
    external/safe-iop/include \
    system/core/libutils

LOCAL_SHARED_LIBRARIES := libui libutils liblog
LOCAL_MODULE := libshim_camera
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    gui/SensorManager.cpp \
    parcel.cpp \
    utils/VectorImpl.cpp

LOCAL_C_INCLUDES := \
    external/safe-iop/include \
    system/core/libutils

LOCAL_SHARED_LIBRARIES := libcutils libgui libbinder libutils liblog
LOCAL_MODULE := libshim_cald
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    utils/VectorImpl.cpp

LOCAL_C_INCLUDES := \
    external/safe-iop/include \
    system/core/libutils

LOCAL_SHARED_LIBRARIES := \
    liblog \
    libutils

LOCAL_MODULE := libshim_MPU3050
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)
