module knowledgetree

import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.markdowndocs
import os

const collections_path = os.dir(@FILE) + '/testdata/collections'

const book1_path = os.dir(@FILE) + '/testdata/book1'

const book1_dest = os.dir(@FILE) + '/testdata/_book1'

fn config_tree() !Tree {
	mut s := spawner.new()
	mut tree := new(mut s)!

	mut col_examples := tree.collection_new(
		name: 'examples'
		path: knowledgetree.collections_path + '/examples'
		heal: true
	)!
	mut col_playground := tree.collection_new(
		name: 'playground'
		path: knowledgetree.collections_path + '/playground'
		heal: true
	)!
	mut col_rpc := tree.collection_new(
		name: 'rpc'
		path: knowledgetree.collections_path + '/rpc'
		heal: true
	)!
	mut col_server := tree.collection_new(
		name: 'server'
		path: knowledgetree.collections_path + '/server'
		heal: true
	)!

	tree.scan()!
	return tree
}

fn test_book_reset() {
	tree := config_tree()!
	mut book := book_new(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree: tree
	)!

	os.mkdir(knowledgetree.book1_dest)!
	assert os.exists(knowledgetree.book1_dest)
	book.reset()!
	assert !os.exists(knowledgetree.book1_dest)
}

fn test_book_load_summary() {
	tree := config_tree()!
	mut book := book_new(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree: tree
	)!
	book.load_summary()!

	assert book.doc_summary.items.len == 2
	assert book.doc_summary.items[1] is markdowndocs.Paragraph
	toc_paragraph := book.doc_summary.items[1] as markdowndocs.Paragraph
	toc_links := toc_paragraph.items.filter(it is markdowndocs.Link)
	assert toc_links.len == 49
}

fn test_book_fix_summary() {
	tree := config_tree()!
	mut book := book_new(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree: tree
	)!
	book.load_summary()!
	println('starting fix')
	book.fix_summary()!
	panic('hs')
}

fn test_book_new() {
	tree := config_tree()!
	mut book := book_new(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree: tree
	)!

	println(book)
	// panic('sh')
}

fn test_book_export() {
	tree := config_tree()!
	mut book := book_new(
		name: 'book1'
		path: knowledgetree.book1_path
		dest: knowledgetree.book1_dest
		tree: tree
	) or { panic(err) }
	// book.export() or {panic(err)}
}
