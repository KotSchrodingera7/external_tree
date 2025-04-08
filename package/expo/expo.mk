################################################################################
#
# EXPO
#
################################################################################

EXPO_VERSION = 2d8a143
EXPO_SITE = https://github.com/KotSchrodingera7/test_peripheral.git
EXPO_SITE_METHOD = git
EXPO_INSTALL_STAGING = YES


define EXPO_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/share/qml
	mkdir -p $(TARGET_DIR)/usr/local/share/icons
	$(INSTALL) -D -m 0777 $(@D)/expo_view $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/qml/*.qml $(TARGET_DIR)/usr/local/share/qml
	$(INSTALL) -D -m 0755 $(@D)/icons/* $(TARGET_DIR)/usr/local/share/icons
endef

$(eval $(cmake-package))
