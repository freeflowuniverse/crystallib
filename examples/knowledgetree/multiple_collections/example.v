module main

import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.data.knowledgetree
import os

const (
	tree_name        = 'fruits_and_veggies'
	collections_path = os.dir(@FILE) + '/collections'
	book_path        = os.dir(@FILE) + '/book'
	book_dest        = os.dir(@FILE) + '/dest'
)

pub fn main() {
	do() or { panic(err) }
}

pub fn do() ! {
	mut tree := knowledgetree.new(name: tree_name)!
	tree.scan(
		name: tree_name
		path: collections_path
		heal: true
	)!

	mut book := knowledgetree.book_generate(
		name: 'Fruits & Vegetables'
		tree: tree
		path: book_path
		dest: book_dest
	)!
	book.export()!
	book.read()!
}
