module actionsparser

import os

const testpath = os.dir(@FILE) + '/testdata'

const text = "
//select the book, can come from context as has been set before
//now every person added will be added in this book
!!actor_select people

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

!!select_actor test

!!test_action
	key: value

!!actor_select bbb.people

!!person_define
  cid: 'eg'
  name: despiegk

!!select_book bbb
"

fn test_parse_into_blocks() {
	md := "!!git.link
		source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/feasibility_study/Capabilities'
		dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'"

	mut blocks := parse_into_blocks(md)!
	assert blocks.blocks.len == 1
	assert blocks.blocks[0].name == 'git.link'
	mut content_lines := blocks.blocks[0].content.split('\n')
	assert content_lines[1] == "source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/feasibility_study/Capabilities'"
	assert content_lines[2] == "dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'"

	// test separate keywords, indented
	md_2 := "!!git.commit
	url:'https://github.com/threefoldfoundation/books'
	message:'link'"

	blocks = parse_into_blocks(md_2)!
	assert blocks.blocks.len == 1
	assert blocks.blocks[0].name == 'git.commit'
	content_lines = blocks.blocks[0].content.split('\n')
	assert content_lines[1] == "url:'https://github.com/threefoldfoundation/books'"
	assert content_lines[2] == "message:'link'"
}

fn test_file_parse() {
	mut actionsmgr := new(
		path: '${actionsparser.testpath}/testfile.md'
		defaultactor: 'people'
		defaultbook: 'aaa'
	)!

	assert actionsmgr.actions.len == 13
}

fn test_dir_load() {
	mut actionsmgr := new(
		path: '${actionsparser.testpath}'
		defaultactor: 'people'
		defaultbook: 'aaa'
	)!
	assert actionsmgr.actions.len == 14

	mut a := actionsmgr.actions.last()
	assert a.name == 'select'
	assert a.actor == 'people'
	assert a.book == 'aaa'
}

fn test_text_add() ! {
	mut parser := new(
		text: actionsparser.text
		defaultactor: 'people'
		defaultbook: 'aaa'
	)!

	// confirm first action
	mut action := parser.actions[0]
	assert action.name == 'actor_select'
	mut arg := action.params.get_arg(0, 1)!
	assert arg == 'people'

	// confirm second action
	action = parser.actions[1]
	assert action.name == 'person_delete'
	mut param := action.params.get('cid')!
	assert param == '1gt'

	// confirm third action
	action = parser.actions[1]
	assert action.name == 'person_delete'
	param = action.params.get('cid')!
	assert param == '1gt'

	// confirm last action
	action = parser.actions.last()
	assert action.name == 'person_define'
	param = action.params.get('name')!
	assert param == 'despiegk'
}
