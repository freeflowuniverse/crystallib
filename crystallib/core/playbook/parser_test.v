module playbook

import os

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

	println(a.actions)

	assert a.actions.len == 1
	mut s:=a.actions_sorted()!
	assert s.len == 1
	mut sorted:=a.actions_sorted(filtered:true)!
	assert sorted.len == 0	

	mut myaction:=s[0] or {panic("bug")}

	assert myaction.comments=='comment for the action'
	assert myaction.params.params.len==6
	assert myaction.id==1

	println("EXPECTED OUTPUT:
	!!payment.add id:1 account:something description:'TF Wallet for TFT' person:fatayera preferred:false
		name:'TF Wallet' //comment for name
		blockchain:stellar //holochain maybe?
	")

	assert a.hashkey()  == '89444b5d8ea4f7ded66cced6067b7c822cecf1c3'
	c:= a.script3()!
	b := new(text:c) or { panic(err) }

	println(b)
	assert b.hashkey() == '89444b5d8ea4f7ded66cced6067b7c822cecf1c3'
}

fn test_parser() {
	mut pb := new(text: playbook.text1) or { panic(err) }
	mut a:=pb.actions[0]
	assert a.actor == 'payment'
	assert a.name == 'add'
	assert a.params.get('name')! == 'TF Wallet'
	assert a.params.get('blockchain')! == 'stellar'
	assert a.params.get('account')! == 'something'
	assert a.params.get('description')! == 'TF Wallet for TFT'
	assert a.params.get_default_false('preferred') == false
}
