module keysafe
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.encoder
import encoding.binary as bin
import crypto.ed25519
import libsodium

pub struct KeysSafe{
pub mut:	
	path pathlib.Path
	secret string
	keys []PrivKey
	name2id map[string]u16
}


pub fn keysafe_get(path0 string,secret string)! KeysSafe {
	mut path:=pathlib.get_file_dir_create(path0+"/.keys")!
	mut safe:=KeysSafe{path:path,secret:secret}
	//TODO: if the file is and right size there it needs to be loaded
	//loading is reverse of serialization
	//it needs to also encrypt / decrypt the file
	return safe
}


//for testing purposes you can generate multiple keys
pub fn (mut ks KeysSafe) generate_multiple(count int)!{
	for i in 0..count{
		ks.key_generate_add("name_$i")!
	}

}

pub fn (mut ks KeysSafe) key_generate_add(name string) !PrivKey{
	mut e := encoder.encoder_new()
	pubkey,signkey:=ed25519.generate_key()!
	privkey := libsodium.new_private_key()
	pk:=PrivKey{
		name:name
		privkey:privkey
		signkey:signkey
	}
	ks.key_add(pk)!
	return pk
}


pub fn (mut ks KeysSafe) key_add(pk PrivKey)!{
	ks.keys << pk
	ks.name2id[pk.name]=u16(ks.keys.len)
}


pub fn (mut ks KeysSafe) serialize()[]u8{
	mut out:=[]u8{}
	mut e := encoder.encoder_new()	
	e.add_u16(u16(ks.keys.len))
	// for pk in ks.keys {
	// 	e.add_string(pk.name)
	// 	println(pk.privkey)
	// 	e.add_bytes(pk.privkey.public_key.data)
	// 	e.add_bytes(pk.privkey.secret_key.data)
	// 	e.add_bytes(pk.signkey)
	// }
	//TODO: now we need to encrypt using the secret on keysafe
	return e.data
}


