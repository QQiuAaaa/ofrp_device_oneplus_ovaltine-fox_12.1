# Android.mk for the OVALTINE (OnePlus 9 series) OrangeFox recovery device tree.
#
# Include sub-directory makefiles only when building for this specific device.
# The (TARGET_DEVICE) guard prevents the sub-makefiles from being evaluated
# while other devices are being built from the same source tree (upstream TWRP pattern).

LOCAL_PATH := $(call my-dir)

ifeq ($(filter $(TARGET_DEVICE),ovaltine),)
$(warning OVALTINE: skipping sub-makefiles for TARGET_DEVICE "$(TARGET_DEVICE)")
else
  include $(call all-subdir-makefiles)
endif
