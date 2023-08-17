module knowledgetree

import log
import v.embed_file

[heap]
pub struct Tree {
pub:
	name string
pub mut:
	logger         log.Logger
	pointers       map[string]&Pointer
	collections    map[string]&Collection
	books          map[string]&MDBook
	embedded_files []embed_file.EmbedFileData // this where we have the templates for exporting a book
	state          TreeState
}

pub enum TreeState {
	init
	ok
	error
}

fn (mut tree Tree) init() ! {
	tree.embedded_files << $embed_file('template/css/print.css')
	tree.embedded_files << $embed_file('template/css/variables.css')
	tree.embedded_files << $embed_file('template/mermaid-init.js')
	tree.embedded_files << $embed_file('template/mermaid.min.js')
}

// reset all, just to make sure we regenerate fresh
pub fn (mut tree Tree) reset() ! {
	for _, mut book in tree.books {
		book.reset()!
	}
}

// export the mdbooks to html
pub fn (mut tree Tree) export() ! {
	tree.reset()! // make sure we start from scratch
	tree.fix()!
	for _, mut book in tree.books {
		book.export()!
	}
}

// fix all loaded tree
pub fn (mut tree Tree) fix() ! {
	if tree.state == .ok {
		return
	}
	for _, mut collection in tree.collections {
		collection.fix()!
	}
}

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
pub fn (mut tree Tree) page_get(pointerstr string) !&Page {
	p := pointer_new(pointerstr)!
	mut res := []&Page{}
	for _, collection in tree.collections {
		if p.collection == '' || p.collection == collection.name {
			if collection.page_exists(pointerstr) {
				res << collection.page_get(pointerstr) or { panic('BUG') }
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
pub fn (mut tree Tree) image_get(pointerstr string) !&File {
	p := pointer_new(pointerstr)!
	// println("collection:'$p.collection' name:'$p.name'")
	mut res := []&File{}
	for _, collection in tree.collections {
		// println(collection.name)
		if p.collection == '' || p.collection == collection.name {
			// println("in collection")
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
pub fn (mut tree Tree) file_get(pointerstr string) !&File {
	p := pointer_new(pointerstr)!
	mut res := []&File{}
	for _, collection in tree.collections {
		if p.collection == '' || p.collection == collection.name {
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
pub fn (mut tree Tree) page_exists(name string) bool {
	_ := tree.page_get(name) or {
		if err is CollectionNotFound || err is CollectionObjNotFound || err is NoOrTooManyObjFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

// exists or too many
pub fn (mut tree Tree) image_exists(name string) bool {
	_ := tree.image_get(name) or {
		if err is CollectionNotFound || err is CollectionObjNotFound || err is NoOrTooManyObjFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

// exists or too many
pub fn (mut tree Tree) file_exists(name string) bool {
	_ := tree.file_get(name) or {
		if err is CollectionNotFound || err is CollectionObjNotFound || err is NoOrTooManyObjFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}
