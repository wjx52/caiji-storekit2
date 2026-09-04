TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = collect_sw
collect_sw_FILES = SimpleStoreKit.swift
collect_sw_FRAMEWORKS = StoreKit Foundation
collect_sw_SWIFTFLAGS = -module-name collect_sw
collect_sw_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
collect_sw_LDFLAGS = -rpath /usr/lib/swift

include $(THEOS_MAKE_PATH)/library.mk

TWEAK_NAME = collect
collect_FILES = Tweak.xm \
                src/CollectAppStore.m \
                src/WindowManager.m \
                src/SPUncaughtExceptionHandler.m \
                src/view/CollectWindow.m
collect_CFLAGS = -fobjc-arc
collect_FRAMEWORKS = UIKit Foundation StoreKit Security SystemConfiguration CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += caiji
include $(THEOS_MAKE_PATH)/aggregate.mk
