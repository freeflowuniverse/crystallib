module osal

import freeflowuniverse.crystallib.core.dbfs

pub fn done_set(key string, val string) ! {
	mut collection := dbfs.get()!
	mut db := collection.get('todo')!
	db.set(key, val)!
}

pub fn done_get(key string) ?string {
	mut collection := dbfs.get() or { panic('Failed to get DB Collection') }
	mut db := collection.get('todo') or { panic('Failed to get DB') }
	return db.get(key) or { return none }
}

pub fn done_delete(key string) ! {
	mut collection := dbfs.get()!
	mut db := collection.get('todo')!
	db.delete(key)!
}

pub fn done_get_str(key string) string {
	val := done_get(key) or { panic(err) }
	return val
}

pub fn done_get_int(key string) int {
	val := done_get(key) or { panic(err) }
	return val.int()
}

pub fn done_exists(key string) bool {
	mut collection := dbfs.get() or { panic('Failed to get DB Collection') }
	mut db := collection.get('todo') or { panic('Failed to get DB') }
	return db.exists(key)
}

pub fn done_print() ! {
	mut collection := dbfs.get()!
	mut db := collection.get('todo')!
	mut output := 'DONE:\n'
	for key in db.keys('')! {
		output += '\t${key} = ${done_get_str(key)}\n'
	}
	println('${output}')
}

pub fn done_reset() ! {
	mut collection := dbfs.get()!
	mut db := collection.get('todo')!
	db.destroy()!
}
