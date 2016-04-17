# A definition of the SlamTest’s `run_test` function for the self-tests.
# See: README.md

run_test() {
	local TMP_DIR="${2%/*/*}"/in
	local test_name="${1##*/}"

	rm -rf "${TMP_DIR}/${test_name}"
	mkdir -p -- "${TMP_DIR}"
	cp -a -t "${TMP_DIR}" -- "$1"
	(
		# Force directory listing order, so the output of the test does not
		# depend on user settings.
		LC_COLLATE=C

		cd "${TMP_DIR}/${test_name}"
		set -- ../../../../target/main/slamtest
		. main
	) < "$1" > "$2" 2>&1
}
