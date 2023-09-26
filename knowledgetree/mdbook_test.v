module knowledgetree

import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.markdowndocs
import os

const (
	testdata_path     = os.dir(@FILE) + '/testdata'
	collections_path  = os.dir(@FILE) + '/testdata/collections'
	books_path        = os.dir(@FILE) + '/testdata/books'
	destinations_path = os.dir(@FILE) + '/testdata/destinations'
	tree_name         = 'mdbook_test_tree'
	book1_path        = os.dir(@FILE) + '/testdata/book1'
	book1_dest        = os.dir(@FILE) + '/testdata/_book1'
)

fn testsuite_begin() {
	if os.exists(knowledgetree.book1_dest) {
		os.rmdir_all(knowledgetree.book1_dest)!
	}
	os.cp_all(knowledgetree.testdata_path, '${knowledgetree.testdata_path}_previous',
		true)!
}

fn testsuite_end() {
	os.rmdir_all(knowledgetree.testdata_path)!
	os.mv('${knowledgetree.testdata_path}_previous', knowledgetree.testdata_path)!
}

fn create_tree() ! {
	new(name: knowledgetree.tree_name)!
	scan(
		name: knowledgetree.tree_name
		path: knowledgetree.collections_path
	)!
}

fn test_book_reset() {
	create_tree()!
	mut book := book_create(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree_name: knowledgetree.tree_name
	)!

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
		tree_name: knowledgetree.tree_name
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
		path: '${knowledgetree.books_path}/fruits_vegetables'
		dest: '${knowledgetree.destinations_path}/fruits_vegetables'
		tree_name: knowledgetree.tree_name
	)!
	book.load_summary()!
	summary_links_before := '${book.doc_summary.items}'
	book.fix_summary()!
	summary_links_after := '${book.doc_summary.items}'
	assert summary_links_before != summary_links_after
}

fn test_book_create() {
	create_tree()!
	mut book := book_create(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree_name: knowledgetree.tree_name
	)!
}

fn test_book_export() {
	create_tree()!
	mut book := book_create(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree_name: knowledgetree.tree_name
	) or { panic(err) }
	book.export() or { panic(err) }
}
