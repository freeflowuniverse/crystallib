module actionsparser

const text = "
//select the book, can come from context as has been set before
//now every person added will be added in this book
!!actor.select aaa.people

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

!!actor.select aaa.test

!!test_action
	key: value

!!actor.select bbb.people

!!person_define
  cid: 'eg'
  name: despiegk

!!book.select bbb
"

fn test_filter_actor() ! {
	mut parser := new(actor: 'people')!
	parser.text_add(text)!

	assert parser.unsorted.len == 8
	assert parser.skipped.len == 0

	parser.filter_actor()

	// confirm only one test actor action is skipped
	assert parser.unsorted.len == 7
	assert parser.skipped.len == 1
}

fn test_filter_book() ! {
	test_filter_book_aaa()!
	test_filter_book_bbb()!
}

fn test_filter_book_aaa() ! {
	mut parser := new(book: 'aaa')!
	parser.text_add(text)!
	
	assert parser.unsorted.len == 8
	assert parser.skipped.len == 0

	parser.filter_book()

	// assert skipped action from book 'bbb'
	assert parser.unsorted.len == 7
	assert parser.skipped.len == 1
	assert parser.skipped[0].name == 'bbb.people.person_define'
}

fn test_filter_book_bbb() ! {
	mut parser := new(book: 'bbb')!
	parser.text_add(text)!
	
	assert parser.unsorted.len == 8
	assert parser.skipped.len == 0

	parser.filter_book()

	// assert skipped action from book 'bbb'
	assert parser.unsorted.len == 1
	assert parser.skipped.len == 7
	assert parser.unsorted[0].name == 'bbb.people.person_define'
}

fn test_filter() ! {
	parser := new(
		text: text
		filter: ['circle_delete', 'person_delete', 'circle_define', 'person_define', 'circle_link',
			'circle_comment', 'digital_payment_add']
		actor: 'people'
		book: 'aaa'
	)!

	assert parser.unsorted.len == 0
	assert parser.ok.len == 6
	assert parser.skipped.len == 2

	// assert parser.unsorted[1].name == 'person_delete'
	// assert parser.ok[1].name == 'circle_delete'
}