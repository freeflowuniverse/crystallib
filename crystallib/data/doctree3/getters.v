module doctree3

import freeflowuniverse.crystallib.data.doctree3.collection
import freeflowuniverse.crystallib.data.doctree3.collection.data
import freeflowuniverse.crystallib.data.doctree3.pointer

pub fn (tree Tree) get_collection(name string) !&collection.Collection {
	col := tree.collections[name] or { return error('collection ${name} not found') }

	return col
}

pub fn (tree Tree) get_collection_with_pointer(p pointer.Pointer) !&collection.Collection {
	return tree.get_collection(p.collection) or {
		return CollectionNotFound{
			pointer: p
			msg: '${err}'
		}
	}
}

// get the page from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree Tree) get_page(pointerstr string) !&data.Page {
	p := pointer.pointer_new(text: pointerstr)!
	return tree.get_page_with_pointer(p)!
}

fn (tree Tree) get_page_with_pointer(p pointer.Pointer) !&data.Page {
	col := tree.get_collection_with_pointer(p)!
	new_page := col.get_page(p.name)!

	return new_page
}

// get the page from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree Tree) get_image(pointerstr string) !&data.File {
	p := pointer.pointer_new(text: pointerstr)!
	col := tree.get_collection_with_pointer(p)!
	image := col.get_image(p.name)!

	return image
}

// get the file from pointer string: $tree:$collection:$name or
// $collection:$name or $name
pub fn (tree Tree) get_file(pointerstr string) !&data.File {
	p := pointer.pointer_new(text: pointerstr)!
	col := tree.get_collection_with_pointer(p)!
	new_file := col.get_file(p.name)!

	return new_file
}

pub fn (tree Tree) page_exists(pointerstr string) bool {
	p := pointer.pointer_new(text: pointerstr) or { return false }
	col := tree.get_collection_with_pointer(p) or { return false }
	return col.page_exists(p.name)
}

pub fn (tree Tree) image_exists(pointerstr string) bool {
	p := pointer.pointer_new(text: pointerstr) or { return false }
	col := tree.get_collection_with_pointer(p) or { return false }
	return col.image_exists(p.name)
}

pub fn (tree Tree) file_exists(pointerstr string) bool {
	p := pointer.pointer_new(text: pointerstr) or { return false }
	col := tree.get_collection_with_pointer(p) or { return false }
	return col.file_exists(p.name)
}
