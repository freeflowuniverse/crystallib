module knowledgetree

import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.data.markdowndocs
import os
import time

const (
	testdata_path     = os.dir(@FILE) + '/testdata'
	collections_path  = os.dir(@FILE) + '/testdata/collections'
	books_path        = os.dir(@FILE) + '/testdata/books'
	destinations_path = os.dir(@FILE) + '/testdata/destinations'
	tree_name         = 'mdbook_test_tree'
	book_source       = os.dir(@FILE) + '/testdata/book/source'
	book_destination  = os.dir(@FILE) + '/testdata/book/destination'

	test_books        = {
		'fruits_vegetables': TestBook{
			src_path: os.dir(@FILE) + '/testdata/books/fruits_vegetables/source'
			dest_path: os.dir(@FILE) + '/testdata/books/fruits_vegetables/destination'
		}
	}
)

struct TestBook {
	src_path      string
	dest_path     string
	summary_items []string
}

fn testsuite_begin() {
	if os.exists(knowledgetree.book_destination) {
		os.rmdir_all(knowledgetree.book_destination)!
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

fn test_book_create() {
	create_tree()!

	for name, test_book in knowledgetree.test_books {
		mut book := book_create(
			name: name
			path: test_book.src_path
			dest: test_book.dest_path
			tree_name: knowledgetree.tree_name
		)!
	}
}

fn test_book_reset() {
	create_tree()!

	for name, test_book in knowledgetree.test_books {
		mut book := book_create(
			name: 'book1'
			path: test_book.src_path
			dest: test_book.dest_path
			tree_name: knowledgetree.tree_name
		)!

		assert os.exists(test_book.dest_path)
		book.reset()!
		assert !os.exists(test_book.dest_path)
	}
}

fn test_book_load_summary() {
	create_tree()!

	for name, test_book in knowledgetree.test_books {
		mut book := book_create(
			name: name
			path: test_book.src_path
			dest: test_book.dest_path
			tree_name: knowledgetree.tree_name
		)!
		book.load_summary()!

		assert book.doc_summary.items.len == 2
		assert book.doc_summary.items[1] is markdowndocs.Paragraph
		toc_paragraph := book.doc_summary.items[1] as markdowndocs.Paragraph
		toc_links := toc_paragraph.items.filter(it is markdowndocs.Link)
		assert toc_links.len == 6
	}
}

fn test_book_fix_summary() {
	create_tree()!

	for name, test_book in knowledgetree.test_books {
		mut book := book_create(
			name: name
			path: test_book.src_path
			dest: test_book.dest_path
			tree_name: knowledgetree.tree_name
		)!
		book.load_summary()!
		summary_links_before := '${book.doc_summary.items}'
		book.fix_summary()!
		summary_links_after := '${book.doc_summary.items}'
		assert summary_links_before != summary_links_after
	}
}

fn test_book_export() {
	create_tree()!

	for name, test_book in knowledgetree.test_books {
		mut book := book_create(
			name: name
			path: test_book.src_path
			dest: test_book.dest_path
			tree_name: knowledgetree.tree_name
		)!
		book.export() or { panic(err) }
	}
}
