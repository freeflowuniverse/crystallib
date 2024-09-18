module server

import freeflowuniverse.crystallib.data.server

@[heap]
pub struct DocTree {
pub:
	name string
pub mut:
	collections map[string]&Collection
	defs        map[string]&server.Pointer
	state       TreeState
	cid string = '000'
}

pub enum TreeState {
	init
	ok
	error
}

// the unique key to remember a tree .
// is unique per circle (based on cid)
pub fn (tree DocTree) key() string {
	return '${tree.cid}__${tree.name}'
}


// get the page from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree DocTree) page_get(pointerstr string) !&Page {
	console.print_debug("page get:${pointerstr}")
	p := server.pointer_new(pointerstr)!
	if p.name == '' || p.collection == '' {
		return ObjNotFound{
			info: 'bad pointer, name or collection should not be empty:\n${pointerstr}'
			collection: p.collection
			name: p.name
		}
	}
	// console.print_debug(p)
	mut res := []&Page{}
	for _, collection in tree.collections {
		if p.collection == collection.name {
			if collection.page_exists(p.name) {
				res << collection.page_get(p.name) or { panic('BUG') }
			}
		}
	}
	if res.len == 1 {
		return res[0]
	} else {
		return NoOrTooManyObjFound{
			tree: &tree
			pointer: p
			nr: res.len
		}
	}
}

// get the page from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree DocTree) image_get(pointerstr string) !&File {
	p := pointer_new(pointerstr)!
	// console.print_debug("collection:'$p.collection' name:'$p.name'")
	mut res := []&File{}
	for _, collection in tree.collections {
		// console.print_debug(collection.name)
		if p.collection == collection.name {
			// console.print_debug("in collection")
			if collection.image_exists(pointerstr) {
				res << collection.image_get(pointerstr) or { panic('BUG') }
			}
		}
	}
	if res.len == 1 {
		return res[0]
	} else {
		return NoOrTooManyObjFound{
			tree: &tree
			pointer: p
			nr: res.len
		}
	}
}

// get the file from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree DocTree) file_get(pointerstr string) !&File {
	p := pointer_new(pointerstr)!
	mut res := []&File{}
	for _, collection in tree.collections {
		if p.collection == collection.name {
			if collection.file_exists(pointerstr) {
				res << collection.file_get(pointerstr) or { panic('BUG') }
			}
		}
	}
	if res.len == 1 {
		return res[0]
	} else {
		return NoOrTooManyObjFound{
			tree: &tree
			pointer: p
			nr: res.len
		}
	}
}

// exists or too many
pub fn (tree DocTree) page_exists(name string) bool {
	_ := tree.page_get(name) or {
		if err is CollectionNotFound || err is ObjNotFound || err is NoOrTooManyObjFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

// exists or too many
pub fn (tree DocTree) image_exists(name string) bool {
	_ := tree.image_get(name) or {
		if err is CollectionNotFound || err is ObjNotFound || err is NoOrTooManyObjFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

// exists or too many
pub fn (tree DocTree) file_exists(name string) bool {
	_ := tree.file_get(name) or {
		if err is CollectionNotFound || err is ObjNotFound || err is NoOrTooManyObjFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}
