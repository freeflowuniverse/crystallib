module installers

//TODO: implement done using redis (just a hset)

pub fn  done_set(key string, val string) ! {
	if key in node.done {
		if node.done[key] == val {
			return
		}
	}
	node.done[key] = val
	node.save()!
}

pub fn  done_get(key string) ?string {
	if key !in node.done {
		return none
	}
	return node.done[key]
}

// will return empty string if it doesnt exist
pub fn  done_get_str(key string) string {
	if key !in node.done {
		return ''
	}
	return node.done[key]
}

// will return 0 if it doesnt exist
pub fn  done_get_int(key string) int {
	if key !in node.done {
		return 0
	}
	return node.done[key].int()
}

pub fn  done_exists(key string) bool {
	return key in node.done
}

pub fn  done_print() {
	println('   DONE: ${node.name} ')
	for key, val in node.done {
		println('   . ${key} = ${val}')
	}
}

pub fn  done_reset() ! {
	node.done = map[string]string{}
	node.save()!
}
