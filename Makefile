INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = collect

collect_FILES = collect/collect/collect.xm \
                collect/collect/CollectAppStore.m \
                collect/collect/StoreKitBridge.m \
                collect/collect/StoreKit2Manager.swift \
                collect/collect/view/CollectWindow.m \
                collect/collect/WindowManager.m \
                collect/collect/SPUncaughtExceptionHandler.m

collect_CFLAGS = -fobjc-arc
collect_SWIFTFLAGS = -import-objc-header collect/collect/collect-Bridging-Header.h
collect_FRAMEWORKS = UIKit Foundation StoreKit Security SystemConfiguration CoreGraphics
collect_EXTRA_FRAMEWORKS =

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += caiji
include $(THEOS_MAKE_PATH)/aggregate.mk
