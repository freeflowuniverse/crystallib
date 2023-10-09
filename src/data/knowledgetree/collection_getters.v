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
	msg     string
}

pub fn (err CollectionNotFound) msg() string {
	if err.msg.len > 0 {
		return err.msg
	}
	return '"Cannot find collection ${err.pointer} in tree.\n}'
}

pub fn (tree Tree) collection_exists(name string) bool {
	namelower := texttools.name_fix(name)
	if namelower in tree.collections {
		return true
	}
	return false
}

// internal function
fn (tree Tree) collection_get_from_pointer(p Pointer) !Collection {
	if p.tree.len > 0 && p.tree != tree.name {
		return CollectionNotFound{
			pointer: p
			msg: 'tree name was not empty and was not same as tree.\n${p}'
		}
	}
	mut ch := tree.collections[p.collection] or { return CollectionNotFound{
		pointer: p
	} }
	return *ch
}

pub fn (tree Tree) collection_get(name string) !Collection {
	name_fixed := texttools.name_fix(name)
	return tree.collection_get_from_pointer(Pointer{ collection: name_fixed })!
}
