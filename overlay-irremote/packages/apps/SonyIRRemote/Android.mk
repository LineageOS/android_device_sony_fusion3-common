LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

#LOCAL_STATIC_JAVA_LIBRARIES := AndroidAsync

LOCAL_MODULE_TAGS := optional

LOCAL_SRC_FILES := $(call all-java-files-under, src)

LOCAL_PACKAGE_NAME := SonyIRRemote

LOCAL_JNI_SHARED_LIBRARIES := libjni_sonyopenir

include $(BUILD_PACKAGE)

include $(call all-makefiles-under, jni)

