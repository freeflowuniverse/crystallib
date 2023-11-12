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

//free comment
a:=this is something else

//comment2
!!payment.add person:despiegk
	name: 'TF Wallet2'

"

fn test_parse_1() {

	a:=parse_collection(text:actionparser.text1) or {panic(err)}

	println(a)
	println(a.script3())

	println("EXPECTED OUTPUT:
		// comment for the action
		!!payment.add account:something description:'TF Wallet for TFT' person:fatayera preferred:false
			name:'TF Wallet' //comment for name
			blockchain:stellar //holochain maybe?

		// comment2
		!!payment.add name:'TF Wallet2' person:despiegk



		free comment
		a:=this is something else
		")

	assert sha256.hexhash(a.str()) == "daf0a54b8f2572cf8f3a565d313801d6576c1eb153c79cf7b1a3a5ea7579f7f9"


}
