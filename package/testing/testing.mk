################################################################################
#
# TESTING
#
################################################################################

TESTING_VERSION = feature_3588
TESTING_SITE = https://github.com/KotSchrodingera7/test_peripheral.git
TESTING_SITE_METHOD = git
TESTING_INSTALL_STAGING = YES


define TESTING_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/bin
	$(INSTALL) -D -m 0777 $(@D)/tester $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/scripts/*.sh $(TARGET_DIR)/usr/local/bin
endef

$(eval $(cmake-package))
