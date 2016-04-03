# The build script for this project.
# See also: README.md

# Generates a versioned copy of the script.
build:
	mkdir -p target/main && \
	PROJECT_VERSION=$$(git describe --always --dirty --tags --match 'version-*') && \
	sed "s/\\\$$VERSION\\\$$/$${PROJECT_VERSION#version-}/g" src/main/bash/slamtest > target/main/slamtest && \
	chmod u+x target/main/slamtest

test: test-with-lib test-with-src

# Tests the current version with an older (simplier) version.
test-with-lib: build
	lib/test/bash/slamtest src/test/bash/self_test.sh

# Tests the current version with itself.
test-with-src: build
	target/main/slamtest -l src/test/bash/self_test.sh
