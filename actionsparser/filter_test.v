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

!!select_actor test

!!test_action
	key: value

!!select_book bbb
!!select_actor people

!!person_define
  cid: 'eg'
  name: despiegk

"

//QUESTION: how to better organize these tests
fn test_filter() ! {

	// test filter book:aaa actor:people
	mut parser := new(defaultbook: 'aaa',text:actionsparser.text2)!
	mut sorted := filtersort(parser.actions, actor: 'people' book: 'aaa')! //QUESTION: can you leave actor blank?
	assert parser.actions.len == 8
	assert sorted.len == 6

	// test filter book:bbb actor:people
	parser = new(defaultbook: 'aaa',text:actionsparser.text2)!
	sorted = filtersort(parser.actions, actor: 'people' book: 'bbb')!
	assert parser.actions.len == 8
	assert sorted.len == 1

	// test filter book:ccc actor:people
	parser = new(defaultbook: 'aaa',text:actionsparser.text2)!
	sorted = filtersort(parser.actions, actor: 'people' book: 'ccc')!
	assert parser.actions.len == 8
	assert sorted.len == 0

	// test filter book:aaa actor:test
	parser = new(defaultbook: 'aaa',text:actionsparser.text2)!
	sorted = filtersort(parser.actions, actor: 'test' book: 'aaa')!
	assert parser.actions.len == 8
	assert sorted.len == 1

	// test filter with names:[*]
	parser = new(defaultbook: 'aaa' text: actionsparser.text2)!
	assert parser.actions.len == 8
	assert parser.actions.map(it.name) == ['person_delete', 'person_define', 'circle_link', 'circle_comment', 'circle_comment', 'digital_payment_add', 'test_action', 'person_define']

	mut args := FilterArgs {
		actor: 'people'
		book: 'aaa'
		names_filter: ['*']
	}
	sorted = filtersort(parser.actions, args)!
	assert sorted.len == 6
	assert sorted.map(it.name) == ['person_delete', 'person_define', 'circle_link', 'circle_comment', 'circle_comment', 'digital_payment_add']
	
	// test filter with names:['']
	//QUESTION: should this return empty list?
	parser = new(
		defaultbook: 'aaa'
		text: actionsparser.text2
	)!
	
	assert parser.actions.map(it.name) == ['person_delete', 'person_define', 'circle_link', 'circle_comment', 'circle_comment', 'digital_payment_add', 'test_action', 'person_define']

	args = FilterArgs {
		actor: 'people'
		book: 'aaa'
		names_filter: ['']
	}
	sorted = filtersort(parser.actions, args)!
	assert sorted.len == 0
	assert sorted.map(it.name) == []
	
	// test filter with names in same order as actions
	parser = new(
		defaultbook: 'aaa'
		text: actionsparser.text2
	)!
	
	args = FilterArgs {
		actor: 'people'
		book: 'aaa'
		names_filter: ['person_delete', 'person_define', 'circle_link', 'circle_comment', 'digital_payment_add']
	}
	sorted = filtersort(parser.actions, args)!
	assert sorted.len == 6
	assert sorted.map(it.name) == ['person_delete', 'person_define', 'circle_link', 'circle_comment', 'circle_comment', 'digital_payment_add']
	
	// test filter with names in different order than actions
	parser = new(
		defaultbook: 'aaa'
		text: actionsparser.text2
	)!
	args = FilterArgs {
		actor: 'people'
		book: 'aaa'
		// this order of names don't make much sense, just for testing
		names_filter: ['circle_comment', 'person_define','digital_payment_add', 'person_delete', 'circle_link']
	}
	sorted = filtersort(parser.actions, args)!
	assert sorted.len == 6
	assert sorted.map(it.name) == ['circle_comment', 'circle_comment', 'person_define', 'digital_payment_add', 'person_delete', 'circle_link']

	//QUESTION: if we only have one name, is it just that action?
	// test filter with only two names in filter
	parser = new(
		defaultbook: 'aaa'
		text: actionsparser.text2
	)!
	
	args = FilterArgs {
		actor: 'people'
		book: 'aaa'
		// this order of names don't make much sense, just for testing
		names_filter: ['person_define', 'person_delete']
	}
	sorted = filtersort(parser.actions, args)!
	assert sorted.len == 2
	assert sorted.map(it.name) == ['person_define', 'person_delete']

}
