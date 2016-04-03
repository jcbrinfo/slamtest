run_test() {
	cp -- "$1" "$2"
	echo ---- >> "$2"
	echo "${@:3}" >> "$2"
	echo ---- >> "$2"
	echo "${tested_command[0]},${tested_command[1]}" >> "$2"
}
