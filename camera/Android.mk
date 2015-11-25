LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

LOCAL_SRC_FILES := \
     gui/SensorManager.cpp \
     ui/GraphicBuffer.cpp \
     ui/GraphicBufferAllocator.cpp \
     ui/GraphicBufferMapper.cpp

LOCAL_SHARED_LIBRARIES := \
    libbinder libcutils libgui libhardware liblog libsync libui libutils

LOCAL_MODULE := libcamera_shim
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    CameraWrapper.cpp

LOCAL_C_INCLUDES := \
    system/media/camera/include

LOCAL_SHARED_LIBRARIES := \
    libhardware liblog libcamera_client libutils libcutils

LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/hw
LOCAL_MODULE := camera.qcom

LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)
