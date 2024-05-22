module playbook

import os
import crypto.sha256

const testpath = os.dir(@FILE) + '/testdata'

// TODO: fix

const text1 = "
//comment for the action
!!payment.add person:fatayera
	//comment for name
	name: 'TF Wallet'
	blockchain: 'stellar' //holochain maybe?
	account: 'something'
	description: 'TF Wallet for TFT' 
	preferred: false

//comment2
!!payment.add person:despiegk
	name: 'TF Wallet2'

"

const text2 = "
//comment for the action
!!payment.add person:fatayera
	name: 'TF Wallet'

!!payment.else person:despiegk
	name: 'TF Wallet2'

!!actor2.else person:despiegk
	name: 'TF Wallet2'

"

fn test_parse_1() {
	mut a := new(text: playbook.text1) or { panic(err) }

	println(a)

	println("EXPECTED OUTPUT:
// comment for the action
!!payment.add account:something description:'TF Wallet for TFT' person:fatayera preferred:false
	name:'TF Wallet' //comment for name
	blockchain:stellar //holochain maybe?

// comment2
!!payment.add name:'TF Wallet2' person:despiegk
")

	assert sha256.hexhash(a.str()) == 'cff221d01c67af053f3eb51fc3f2759eee889b65363bab4fae446a1490512eb7'
}

fn test_hashkey() {
	mut a := new(text: playbook.text1) or { panic(err) }
	t := a.hashkey()

	println(t)

	assert t == '773708ca1fa94582ce2ef625932a13a6aa2d46a1'
}

fn test_filter() {
	mut a := new(text: playbook.text2) or { panic(err) }

	mut b := a.find(filter: 'payment.*')!
	assert b.len == 2

	mut c := a.find(filter: 'payment.else')!
	assert c.len == 1

	mut d := a.find(filter: 'actor2.*')!
	assert d.len == 1

	mut e := a.find(filter: 'actor2.else')!
	assert e.len == 1

	mut f := a.find(filter: 'actor2:else2')!
	assert f.len == 0
}
