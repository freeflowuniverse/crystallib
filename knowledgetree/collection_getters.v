module knowledgetree

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
	book    &Book
	msg     string
}

pub fn (err CollectionNotFound) msg() string {
	if err.msg.len > 0 {
		return err.msg
	}
	collectionnames := err.book.collectionnames().join('\n- ')
	return '"Cannot not find collection from book:${err.book.name}.\nPointer: ${err.pointer}.\nKnown Collections:\n${collectionnames}'
}

pub fn (mut book Book) collection_exists(name string) bool {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in book.collections {
		return true
	}
	return false
}


// internal function
fn (mut tree Tree) collection_get_from_pointer(p Pointer) !&Collection {
	if p.tree != '' && p.tree != tree.name {
		return CollectionNotFound{
			tree: &tree
			pointer: p
			msg: 'tree name was not empty and was not same as tree.\n${p}'
		}
	}
	mut ch := tree.collections[p.collection] or { return CollectionNotFound{
		tree: &tree
		pointer: p
	} }
	return ch
}

pub fn (mut tree Tree) collection_get(name string) !&Collection {
	p := pointer_new(name)!
	return tree.collection_get_from_pointer(p)!
}
