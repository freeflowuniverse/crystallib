module main

import freeflowuniverse.crystallib.algo.aes_symmetric {encrypt,decrypt}

fn main() {
	do() or {panic(err)}
}

fn do()!{

	msg:="my message".bytes()
	println(msg)
	secret:="1234"
	encrypted:=encrypt(msg,secret)
	println(encrypted)
	decrypted:=decrypt(encrypted,secret)
	println(decrypted)
	assert decrypted==msg

}
