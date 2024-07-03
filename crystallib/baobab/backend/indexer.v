module backend

import json
import db.sqlite
import freeflowuniverse.crystallib.core.texttools

pub struct Indexer {
	db sqlite.DB
}

@[table: 'root_objects']
pub struct RootObject {
	id    int    @[primary; sql: serial] // unique serial root object id
	table string // name of table root object is in
}

pub fn new_indexer(db_path string) !Indexer {
	mut backend := Indexer{
		db: sqlite.connect(db_path)!
	}

	sql backend.db {
		create table RootObject
	}!

	return backend
}

// new creates a new root object entry in the root_objects table,
// and the table belonging to the type of root object with columns for index fields
pub fn (mut backend Indexer) new[T](obj T) ! {
	table_name := get_table_name[T]()

	row := RootObject{
		table: table_name
	}

	sql backend.db {
		insert row into RootObject
	}!

	// id := backend.db.last_id()

	// create table for root object if it doesn't exist
	backend.create_root_struct_table[T]()!

	obj_encoded := json.encode(obj)
	// insert root object into its table
	mut indices := ['data']
	obj_val := "'${obj_encoded.replace("'", "''")}'"
	mut values := [obj_val]
	$for field in T.fields {
		$if field.name == 'id' {
			indices << '${field.name}'
			val := obj.$(field.name)
			values << "'${val}'"
		}
		$if field.typ is string {
			if field.attrs.contains('index') {
				indices << '${field.name}'
				val := obj.$(field.name)
				values << "'${val}'"
			}
		}
	}
	insert_query := 'insert into ${table_name} (${indices.join(',')}) values (${values.join(',')})'
	backend.db.exec(insert_query) or {
		return error('Error inserting object ${obj} into table ${table_name}\n${err}')
	}

	// return id
}

// save the session to redis & mem
pub fn (mut backend Indexer) set[T](obj T) ! {
	table_name := get_table_name[T]()
	obj_encoded := json.encode(obj)
	// todo: check table and entry exists
	backend.db.exec("update ${table_name} set data='${obj_encoded}' where id=${obj.id}")!
}

// save the session to redis & mem
pub fn (mut backend Indexer) delete[T](id u32) ! {
	table_name := get_table_name[T]()
	// todo: check table and entry exists
	backend.db.exec('delete from ${table_name} where id=${id}')!
	backend.db.exec('delete from root_objects where id=${id}')!
}

// save the session to redis & mem
pub fn (mut backend Indexer) get[T](id string) !T {
	table_name := get_table_name[T]()

	// check root object and table exists
	result0 := backend.db.exec('select * from ${table_name} where id=${id}')!
	if result0.len == 0 {
		return error('Root object not found')
	} else if result0.len > 1 {
		panic('More than one result with same id found. This should never happen.')
	}

	responses := backend.db.exec('select * from ${table_name} where id=${id}') or { panic(err) }
	if responses.len == 0 {
		panic('Root object found in root objects but not in object table. This should never happen.')
	}
	if responses.len > 1 {
		panic('More than one result with same id found. This should never happen.')
	}

	return json.decode(T, responses[0].vals[1])
}

// save the session to redis & mem
pub fn (mut backend Indexer) list[T]() ![]T {
	if !is_root_struct[T]() {
		return error('List method can only be used for root structs')
	}

	table_name := get_table_name[T]()

	responses := backend.db.exec('select * from ${table_name}') or { panic(err) }
	return responses.map(json.decode(T, it.vals[1]) or { panic('JSON decode failed.') })
}

// from and to for int f64 time etc.
@[params]
pub struct FilterParams {
	// indices     map[string]string // map of index values that are being filtered by, in order of priority.
	limit       int  // limit to the number of values to be returned, in order of priority
	fuzzy       bool // if fuzzy matching is enabled in matching indices
	matches_all bool // if results should match all indices or any
}

// filter lists root objects of type T that match provided index parameters and params.
pub fn (mut backend Indexer) filter[T, D](filter D, params FilterParams) ![]int {
	table_name := get_table_name[T]()
	table_indices := backend.get_table_indices(table_name) or { panic(err) }

	$for field in D.fields {
		if field.name !in table_indices {
			return error('Index ${field.name} not found for root struct ${typeof[T]()}')
		}
	}
	mut select_stmt := 'select * from ${table_name}'

	// $if D.fields.len > 0 {
	select_stmt += ' where'
	$for field in D.fields {
		val := filter.$(field.name)
		select_stmt += " ${field.name} == '${val}'"
	}
	// }

	// console.print_debug(select_stmt)
	responses := backend.db.exec(select_stmt) or { panic(err) }
	ids := responses.map(it.vals[0])
	// objects := responses.map(json.decode(T, it.vals[1]) or { panic(err) })
	return if params.limit == 0 { ids.map(it.int()) } else { ids.map(it.int())[..params.limit] }
}

// create_root_struct_table creates a table for a root_struct with columns for each index field
fn (mut backend Indexer) create_root_struct_table[T]() ! {
	table_name := get_table_name[T]()
	mut columns := ['id integer primary key AUTOINCREMENT', 'data TEXT']

	// create columns for fields marked as index
	$for field in T.fields {
		if field.attrs.contains('index') {
			columns << '${field.name} TEXT'
		}
	}
	create_query := 'create table if not exists ${table_name} (${columns.join(',')})'
	backend.db.exec(create_query)!
}

fn (mut backend Indexer) get_table_indices(table_name string) ![]string {
	table_info := backend.db.exec('pragma table_info(${table_name});')!
	return table_info[1..].map(it.vals[1])
}

// get_table_name returns the name of the table belonging to a root struct
fn get_table_name[T]() string {
	mut table_name := ''
	$for attr in T.attributes {
		if attr.name == 'table' && attr.arg.len > 0 {
			table_name = attr.arg
		}
	}
	if table_name == '' {
		table_name = typeof[T]()
	}
	table_name = texttools.name_fix(table_name)
	table_name = table_name.replace('.', '_')
	return table_name
}

// is_root_struct returns whether a given generic is a root struct
fn is_root_struct[T]() bool {
	$for attr in T.attributes {
		if attr.name == 'root_struct' {
			return true
		}
	}
	return false
}
