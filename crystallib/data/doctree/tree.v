module doctree

import log
// import v.embed_file

// import freeflowuniverse.crystallib.core.smartid

@[heap]
pub struct Tree {
pub:
	name string
pub mut:
	logger &log.Logger = &log.Log{
	level: .info
} @[skip; str: skip]
	playbooks map[string]&Collection
	// embedded_files  []embed_file.EmbedFileData // this where we have the templates for exporting a book
	state TreeState
	// macroprocessors []IMacroProcessor
	// spawner         &spawner.Spawner
	// context context.Context
	cid string
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
// 	// tree.playbooks = map[string]
// }

// add macroprocessor to the tree
// see interface IMacroProcessor for how macroprocessor needs to be implemented
// pub fn (mut tree Tree) macroprocessor_add(mp IMacroProcessor) ! {
// 	tree.macroprocessors << mp
// }

// fix all loaded tree
pub fn (mut tree Tree) fix() ! {
	if tree.state == .ok {
		return
	}
	for _, mut playbook in tree.playbooks {
		playbook.fix()!
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

// get the page from pointer string: $tree:$playbook:$name or
// $playbook:$name or $name
pub fn (tree Tree) page_get(pointerstr string) !&Page {
	p := pointer_new(pointerstr)!
	mut res := []&Page{}
	for _, playbook in tree.playbooks {
		if p.playbook == '' || p.playbook == playbook.name {
			if playbook.page_exists(pointerstr) {
				res << playbook.page_get(pointerstr) or { panic('BUG') }
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

// get the page from pointer string: $tree:$playbook:$name or
// $playbook:$name or $name
pub fn (tree Tree) image_get(pointerstr string) !&File {
	p := pointer_new(pointerstr)!
	// println("playbook:'$p.playbook' name:'$p.name'")
	mut res := []&File{}
	for _, playbook in tree.playbooks {
		// println(playbook.name)
		if p.playbook == '' || p.playbook == playbook.name {
			// println("in playbook")
			if playbook.image_exists(pointerstr) {
				res << playbook.image_get(pointerstr) or { panic('BUG') }
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

// get the file from pointer string: $tree:$playbook:$name or
// $playbook:$name or $name
pub fn (mut tree Tree) file_get(pointerstr string) !&File {
	p := pointer_new(pointerstr)!
	mut res := []&File{}
	for _, playbook in tree.playbooks {
		if p.playbook == '' || p.playbook == playbook.name {
			if playbook.file_exists(pointerstr) {
				res << playbook.file_get(pointerstr) or { panic('BUG') }
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
		if err is CollectionNotFound || err is ObjNotFound || err is NoOrTooManyObjFound {
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
		if err is CollectionNotFound || err is ObjNotFound || err is NoOrTooManyObjFound {
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
		if err is CollectionNotFound || err is ObjNotFound || err is NoOrTooManyObjFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}
