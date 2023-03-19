module actions

import os
import freeflowuniverse.crystallib.texttools

const testpath = os.dir(@FILE) + '/testdata'

fn test_parse_into_blocks() {
	text := "!!git.link
source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/feasibility_study/Capabilities'
dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'"

	mut blocks := parse_into_blocks(text) or { panic('cant parse') }
	assert blocks.blocks.len == 1
	assert blocks.blocks[0].name == 'git.link'
	mut content_lines := blocks.blocks[0].content.split('\n')
	assert content_lines[1] == "source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/feasibility_study/Capabilities'"
	assert content_lines[2] == "dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'"

	// test separate keywords, indented
	text1 := "!!git.commit
	url:'https://github.com/threefoldfoundation/books'
	message:'link'"

	blocks = parse_into_blocks(text1) or { panic('cant parse') }
	assert blocks.blocks.len == 1
	assert blocks.blocks[0].name == 'git.commit'
	content_lines = blocks.blocks[0].content.split('\n')
	assert content_lines[1] == "url:'https://github.com/threefoldfoundation/books'"
	assert content_lines[2] == "message:'link'"
}

fn test_file_parse() {
	mut actionsmgr := get()
	actionsmgr.file_parse('${actions.testpath}/testfile.md') or { panic(err) }
	assert actionsmgr.actions.len == 10
}

fn test_dir_load() {
	mut actionsmgr := dir_parse(actions.testpath)!
	assert actionsmgr.actions.len == 11

	mut a := actionsmgr.actions.last()
	assert a.name == 'books.mdbook_develop'
	mut b := a.params.get('name') or { panic(err) }
	assert b == 'feasibility_study_internet'
}
