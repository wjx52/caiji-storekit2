INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = caiji

caiji_FILES = ../collect/collect/caiji.xm
caiji_CFLAGS = -fobjc-arc
caiji_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
