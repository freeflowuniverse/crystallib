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

	assert sha256.hexhash(a.str()) == '9e33a11c276f1dfada99f5f8ecf48b1fd59f778bafdee686545d4da10f63691c'

	b := parse(text: a.str()) or { panic(err) }

	println(b)

	println("EXPECTED OUTPUT 2:
	!!payment.add account:something description:'TF Wallet for TFT' person:fatayera preferred:false
		name:'TF Wallet' //comment for name
		blockchain:stellar //holochain maybe?	
	")

	assert sha256.hexhash(b.str()) == '9e33a11c276f1dfada99f5f8ecf48b1fd59f778bafdee686545d4da10f63691c'
}
