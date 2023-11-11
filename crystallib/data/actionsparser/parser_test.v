module actionsparser

import os
import freeflowuniverse.crystallib.baobab.smartid

const testpath = os.dir(@FILE) + '/testdata'

const text = "

!!select_circle bbb

!!person.define name: fatayera
	firstname: 'Adnan'
	lastname: 'Fatayerji'
	description: 'Head of Business Development'
  email: 'adnan@threefold.io,fatayera@threefold.io'

!!circle.link  circle:tftech role:'stakeholder'
	description:'' //is the name as given to the link
	name:'vpsales'        

!!people.comment_define cid:'1g' 
    comment:
      this is a comment
      can be multiline 

!!circle.comment_define cid:'1g' 
    comment:
      another comment



!!payment.add 
  person:fatayera
	name: 'TF Wallet'
	blockchain: 'stellar'
	account: ''
	description: 'TF Wallet for TFT' 
	preferred: false

"

fn test_parse_into_blocks() {
	md := "!!git.link name:myname
		source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/feasibility_study/Capabilities'
		dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'"

	cid := smartid.cid(cid_int: 0)!

	mut blocks := parse_into_blocks(md, '', false, cid) or { panic(err) }

	println(blocks)

	assert blocks.blocks.len == 1
	assert blocks.blocks[0].name == 'git.link'
	mut content_lines := blocks.blocks[0].content.split('\n')
	assert content_lines[0] == 'name:myname'
	assert content_lines[1] == "source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/feasibility_study/Capabilities'"
	assert content_lines[2] == "dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'"

	// test separate keywords, indented
	md_2 := "!!git.commit
	url:'https://github.com/threefoldfoundation/books'
	message:'link'"

	blocks = parse_into_blocks(md_2, '', false, cid) or { panic(err) }
	assert blocks.blocks.len == 1
	assert blocks.blocks[0].name == 'git.commit'
	content_lines = blocks.blocks[0].content.split('\n')
	assert content_lines[1] == "url:'https://github.com/threefoldfoundation/books'"
	assert content_lines[2] == "message:'link'"
}

fn test_file_parse() {
	mut parser := new(
		path: '${actionsparser.testpath}/testfile.md'
		defaultactor: 'people'
		default_cid: 1
	)!

	assert parser.actions.len == 9
}

// fn test_dir_load() {
// 	mut actionsmgr := new(
// 		path: '${actionsparser.testpath}'
// 		defaultactor: 'people'
// 		default_cid: 1
// 	)!
// 	assert actionsmgr.actions.len == 14

// 	mut a := actionsmgr.actions.last()
// 	assert a.name == 'select'
// 	assert a.actor == 'people'
// }

// fn test_text_add() ! {
// 	mut parser := new(
// 		text: actionsparser.text
// 		defaultactor: 'people'
// 		default_cid: 1
// 	)!

// 	// confirm first action
// 	mut action := parser.actions[0]
// 	assert action.name == 'actor_select'
// 	mut arg := action.params.get_arg(0)!
// 	assert arg == 'people'

// 	// confirm second action
// 	action = parser.actions[1]
// 	assert action.name == 'person_delete'
// 	mut param := action.params.get('cid')!
// 	assert param == '1gt'

// 	// confirm third action
// 	action = parser.actions[1]
// 	assert action.name == 'person_delete'
// 	param = action.params.get('cid')!
// 	assert param == '1gt'

// 	// confirm last action
// 	action = parser.actions.last()
// 	assert action.name == 'person_define'
// 	param = action.params.get('name')!
// 	assert param == 'despiegk'
// }
