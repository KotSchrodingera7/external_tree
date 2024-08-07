################################################################################
#
# TESTING
#
################################################################################

TESTING_VERSION = intodaction
TESTING_SITE = $(call github,KotSchrodingera,test_peripheral,$(TESTING_VERSION))
# TESTING_LICENSE = MIT
# TESTING_LICENSE_FILES = LICENCE
# TESTING_CPE_ID_VENDOR = TESTING
# TESTING_DEPENDENCIES = host-pkgconf
# TESTING_CONF_OPTS = -DTESTING_GSSAPI=OFF

# ifeq ($(BR2_PACKAGE_LIBGTK3),y)
# TESTING_DEPENDENCIES += libgtk3
# else ifeq ($(BR2_PACKAGE_LIBGTK2),y)
# TESTING_DEPENDENCIES += libgtk2
# endif

# ifeq ($(BR2_STATIC_LIBS),y)
# TESTING_CONF_OPTS += -DCMAKE_C_FLAGS="$(TARGET_CFLAGS) -DNO_LIBDL"
# endif

$(eval $(cmake-package))
