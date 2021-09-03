module builder

interface Executor {
	exec(cmd string) ?string
	exec_silent(cmd string) ?string
	file_write(path string, text string) ?
	file_read(path string) ?string
	file_exists(path string) bool
	remove(path string) ?
	download(source string, dest string) ?
	upload(source string, dest string) ?
	environ_get() ?map[string]string
	info() map[string]string
	ssh_shell(port int) ?
	list(path string) ?[]string
	dir_exists(path string) bool
}
