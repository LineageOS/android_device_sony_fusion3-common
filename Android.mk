LOCAL_PATH := $(call my-dir)

ifeq ($(BOARD_VENDOR_PLATFORM),fusion3)
    include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
