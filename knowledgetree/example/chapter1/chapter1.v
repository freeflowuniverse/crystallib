module main

import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.knowledgetree
import os

const book1_path = os.dir(@FILE)

const collection_path = os.dir(@FILE)

const book1_dest = os.dir(@FILE) + '/testdata/_book1'

pub fn main() {
	do() or { panic(err) }
}

pub fn do() ! {
	mut s := spawner.new()
	mut tree := knowledgetree.new(mut s)!

	mut col_examples := tree.collection_new(
		name: 'examples'
		path: collection_path
		heal: true
	)!
	// mut col_playground := tree.collection_new(
	// 	name: 'playground'
	// 	path: knowledgetree.collections_path + '/playground'
	// 	heal: true
	// )!
	// mut col_rpc := tree.collection_new(
	// 	name: 'rpc'
	// 	path: knowledgetree.collections_path + '/rpc'
	// 	heal: true
	// )!
	// mut col_server := tree.collection_new(
	// 	name: 'server'
	// 	path: knowledgetree.collections_path + '/server'
	// 	heal: true
	// )!

	mut book := tree.book_new(name: 'book1', path: book1_path, dest: book1_dest)!
	book.export()!
}
