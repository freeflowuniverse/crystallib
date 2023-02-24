module builder


pub fn (mut node Node) done_set(key string, val string) ! {
	if key in node.done {
		if node.done[key] == val {
			return
		}
	}
	node.done[key] = val
	node.save()!
}

pub fn (mut node Node) done_get(key string) ?string {
	if key !in node.done {
		return none
	}
	return node.done[key]
}

// will return empty string if it doesnt exist
pub fn (mut node Node) done_get_str(key string) string {
	if key !in node.done {
		return ''
	}
	return node.done[key]
}

// will return 0 if it doesnt exist
pub fn (mut node Node) done_get_int(key string) int {
	if key !in node.done {
		return 0
	}
	return node.done[key].int()
}

pub fn (mut node Node) done_exists(key string) bool {
	return key in node.done
}

pub fn (mut node Node) done_print() {
	println('   DONE: ${node.name} ')
	for key, val in node.done {
		println('   . ${key} = ${val}')
	}
}

pub fn (mut node Node) done_reset() ! {
	node.done = map[string]string{}
	node.save()!
}
