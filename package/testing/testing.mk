################################################################################
#
# TESTING
#
################################################################################

TESTING_VERSION = 0db76f3
TESTING_SITE = https://github.com/KotSchrodingera7/test_peripheral.git
TESTING_SITE_METHOD = git
TESTING_INSTALL_STAGING = YES


define TESTING_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/bin
	mkdir -p $(TARGET_DIR)/usr/local/share
	$(INSTALL) -D -m 0777 $(@D)/tester_qt $(TARGET_DIR)/usr/bin/tester
	$(INSTALL) -D -m 0755 $(@D)/scripts/* $(TARGET_DIR)/usr/local/bin
	$(INSTALL) -D -m 0755 $(@D)/configs/config.cfg $(TARGET_DIR)/usr/local/share
	$(INSTALL) -D -m 0755 $(@D)/configs/board.cfg.json $(TARGET_DIR)/root/board.cfg
endef

$(eval $(cmake-package))
