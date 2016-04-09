# The build script for this project.
# See also: README.md

.PHONY: all
all: target/main/slamtest

# Generates a versioned copy of the script.
target/main/slamtest: src/main/bash/slamtest
	mkdir -p target/main && \
	PROJECT_VERSION=$$(git describe --always --dirty --tags --match 'version-*') && \
	sed "s/\\\$$VERSION\\\$$/$${PROJECT_VERSION#version-}/g" src/main/bash/slamtest > target/main/slamtest && \
	chmod u+x target/main/slamtest

# Removes generated files
.PHONY: clean distclean mostlyclean maintainer-clean
clean:
	rm -rf target
disclean: clean
mostlyclean: clean
maintainer-clean: clean

.PHONY: check
check: check-with-lib check-with-src

# Tests the current version with an older (simplier) version.
.PHONY: check-with-lib
check-with-lib:
	lib/test/bash/slamtest src/test/bash/self_test.sh

# Tests the current version with itself.
.PHONY: check-with-src
check-with-src:
	target/main/slamtest -l src/test/bash/self_test.sh
