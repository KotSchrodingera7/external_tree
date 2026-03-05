################################################################################
#
# TESTING
#
################################################################################

TESTING_VERSION = 17f2375
TESTING_SITE = https://github.com/KotSchrodingera7/test_peripheral.git
TESTING_SITE_METHOD = git
TESTING_INSTALL_STAGING = YES

TESTING_DEPENDENCIES = \
	qt5base qt5declarative \
	gstreamer1 gst1-plugins-base \
	spdlog libgpiod


ifeq ($(BR2_PACKAGE_TESTING_SOC_RK3568),y)
TESTING_SOC = rk3568
endif

ifeq ($(BR2_PACKAGE_TESTING_SOC_RK3588),y)
TESTING_SOC = rk3588
endif

ifeq ($(TESTING_SOC),)
$(error "TESTING_SOC is not set; enable one of rk3568/rk3588 in Config.in")
endif

define TESTING_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/bin
	mkdir -p $(TARGET_DIR)/usr/local/share
	$(INSTALL) -D -m 0777 $(@D)/tester_qt $(TARGET_DIR)/usr/bin/tester
	$(INSTALL) -D -m 0755 $(@D)/scripts/* $(TARGET_DIR)/usr/local/bin
	$(INSTALL) -D -m 0755 $(@D)/configs/config.cfg $(TARGET_DIR)/usr/local/share
	$(INSTALL) -D $(@D)/configs/board_$(TESTING_SOC).json $(TARGET_DIR)/root/board.cfg
endef

$(eval $(cmake-package))
