module wikicreator

[heap]
struct WikiCreator {
pub mut:
	pages []string
}

fn init2() WikiCreator {
	mut wc := WikiCreator{}
	return wc
}

const creator = init2()

pub fn get() &WikiCreator {
	return &wikicreator.creator
}

// init instance of planner
pub fn new(path string, path_out string) &WikiCreator {
	// reuse single object
	mut wc := get()
	wc.do(path, path_out) or { panic(err) }
	return wc
}
