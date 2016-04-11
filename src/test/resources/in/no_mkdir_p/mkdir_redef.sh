mkdir() {
	if [ "$1" = -p ]; then
		return 42
	else
		command mkdir "$@"
	fi
}
