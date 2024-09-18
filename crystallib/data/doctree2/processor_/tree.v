module processor

@[heap]
pub struct Tree {
pub:
	name string
pub mut:
	collections map[string]&Collection
	defs        map[string]&Page
	state       TreeState
	// context context.Context
	cid string = '000'
}

pub enum TreeState {
	init
	ok
	error
}

// the unique key to remember a tree .
// is unique per circle (based on cid)
pub fn (tree Tree) key() string {
	return '${tree.cid}__${tree.name}'
}

// pub fn (mut tree Tree) reset() ! {
// 	// tree.collections = map[string]
// }

// add macroprocessor to the tree
// see interface IMacroProcessor for how macroprocessor needs to be implemented
// pub fn (mut tree Tree) macroprocessor_add(mp IMacroProcessor) ! {
// 	tree.macroprocessors << mp
// }

// fix all loaded tree
// pub fn (mut tree Tree) fix() ! {
// 	if tree.state == .ok {
// 		return
// 	}
// 	for _, mut collection in tree.collections {
// 		collection.fix()!
// 	}
// }

// the next is our custom error for objects not found
pub struct NoOrTooManyObjFound {
	Error
pub:
	tree    &Tree
	pointer Pointer
	nr      int
}

pub fn (err NoOrTooManyObjFound) msg() string {
	if err.nr > 0 {
		return 'Too many obj found for ${err.tree.name}. Pointer: ${err.pointer}'
	}
	return 'No obj found for ${err.tree.name}. Pointer: ${err.pointer}'
}

// get the page from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree Tree) page_get(pointerstr string) !&Page {
	// console.print_debug("page get:${pointerstr}")
	p := pointer_new(pointerstr)!
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
pub fn (tree Tree) image_get(pointerstr string) !&File {
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
pub fn (tree Tree) file_get(pointerstr string) !&File {
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
pub fn (tree Tree) page_exists(name string) bool {
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
pub fn (tree Tree) image_exists(name string) bool {
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
pub fn (tree Tree) file_exists(name string) bool {
	_ := tree.file_get(name) or {
		if err is CollectionNotFound || err is ObjNotFound || err is NoOrTooManyObjFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}
