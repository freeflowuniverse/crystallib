module builder

pub struct DB {
pub mut:
	environment map[string]string
	node        Node
	db_dirname  string = 'builder'
}

pub struct DBArguments {
pub mut:
	node_args  NodeArguments
	db_dirname string = 'builder'
}

pub fn (db DB) db_path() string {
	return '${db.environment['HOME']}/.config/$db.db_dirname'
}

// get the node instance
pub fn db_new(args DBArguments) ?DB {
	node := node_get(args.node_args) or { panic(err) }
	mut db := DB{
		node: &node
		db_dirname: args.db_dirname
	}
	db.environment_load() ?
	// make sure the db path exists
	db.node.executor.exec('mkdir -p $db.db_path()') ?
	return db
}

// get the path of the config db
fn (mut db DB) db_key_path_get(key string) string {
	return '$db.db_path()/${key}.json'
}

// get remote environment arguments in memory
fn (mut db DB) environment_load() ? {
	db.environment = db.node.executor.environ_get() or { return error('can not load env') }
}

// return info from the db
pub fn (mut db DB) get(key string) ?string {
	fpath := db.db_key_path_get(key)
	return db.node.executor.file_read(fpath)
}

// save
pub fn (mut db DB) save(key string, val string) ? {
	fpath := db.db_key_path_get(key)
	db.node.executor.file_write(fpath, val) ?
}

pub fn (mut db DB) delete(key string) ? {
	if key.ends_with('*') {
		prefix := key.trim_right('*')
		files := db.node.executor.list(db.db_path()) ?
		for file in files {
			k := file.trim_right('.json')
			if k.starts_with(prefix) {
				fpath := db.db_key_path_get(k)
				db.node.executor.exec('rm $fpath') ?
			}
		}
	} else if key.starts_with('*') {
		suffix := key.trim_left('*')
		files := db.node.executor.list(db.db_path()) ?
		for file in files {
			k := file.trim_right('.json')
			if k.ends_with(suffix) {
				fpath := db.db_key_path_get(k)
				db.node.executor.remove(fpath) or { panic(err) }
			}
		}
	} else {
		fpath := db.db_key_path_get(key)
		db.node.executor.remove(fpath) ?
	}
}

// reset
pub fn (mut db DB) reset() ? {
	db.node.executor.exec('rm -rf $db.db_path() && mkdir $db.db_path()') or { panic(err) }
}
