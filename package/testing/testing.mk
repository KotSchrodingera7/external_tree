################################################################################
#
# TESTING
#
################################################################################

TESTING_VERSION = intodaction
TESTING_SITE = https://github.com/KotSchrodingera7/test_peripheral.git
TESTING_SITE_METHOD = git
TESTING_INSTALL_STAGING = YES


define TESTING_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/share/qml
	$(INSTALL) -D -m 0777 $(@D)/tester $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/qml/*.qml $(TARGET_DIR)/usr/local/share/qml
endef

$(eval $(cmake-package))
