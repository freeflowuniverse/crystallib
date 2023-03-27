module actionsparser

const text2 = "
//select the book, can come from context as has been set before
//now every person added will be added in this book
!!select_actor people
!!select_book aaa

//delete everything as found in current book
!!person_delete cid:1g

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

!!select_actor aaa.test

!!test_action
	key: value

!!select_actor bbb.people

!!person_define
  cid: 'eg'
  name: despiegk

!!select_book bbb
"

fn test_filter_actor() ! {
	mut parser := new(
		defaultbook: 'aaa'
		text: actionsparser.text2
	)!
	assert parser.actions.len == 8
	assert parser.actions.map(it.name) == ['person_delete', 'person_define', 'circle_link', 'circle_comment', 'circle_comment', 'digital_payment_add', 'test_action', 'person_define']

	// pub struct FilterArgs{
	// pub:
	// 	domain string = "protocol_me"
	// 	actor    string [required]  //can be empty, this means will not filter based on actor
	// 	book     string	[required]  //can be empty, this means will not filter based on book	
	// 	names_filter    []string //can be empty, then no filter, unix glob filters are allowed
	// }	
	args := FilterArgs {
		actor: 'people'
		book: 'aaa'
		names_filter: ['*'] //QUESTION: if name filter is empty, should filter sort return list of len 0?
	}
	actions := filtersort(parser.actions, args)! //QUESTION: book and actors are also filtered here, is ok?
	assert actions.len == 6
	assert actions.map(it.name) == ['person_delete', 'person_define', 'circle_link', 'circle_comment', 'circle_comment', 'digital_payment_add']
}

// fn test_filter_book_aaa() ! {
// 	mut parser := new(defaultbook: 'aaa',text:actionsparser.text2)!

// 	// assert parser.unsorted.len == 8
// 	// assert parser.skipped.len == 0

// 	// parser.filter_book()

// 	// assert skipped action from book 'bbb'
// 	// assert parser.unsorted.len == 7
// 	// assert parser.skipped.len == 1
// 	// assert parser.skipped[0].name == 'bbb.people.person_define'

// 	//FIXME

// }

// fn test_filter_book_bbb() ! {
// 	mut parser := new(defaultbook: 'bbb',text:actionsparser.text2)!

// 	// parser.filtersort()

// 	//FIXME

// }

// fn test_filter() ! {
// 	// parser := new(
// 	// 	text: actionsparser.text2
// 	// )!

// 	// actions:=parser.filtersort(
// 	// 	names_filter: ['circle_delete', 'person_delete', 'circle_define', 'person_define', 'circle_link',
// 	// 		'circle_comment', 'digital_payment_add']
// 	// 	actor: 'people'
// 	// 	book: 'aaa'
// 	// )!
// 	// assert actions.len == 8

// }
