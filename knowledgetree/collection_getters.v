module knowledgetree

import freeflowuniverse.crystallib.texttools

pub fn (tree Tree) collectionnames() []string {
	mut res := []string{}
	for _, collection in tree.collections {
		res << collection.name
	}
	res.sort()
	return res
}

pub struct CollectionNotFound {
	Error
pub:
	pointer Pointer
	tree    &Tree
	msg     string
}

pub fn (err CollectionNotFound) msg() string {
	if err.msg.len > 0 {
		return err.msg
	}
	collectionnames := err.tree.collectionnames().map('- ${it}').join('\n')
	return '"Cannot find collection ${err.pointer} in tree.\nKnown Collections:\n${collectionnames}'
}

pub fn (tree Tree) collection_exists(name string) bool {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in tree.collections {
		return true
	}
	return false
}

// internal function
fn (mut tree Tree) collection_get_from_pointer(p Pointer) !&Collection {
	if p.tree.len > 0 && p.tree != tree.name {
		return CollectionNotFound{
			tree: &tree
			pointer: p
			msg: 'tree name was not empty and was not same as tree.\n${p}'
		}
	}
	mut ch := tree.collections[p.collection] or {
		return CollectionNotFound{
			tree: &tree
			pointer: p
		}
	}
	return ch
}

pub fn (mut tree Tree) collection_get(name string) !&Collection {
	return tree.collection_get_from_pointer(Pointer{ collection: name })!
}
