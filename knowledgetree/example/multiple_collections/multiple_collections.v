module main

import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.knowledgetree
import os

const collections_path = os.dir(@FILE) + '/collections'

const book_path = os.dir(@FILE) + '/book'

const book_dest = os.dir(@FILE) + '/dest'

pub fn main() {
	do() or { panic(err) }
}

pub fn do() ! {
	mut s := spawner.new()
	mut tree := knowledgetree.new(mut s)!

	mut col_fruits := tree.collection_new(
		name: 'fruits'
		path: collections_path + '/fruits'
		heal: false
	)!
	mut col_vegetables := tree.collection_new(
		name: 'vegetables'
		path: collections_path + '/vegetables'
		heal: false
	)!

	mut book := tree.book_new(
		name: 'Fruits & Vegetables'
		path: book_path
		dest: book_dest
		heal: true
	)!
	book.export()!
}
