module knowledgetree

import os

const testpath = os.dir(@FILE) + '/testdata/book1'

fn test_book_new() {
	mut tree := new()!
	mut book := tree.book_new(name: 'book1', path: testpath)!
}