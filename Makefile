# The build script for this project.
# See also: README.md

# ##############################################################################
# Compatibility

.POSIX:
.SUFFIXES:
SHELL = /bin/sh

# ##############################################################################
# Commands

CHMOD = chmod

# ##############################################################################
# Paths

SRC_DIR = ./src
LIB_DIR = ./lib
TARGET_DIR = ./target
TARGET_DIRS = $(TARGET_DIR) $(TARGET_DIR)/main \
	$(TARGET_DIR)/test $(TARGET_DIR)/test/in $(TARGET_DIR)/test/out


# ##############################################################################
# Targets

.PHONY: all
all: $(TARGET_DIR)/main/slamtest

# Generates a versioned copy of the script.
$(TARGET_DIR)/main/slamtest: $(SRC_DIR)/main/bash/slamtest
	-for d in $(TARGET_DIRS); do mkdir "$$d"; done
	project_version="$$(./version)" && \
	sed "s/\\\$$VERSION\\\$$/$${project_version}/g" $(SRC_DIR)/main/bash/slamtest > $(TARGET_DIR)/main/slamtest
	$(CHMOD) u+x $(TARGET_DIR)/main/slamtest

# Removes generated files
.PHONY: clean distclean mostlyclean maintainer-clean
clean:
	rm -rf target
disclean: clean
mostlyclean: clean
maintainer-clean: clean

.PHONY: check
check: check-with-lib check-with-src

# Tests the built version with an older (simplier) version.
.PHONY: check-with-lib
check-with-lib:
	-for dir in $(TARGET_DIRS); do mkdir "$${dir}"; done
	$(LIB_DIR)/test/bash/slamtest $(SRC_DIR)/test/bash/self_test.sh

# Tests the built version with itself.
.PHONY: check-with-current
check-with-current:
	$(TARGET_DIR)/main/slamtest -g $(TARGET_DIR)/test-with-current -l $(SRC_DIR)/test/bash/self_test.sh
