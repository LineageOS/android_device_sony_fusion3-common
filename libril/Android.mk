# Copyright 2006 The Android Open Source Project

ifeq ($(BOARD_PROVIDES_LIBRIL),true)

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
    ril.cpp \
    ril_event.cpp \
	RilSocket.cpp \
    RilSapSocket.cpp \

LOCAL_SHARED_LIBRARIES := \
    liblog \
    libutils \
    libbinder \
    libcutils \
    libhardware_legacy \
    librilutils \

LOCAL_STATIC_LIBRARIES := \
    libprotobuf-c-nano-enable_malloc \

#LOCAL_CFLAGS := -DANDROID_MULTI_SIM -DDSDA_RILD1

ifeq ($(SIM_COUNT), 2)
    LOCAL_CFLAGS += -DANDROID_SIM_COUNT_2
endif

LOCAL_C_INCLUDES += $(TARGET_OUT_HEADER)/librilutils
LOCAL_C_INCLUDES += external/nanopb-c

ifeq ($(BOARD_HAS_RIL_LEGACY_PAP),true)
    LOCAL_CFLAGS += -DRIL_LEGACY_PAP
endif

LOCAL_MODULE:= libril

LOCAL_COPY_HEADERS_TO := libril
LOCAL_COPY_HEADERS := ril_ex.h

include $(BUILD_SHARED_LIBRARY)
endif # BOARD_PROVIDES_LIBRIL
