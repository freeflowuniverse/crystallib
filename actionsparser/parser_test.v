module actionsparser

import os

const testpath = os.dir(@FILE) + '/testdata'

const text = "
//select the book, can come from context as has been set before
//now every person added will be added in this book
!!actor.select aaa.people

//delete everything as found in current book
!!person_delete cid:1gt

!!person_define
  //is optional will be filled in automatically, but maybe we want to update
  cid: '1gt' 
  //name as selected in this group, can be used to find someone back
  name: fatayera
	firstname: 'Adnan'
	lastname: 'Fatayerji'
	description: 'Head of Business Development'
  email: 'adnan@threefold.io,fatayera@threefold.io'

!!circle_link
//can define as cid or as name, name needs to be in same book
  person: '1gt'
  //can define as cid or as name
  circle:tftech         
  role:'stakeholder'
	description:''
  //is the name as given to the link
	name:'vpsales'        

!!people.circle_comment cid:'1g' 
    comment:
      this is a comment
      can be multiline 

!!circle_comment cid:'1g' 
    comment:
      another comment

!!digital_payment_add 
  person:fatayera
	name: 'TF Wallet'
	blockchain: 'stellar'
	account: ''
	description: 'TF Wallet for TFT' 
	preferred: false

!!actor.select aaa.test

!!test_action
	key: value

!!actor.select bbb.people

!!person_define
  cid: 'eg'
  name: despiegk

!!book.select bbb
"

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
	mut actionsmgr := new(path: '${actionsparser.testpath}/testfile.md') or { panic(err) }
	assert actionsmgr.unsorted.len == 0
	assert actionsmgr.ok.len == 10
}

fn test_dir_load() {
	mut actionsmgr := new(path: '${actionsparser.testpath}') or { panic(err) }
	assert actionsmgr.ok.len == 11

	mut a := actionsmgr.ok.last()
	assert a.name == 'books.mdbook_develop'
	mut b := a.params.get('name') or { panic(err) }
	assert b == 'feasibility_study_internet'
}

fn test_text_add() ! {
	mut parser := new() or { panic(err) }
	parser.text_add(text)!

	// all actions should be unsorted initially
	assert parser.unsorted.len == 8
	assert parser.ok.len == 0
	assert parser.skipped.len == 0
	assert parser.error.len == 0

	// confirm first action
	mut action := parser.unsorted[0]
	assert action.name == 'aaa.people.person_delete'
	mut param := action.params.get('cid') or { panic(err) }
	assert param == '1gt'

	// confirm second action
	action = parser.unsorted[1]
	assert action.name == 'aaa.people.person_define'
	param = action.params.get('name') or { panic(err) }
	assert param == 'fatayera'

	// confirm last action
	action = parser.unsorted.last()
	assert action.name == 'bbb.people.person_define'
	param = action.params.get('name') or { panic(err) }
	assert param == 'despiegk'

}
