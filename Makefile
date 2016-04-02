#! /usr/bin/make -f
# See also: README.md

PROJECT_VERSION="$(git describe --match 'version-*')"
PROJECT_VERSION="${PROJECT_VERSION#version-}"

# Generates a versioned copy of the script.
build:
	mkdir -p target/main
	sed "s/\$VERSION\$/${PROJECT_VERSION}/g" src/main/bash/slamtest > target/main/slamtest

test: test-with-lib test-with-src

# Tests the current version with an older (simplier) version.
test-with-lib: build
	lib/test/bash/slamtest src/test/bash/self_test.sh target/main/slamtest

# Tests the current version with itself.
test-with-src: build
	target/main/slamtest -l src/test/bash/self_test.sh target/main/slamtest
