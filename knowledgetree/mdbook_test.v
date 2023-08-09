module knowledgetree

import os

const testpath = os.dir(@FILE) + '/testdata/collections'

fn test_book_new() {
	mut tree := new()!

	mut col_examples := tree.collection_new(name:'examples', path: testpath+'/examples')!
	mut col_playground := tree.collection_new(name:'playground', path: testpath+'/playground')!
	mut col_rpc := tree.collection_new(name:'rpc', path: testpath+'/rpc')!

	mut book := tree.book_new(name: 'book1', path: testpath)!
}