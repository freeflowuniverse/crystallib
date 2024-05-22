module playbook

const text1 = "
//comment for the action
!!payment.add person:fatayera
	//comment for name
	name: 'TF Wallet'
	blockchain: 'stellar' //holochain maybe?
	account: 'something'
	description: 'TF Wallet for TFT' 
	preferred: false
"

fn test_parse_1() {
	mut a := new(text: playbook.text1) or { panic(err) }

	assert a.actions.len == 1
	mut s := a.actions_sorted()!
	assert s.len == 1
	// mut sorted := a.actions_sorted(prio_only: true)!
	// assert sorted.len == 0

	mut myaction := s[0] or { panic('bug') }

	assert myaction.comments == 'comment for the action'
	assert myaction.params.params.len == 6
	assert myaction.id == 1

	assert a.hashkey() == '286770a4e2cf79379cb3484471223a738d4b6863'
	c := a.heroscript()!
	b := new(text: c) or { panic(err) }

	assert b.hashkey() == '286770a4e2cf79379cb3484471223a738d4b6863'
}

fn test_parser() {
	mut pb := new(text: playbook.text1) or { panic(err) }
	mut a := pb.actions[0]
	assert a.actor == 'payment'
	assert a.name == 'add'
	assert a.params.get('name')! == 'TF Wallet'
	assert a.params.get('blockchain')! == 'stellar'
	assert a.params.get('account')! == 'something'
	assert a.params.get('description')! == 'TF Wallet for TFT'
	assert a.params.get_default_false('preferred') == false
}
