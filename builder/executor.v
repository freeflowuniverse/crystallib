module builder

interface Executor {
	exec(cmd string) ?string
	exec_silent(cmd string) ?string
	file_write(path path.Path, text string) ?
	file_read(path path.Path) ?string
	file_exists(path path.Path) bool
	remove(path path.Path) ?
	download(source string, dest string) ?
	upload(source string, dest string) ?
	environ_get() ?map[string]string
	info() map[string]string
	ssh_shell(port int) ?
	list(path path.Path) ?[]string
	dir_exists(path path.Path) bool
}
