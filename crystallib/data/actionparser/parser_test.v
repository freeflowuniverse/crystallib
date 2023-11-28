module actionparser

import os
import crypto.sha256

const testpath = os.dir(@FILE) + '/testdata'

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
	a := parse(text: actionparser.text1) or { panic(err) }

	println(a)

	println("EXPECTED OUTPUT:
	!!payment.add account:something description:'TF Wallet for TFT' person:fatayera preferred:false
		name:'TF Wallet' //comment for name
		blockchain:stellar //holochain maybe?	
	")

	assert sha256.hexhash(a.script3()) == '6e5a489144b43422d9c2df4d2c723c55e300ace6dc3ee28ba7ad88c6f89a1050'

	b := parse(text: a.script3()) or { panic(err) }

	println(b)

	println("EXPECTED OUTPUT 2:
	!!payment.add account:something description:'TF Wallet for TFT' person:fatayera preferred:false
		name:'TF Wallet' //comment for name
		blockchain:stellar //holochain maybe?	
	")

	assert sha256.hexhash(b.script3()) == '6e5a489144b43422d9c2df4d2c723c55e300ace6dc3ee28ba7ad88c6f89a1050'
}

fn test_parser() {
	a := parse(text: actionparser.text1)!

	assert a.actor == 'payment'
	assert a.name == 'add'
	assert a.params.get('name')! == 'TF Wallet'
	assert a.params.get('blockchain')! == 'stellar'
	assert a.params.get('account')! == 'something'
	assert a.params.get('description')! == 'TF Wallet for TFT'
	assert a.params.get_default_false('preferred') == false

	script3 := a.script3()
	a2 := parse(text: a.script3())!
	a3 := parse(text: a2.script3())!

	assert a2 == a3
}
