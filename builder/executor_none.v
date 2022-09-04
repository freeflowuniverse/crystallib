module builder

//this is the empty executor to start from

[heap]
pub struct ExecutorNone {
	retry int = 1 
pub mut:
	debug bool
}

pub fn (mut executor ExecutorNone) exec(cmd string) ?string {
	return ""
}

pub fn (mut executor ExecutorNone) exec_silent(cmd string) ?string {
return ""
}

pub fn (mut executor ExecutorNone) file_write(path string, text string) ? {
	return
}

pub fn (mut executor ExecutorNone) file_read(path string) ?string {
	return ""
}

pub fn (mut executor ExecutorNone) file_exists(path string) bool {
	return false
}

pub fn (mut executor ExecutorNone) debug_on() {	
}

pub fn (mut executor ExecutorNone) debug_off() {
}

pub fn (mut executor ExecutorNone) delete(path string) ? {
}

pub fn (mut executor ExecutorNone) environ_get() ?map[string]string {
	return map[string]string{}
}

pub fn (mut executor ExecutorNone) info() map[string]string {
	return map[string]string{}
}

pub fn (mut executor ExecutorNone) upload(source string, dest string) ? {
}

pub fn (mut executor ExecutorNone) download(source string, dest string) ? {
}

pub fn (mut executor ExecutorNone) shell(cmd string) ? {
}

pub fn (mut executor ExecutorNone) list(path string) ?[]string {
	return []string{}
}

pub fn (mut executor ExecutorNone) dir_exists(path string) bool {
	return false
}
