module osal

import freeflowuniverse.crystallib.data.fskvs

pub fn done_set(key string, val string) ! {
	mut db := fskvs.new(name: 'todo')!
	db.set(key, val)!
}

pub fn done_get(key string) ?string {
	mut db := fskvs.new(name: 'todo') or { return none }
	return db.get(key) or { return none }
}

pub fn done_delete(key string) ! {
	mut db := fskvs.new(name: 'todo')!
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
	mut db := fskvs.new(name: 'todo') or { return false }
	return db.exists(key)
}

pub fn done_print() ! {
	mut db := fskvs.new(name: 'todo')!
	mut output := 'DONE:\n'
	for key in db.keys()! {
		output += '\t${key} = ${done_get_str(key)}\n'
	}
	println('${output}')
}

pub fn done_reset() ! {
	mut db := fskvs.new(name: 'todo')!
	db.destroy()!
}
