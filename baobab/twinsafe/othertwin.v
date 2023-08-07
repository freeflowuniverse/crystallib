module twinsafe

import freeflowuniverse.crystallib.algo.secp256k1
import freeflowuniverse.crystallib.baobab.mbus


pub struct OtherTwin{
pub:
	name string
	id u32
	description string
	// pubkey ... //TODO: how to do the pubkey, what is form of that?
	conn_type TwinConnectionType 
	addr string      //ipv4 or ipv6 or redis connection string
	keysafe  &KeysSafe            [str: skip]  //allows us to remove ourselves from mem, or go to db
	state TwinState //only keep this in mem, does not have to be in sqlitedb
}

enum TwinConnectionType{
	ipv6
	ipv4
	redis 
}


// The possible states of a job
pub enum TwinState {
	active
	unreacheable
}


//ADD

[params]
pub struct OtherTwinAddArgs{
pub:
	name string
	id u32
	description string
	publickey string //given in hex
	conn_type TwinConnectionType 
	addr string      //
}


// generate a new key is just importing a key with a random seed
// if it exists will return the key which is already there
pub fn (mut ks KeysSafe) othertwin_add(args_ OtherTwinAddArgs) ! {
	mut args:=args_
	if args.privatekey_generate && args.privatekey.len>0{
		
	}
	mut seed := []u8{}

	// generate a new random seed
	for _ in 0 .. 32 {
		seed << u8(libsodium.randombytes_random()) //TODO: use secp256k1
	}

	//TODO: based on args generate key or add pre-defined key
	//check if hex or mnemonics, then import accordingly

	//use sqlite to store in db, encrypt the private key, symmetric using aes_symmetric 
	//no need to encrypt other properties

	//TODO: use proper error handling with custom error type
}


////GET

//other twins, are remote twins
//they have the info as required to connect to them
pub fn (mut ks KeysSafe) othertwin_get(args GetArgs) !OtherTwin {

	//check if mem, if there get from mem
	//use sqlite to get info (do query)
	//store in mem, so it gets cached
}

//send message to this other twin
pub fn (mut twin OtherTwin) send (msg mbus.RPCMessage)!{

	//TODO: convert to binary (means signature is part of it too)
	//TODO: give to mbus to send

}


//receive info from mbus, if anything in there
pub fn (mut twin OtherTwin) receive ()!mbus.RPCMessage{

	//TODO: receive data from mbus for this twin
	//TODO: verify the data which comes back over mbus with twin.verify... 
	//TODO: probably need to use ? as return, so its optional result

}

//verify the received data from the mbus and make sure signature is ok
fn (mut twin OtherTwin) verify (data []u8, signature []u8)! {

}



pub fn (mut o OtherTwin) delete() ! {
    //delete from memory and from sqlitedb
}

pub fn (mut o OtherTwin) save() ! {
    //update in DB, or insert if it doesn't exist yet
}

