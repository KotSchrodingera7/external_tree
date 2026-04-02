################################################################################
#
# TESTING
#
################################################################################

TESTING_VERSION = 90c356c
TESTING_SITE = https://gitlab.macrogroup.ru/diasom/test_peripheral.git
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

TESTING_CONF_OPTS += \
	-DTESTER_SOC=$(TESTING_SOC) \
	-DCMAKE_TOOLCHAIN_FILE=$(HOST_DIR)/share/buildroot/toolchainfile.cmake

define TESTING_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/bin
	mkdir -p $(TARGET_DIR)/usr/local/share
	$(INSTALL) -D -m 0777 $(@D)/tester_qt $(TARGET_DIR)/usr/bin/tester
	$(INSTALL) -D -m 0755 $(@D)/scripts/* $(TARGET_DIR)/usr/local/bin
	$(INSTALL) -D -m 0755 $(@D)/configs/config.cfg $(TARGET_DIR)/usr/local/share
	$(INSTALL) -D -m 0755 $(@D)/scripts/select_board_cfg.sh $(TARGET_DIR)/usr/bin/select_board_cfg.sh
	$(INSTALL) -D -m 0644 $(@D)/systemd/tester.service $(TARGET_DIR)/usr/lib/systemd/system/tester.service

	$(INSTALL) -D $(@D)/configs/board_rk3568.json $(TARGET_DIR)/root/board_rk3568.json
	$(INSTALL) -D $(@D)/configs/board_rk3588.json $(TARGET_DIR)/root/board_rk3588.json
	$(INSTALL) -D $(@D)/configs/board_rk3588_hat.json $(TARGET_DIR)/root/board_rk3588_hat.json

	if [ "$(TESTING_SOC)" = "rk3568" ]; then \
		ln -sf /root/board_rk3568.json $(TARGET_DIR)/root/board.cfg; \
	else \
		ln -sf /root/board_rk3588.json $(TARGET_DIR)/root/board.cfg; \
	fi
endef

$(eval $(cmake-package))
