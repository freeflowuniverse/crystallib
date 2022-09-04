module builder

enum DBState{
	init
	ok
}

fn (mut node Node) db_check()? {
	if node.db_state==.init{
		// make sure the db path exists
		node.exec('mkdir -p $node.db_path') ?
		node.db_state = .ok
	}
}

// get the path of the config db
fn (mut node Node) db_key_path_get(key string) string {
	node.db_check() or {panic(err)}
	if node.db_path == '' {
		panic('path canot be empty')
	}
	return '$node.db_path/$key'
}

// return info from the db
pub fn (mut node Node) db_get(key string) ?string {
	fpath := node.db_key_path_get(key)
	return node.file_read(fpath)
}

pub fn (mut node Node) db_exists(key string) bool {
	v := node.db_get(key) or { '' }
	if v == '' {
		return false
	}
	return true
}

// save
pub fn (mut node Node) db_set(key string, val string) ? {
	fpath := node.db_key_path_get(key)
	node.file_write(fpath, val)?
}

pub fn (mut node Node) db_delete(key string) ? {
	if key.ends_with('*') {
		prefix := key.trim_right('*')
		files := node.list(node.db_path)?
		for file in files {
			if file.starts_with(prefix) {
				fpath := node.db_key_path_get(file)
				node.exec('rm $fpath')?
			}
		}
	} else if key.starts_with('*') {
		suffix := key.trim_left('*')
		files := node.list(node.db_path)?
		for file in files {
			if file.ends_with(suffix) {
				fpath := node.db_key_path_get(file)
				node.delete(fpath) or { panic(err) }
			}
		}
	} else {
		fpath := node.db_key_path_get(key)
		node.delete(fpath)?
	}
}

// reset
pub fn (mut node Node) db_reset() ? {
	node.exec('rm -rf $node.db_path && mkdir -p $node.db_path') or { panic(err) }
}
