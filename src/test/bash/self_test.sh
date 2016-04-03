# A definition of the SlamTest’s `run_test` function for the self-tests.
# See: README.md

run_test() {
	local TMP_DIR=target/test/in
	local test_name="${1##*/}"

	rm -rf "${TMP_DIR}/${test_name}"
	mkdir -p -- "${TMP_DIR}"
	cp -a -t "${TMP_DIR}" -- "$1"
	(
		cd "${TMP_DIR}/${test_name}"
		set -- ../../../../target/main/slamtest
		. main
	) < "$1" > "$2" 2>&1
}
