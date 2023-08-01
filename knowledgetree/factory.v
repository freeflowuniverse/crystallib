module knowledgetree

pub fn new() !Tree {
	mut t:= Tree{}
	t.mdbooks_init()! //initialize mdbooks logic
	return t
}
