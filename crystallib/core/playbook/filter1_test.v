module playbook

const text3 = "
//select the circle, can come from context as has been set before
//
//now every person added will be added in this circle
//
!!select_actor people
!!select_circle aaa

//delete everything as found in current circle
!!person.delete cid:1g

!!person.define
  	//is optional will be filled in automatically, but maybe we want to update
  	cid: '1gt' 
  	//name as selected in this group, can be used to find someone back
 	 name: fatayera
	firstname: 'Adnan'
	lastname: 'Fatayerji'
	description: 'Head of Business Development'
  	email: 'adnan@threefold.io,fatayera@threefold.io'

!!circle_link
	//can define as cid or as name, name needs to be in same circle
	person: '1gt'
	//can define as cid or as name
	circle:tftech         
	role:'stakeholder'
	description:''
	//is the name as given to the link
	name:'vpsales'        

!!people.circle_comment cid:'1g' 
    comment:'
      this is a comment
      can be multiline 
	  '

!!circle.comment cid:'1g' 
    comment:
      another comment

!!digital_payment.add 
	person:fatayera
	name: 'TF Wallet'
	blockchain: 'stellar'
	account: ''
	description: 'TF Wallet for TFT' 
	preferred: false

!!test.myaction
	key: value

!!person.define
  cid: 'eg'
  name: despiegk //this is a remark

"

// test filter with only two names in filter
fn test_filter1() ! {
	mut plbook := new(
		text: playbook.text3
	)!

	assert plbook.actions.len == 10

	println(plbook)

	assert plbook.hashkey() == 'ea9dea6e28bfaf836719e821953e646a155dd9eb'

	// struct FilterArgs
	//   actor_names  []string 	//if empty will match all,
	//   action_names []string 	//if empty will match all
	//
	// struct FilterSortArgs
	// 	 priorities  map[int]FilterArgs //filter and give priority
	//

	plbook.filtersort(
		priorities: {
			2: 'digital_payment:*'
		}
	)!
	assert plbook.done.len == 1

	plbook.filtersort(
		priorities: {
			5: 'circle*:*'
		}
	)!
	assert plbook.done.len == 2

	plbook.filtersort(
		priorities: {
			50: '*:*circle*'
		}
	)!
	assert plbook.done.len == 5

	mut asorted := plbook.actions_sorted()!
	println(asorted)

	assert asorted.map('${it.actor}:${it.name}') == ['digital_payment:add', 'circle:comment',
		'core:select_circle', 'core:circle_link', 'people:circle_comment', 'core:select_actor',
		'person:delete', 'person:define', 'test:myaction', 'person:define']
}
