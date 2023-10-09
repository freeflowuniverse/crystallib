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
	knowledgetree.new(name: tree_name)!
	knowledgetree.scan(
		name: tree_name
		path: collections_path
		heal: true
	)!

	mut book := knowledgetree.book_create(
		name: 'Fruits & Vegetables'
		tree_name: tree_name
		path: book_path
		dest: book_dest
	)!
	book.export()!
}
