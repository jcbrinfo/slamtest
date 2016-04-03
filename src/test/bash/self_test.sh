# A definition of the SlamTest’s `run_test` function for the self-tests.
# See: README.md

mkdir -p -- target/test/in

run_test() {
	cp -a -t target/test/in -- "$1"
	(
		cd "${TMP_DIR}/${1##*/}"
		set -- ../../../../target/main/slamtest
		. main
	) < "$1" > "$2" 2>&1
}
