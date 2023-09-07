module knowledgetree

import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.markdowndocs
import os

const (
	collections_path = os.dir(@FILE) + '/testdata/collections'
	tree_name = 'mdbook_test_tree'
	book1_path = os.dir(@FILE) + '/testdata/book1'
	book1_dest = os.dir(@FILE) + '/testdata/_book1'
)

fn create_tree() ! {
	mut s := spawner.new()
	new(name: tree_name)!
	scan(
		name: tree_name
		path: collections_path
	)!
	rlock knowledgetrees {
		println('debugz:')
		println(knowledgetrees[tree_name].collections)
	}
}

fn test_book_reset() {
	create_tree()!
	mut book := book_create(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree_name: tree_name
	)!

	os.mkdir(knowledgetree.book1_dest)!
	assert os.exists(knowledgetree.book1_dest)
	book.reset()!
	assert !os.exists(knowledgetree.book1_dest)
}

fn test_book_load_summary() {
	create_tree()!
	mut book := book_create(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree_name: tree_name
	)!
	book.load_summary()!

	assert book.doc_summary.items.len == 2
	assert book.doc_summary.items[1] is markdowndocs.Paragraph
	toc_paragraph := book.doc_summary.items[1] as markdowndocs.Paragraph
	toc_links := toc_paragraph.items.filter(it is markdowndocs.Link)
	assert toc_links.len == 49
}

fn test_book_fix_summary() {
	create_tree()!
	mut book := book_create(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree_name: tree_name
	)!
	book.load_summary()!
	println('starting fix')
	book.fix_summary()!
	panic('hs')
}

fn test_book_create() {
	create_tree()!
	mut book := book_create(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree_name: tree_name
	)!

	println(book)
	// panic('sh')
}

fn test_book_export() {
	create_tree()!
	mut book := book_create(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree_name: tree_name
	) or { panic(err) }
	// book.export() or {panic(err)}
}
