module doctree3

import freeflowuniverse.crystallib.data.doctree3.collection
import freeflowuniverse.crystallib.data.doctree3.collection.page
import freeflowuniverse.crystallib.data.doctree3.collection.file
import freeflowuniverse.crystallib.data.doctree3.pointer

pub fn (tree Tree) collection_get(name string) !&collection.Collection {
	col := tree.collections[name] or { return error('collection ${name} not found') }

	return col
}

// get the page from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree Tree) page_get(pointerstr string) !&page.Page {
	// console.print_debug("page get:${pointerstr}")
	p := pointer.pointer_new(pointerstr)!
	if p.name == '' || p.collection == '' {
		return ObjNotFound{
			info: 'bad pointer, name or collection should not be empty:\n${pointerstr}'
			collection: p.collection
			name: p.name
		}
	}

	col := tree.collections[p.collection] or { return CollectionNotFound{} }

	new_page := col.pages[p.name] or { return ObjNotFound{} }

	return new_page

	// // console.print_debug(p)
	// mut res := []&Page{}
	// for _, collection in tree.collections {
	// 	if p.collection == collection.name {
	// 		if collection.page_exists(p.name) {
	// 			res << collection.page_get(p.name) or { panic('BUG') }
	// 		}
	// 	}
	// }
	// if res.len == 1 {
	// 	return res[0]
	// } else {
	// 	return NoOrTooManyObjFound{
	// 		tree: &tree
	// 		pointer: p
	// 		nr: res.len
	// 	}
	// }
}

// get the page from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree Tree) image_get(pointerstr string) !&file.File {
	p := pointer.pointer_new(pointerstr)!
	// console.print_debug("collection:'$p.collection' name:'$p.name'")

	col := tree.collections[p.collection] or { return CollectionNotFound{
		pointer: p
	} }

	image := col.images[p.name] or { return ObjNotFound{} }

	return image
	// mut res := []&File{}
	// for _, collection in tree.collections {
	// 	// console.print_debug(collection.name)
	// 	if p.collection == collection.name {
	// 		// console.print_debug("in collection")
	// 		if collection.image_exists(pointerstr) {
	// 			res << collection.image_get(pointerstr) or { panic('BUG') }
	// 		}
	// 	}
	// }
	// if res.len == 1 {
	// 	return res[0]
	// } else {
	// 	return NoOrTooManyObjFound{
	// 		tree: &tree
	// 		pointer: p
	// 		nr: res.len
	// 	}
	// }
}

// get the file from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree Tree) file_get(pointerstr string) !&file.File {
	p := pointer.pointer_new(pointerstr)!

	col := tree.collections[p.collection] or { return CollectionNotFound{} }

	new_file := col.files[p.name] or { return ObjNotFound{} }

	return new_file
	// mut res := []&File{}
	// for _, collection in tree.collections {
	// 	if p.collection == collection.name {
	// 		if collection.file_exists(pointerstr) {
	// 			res << collection.file_get(pointerstr) or { panic('BUG') }
	// 		}
	// 	}
	// }
	// if res.len == 1 {
	// 	return res[0]
	// } else {
	// 	return NoOrTooManyObjFound{
	// 		tree: &tree
	// 		pointer: p
	// 		nr: res.len
	// 	}
	// }
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
