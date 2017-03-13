LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_ARM_MODE := arm
LOCAL_MODULE := libwildAssembly
LOCAL_SRC_FILES := wild.s
LOCAL_LDLIBS += -Wl,--no-warn-shared-textrel
include $(BUILD_SHARED_LIBRARY)
