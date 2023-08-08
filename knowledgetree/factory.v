module knowledgetree

pub fn new() !Tree {
	mut t:= Tree{}
	t.init()! //initialize mdbooks logic
	return t
}
