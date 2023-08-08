module twinsafe

import freeflowuniverse.crystallib.algo.secp256k1
import freeflowuniverse.crystallib.algo.aes_symmetric
import freeflowuniverse.crystallib.mnemonic
import encoding.hex

// this is me, my representation
pub struct MyTwin {
pub:
	id          u32                 [primary; sql: serial]
	name        string              [nonull]
	description string
	privkey     secp256k1.Secp256k1 [skip] // to be used for signing, verifying, only to be filled in when private key	
	keysafe     &KeysSafe           [skip] // allows us to remove ourselves from mem, or go to db
	privkey_str string
}

// ADD

[params]
pub struct MyTwinAddArgs {
pub:
	name        string [sql: unique]
	description string
	privatekey string // given in hex or mnemonics
}

// generate a new key is just importing a key with a random seed
// if it exists will return the key which is already there
pub fn (mut ks KeysSafe) mytwin_add(args_ MyTwinAddArgs) ! {
	mut args := args_
	privkeyhex := ""
	if args.privatekey.len > 0 {
		if args.privatekey[0..2] == "0x"{
			privkey_hex = args.privatekey
		}else{
			privkey_hex = hex.encode(mnemonic.parse(args.privatekey))
		}
		
	} else {
		// TODO: generate the seed
		// generate the key_bytes
	}
	privkey_str := aes_symmetric.encrypt(privkeyhex, ks.secret)
	privkey := secp256k1.new(keyhex: privkey_str)
	twin := myTwin{
		name: args.name
		description: args.description
		privkey_str: privkey_str
		privkey: privkey
		keysafe: ks 
	}
	twins := sql safe.db {
		select from MyTwin where name == twin.name
	}!
	if twins.len > 0 {
		return GetError{
			args: {
				id:   twins[0].id
				name: twins[0].name
			}
			msg: 'mytwin with name: ${twins[0].name} aleady exist'
			error_type: GetErrorType.alreadyexists
		}
	}
	sql ks.db {
		insert twin into MyTwin
	}
	ks.mytwins[twin.name] = twin
}


// I can have more than 1 mytwin, ideal for testing as well
pub fn (mut ks KeysSafe) mytwin_get(args GetArgs) !MyTwin {
	twins := sql safe.db {
		select from MyTwin where name == args.name
	}!
	if twins.len == 1 {
		mytwin := twins[0]
		// decrypt privatekey
		privkey_hex := aes_symmetric.decrypt(mytwin.privkey_str, ks.secret)
		privkey := secp256k1.new(keyhex: privkey_hex)
		mytwin.privateKey = privkey
		mytwin.keysafe = ks
		return mytwin
	}
	return  GetError{
		args: args,
		msg: "couldn't get mytwin with name ${args.name}" 
		error_type: GetErrorType.notfound}
}

pub fn (mut ks KeysSafe) mytwin_exist(args_ MyTwinAddArgs) ! {
	ks.mytwin_get(args_) or {
		if err.code == 0{
			return false
		}
		return err
	}
	return true

}

// use my private keyto sign data, important before sending
fn (mut twin MyTwin) sign(data []u8) ![]u8 {
	twin.privkey.sign_data(data)
}

pub fn (mut twin MyTwin) delete() ! {
	twin.keysage.mytwins.delete(twin.name)
	sql twin.keysafe.db {
		delete from MyTwin where id == twin.id
	}!
}

pub fn (mut twin MyTwin) save() ! {
	privkey_hex := twin.privatekey.hex()
	twin.privkey_str = aes_symmetric.encrypt(privkey_hex, twin.keysafe.secret)

	twins := sql twin.keysage.db {
		select from MyTwin where name == twin.name
	}!
	if twins.len > 0 {
		// twin already exists in the data base so we update
		sql twin.keysafe.db {
			update MyTwin set name = twin.name, description = twin.description, privkey_str = twin.privkey_str
			where id == twin.id
		}!
		return
	}
	sql safe.db {
		insert twin into MyTwin
	}!
}
