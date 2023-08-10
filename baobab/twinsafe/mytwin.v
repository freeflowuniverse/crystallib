module twinsafe

import freeflowuniverse.crystallib.algo.secp256k1
import freeflowuniverse.crystallib.algo.aes_symmetric
import freeflowuniverse.crystallib.mnemonic
import encoding.hex

// this is me, my representation
pub struct MyTwin {
pub mut:
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
	privkey  string // given in hex or mnemonics
}

// generate a new key is just importing a key with a random seed
// if it exists will return the key which is already there
pub fn (mut ks KeysSafe) mytwin_add(args_ MyTwinAddArgs) ! {
	mut args := args_
	mut privkey_hex := ''

	twins := sql ks.db {
		select from MyTwin where name == args.name
	}!
	if twins.len > 0 {
		return GetError{
			args: GetArgs{
				id: 0
				name: args.name
			}
			msg: 'mytwin with name: ${twins[0].name} aleady exist'
			error_type: GetErrorType.alreadyexists
		}
	}
	
	if args.privkey.len > 0 {
		if args.privkey[0..2] == '0x' {
			privkey_hex = args.privkey
		} else {
			privkey_hex = hex.encode(mnemonic.parse(args.privkey)) // TODO check after mnemonics lib is fixed
		}
	} else {
		privkey := secp256k1.new()!
		privkey_hex = privkey.export()
	}

	privkey_str := encrypt_privkey(privkey_hex, ks.secret)!
	privkey := secp256k1.new(keyhex: privkey_hex)!
	twin := MyTwin{
		name: args.name
		description: args.description
		privkey_str: privkey_str
		privkey: privkey
		keysafe: ks
	}
	sql ks.db {
		insert twin into MyTwin
	}!
	ks.mytwins[twin.name] = twin
}
fn encrypt_privkey(privkey_hex string, secret string) !string{
	// convert privkey_hex to bytes to decrypt it
	privkey_bytes := hex.decode(privkey_hex)!
	// decrypt the key which will produce encrypted bytes
	privkey_enc_bytes := aes_symmetric.encrypt(privkey_bytes, secret)
	// encode the encrypted bytes so we can store it in the data base as string
	privkey := hex.encode(privkey_enc_bytes)
	return privkey

}
fn decrypt_privkey(privkey_enc string, secret string) !string{
		privkey_enc_bytes := hex.decode(privkey_enc)!
		privkey_bytes := aes_symmetric.decrypt(privkey_enc_bytes, secret)
		return  "0x${hex.encode(privkey_bytes)}"

}
// I can have more than 1 mytwin, ideal for testing as well
pub fn (mut ks KeysSafe) mytwin_get(args GetArgs) !MyTwin {
	if args.name in ks.mytwins {
		return ks.mytwins[args.name]
	}
	twins := sql ks.db {
		select from MyTwin where name == args.name
	}!
	if twins.len == 1 {
		mut mytwin := twins[0]
		privkey_hex := decrypt_privkey(mytwin.privkey_str, ks.secret)!
		privkey := secp256k1.new(keyhex: privkey_hex)!
		mytwin.privkey = privkey
		mytwin.keysafe = ks
		ks.mytwins[mytwin.name] = mytwin
		return mytwin
	}
	return GetError{
		args: args
		msg: "couldn't get mytwin with name ${args.name}"
		error_type: GetErrorType.notfound
	}
}

pub fn (mut ks KeysSafe) mytwin_exist(args_ GetArgs) !bool {
	ks.mytwin_get(args_) or {
		if err.code() == 0 {
			return false
		}
		return err
	}
	return true
}

// use my private keyto sign data, important before sending
fn (mut twin MyTwin) sign(data []u8) ![]u8 {
	return twin.privkey.sign_data(data)
}

pub fn (mut twin MyTwin) delete() ! {
	twin.keysafe.mytwins.delete(twin.name)
	sql twin.keysafe.db {
		delete from MyTwin where id == twin.id
	}!
}

pub fn (mut twin MyTwin) save() ! {
	privkey_hex := twin.privkey.export()
	privkey_bytes := hex.decode(privkey_hex)!
	privkey_enc := aes_symmetric.encrypt(privkey_bytes, twin.keysafe.secret)
	twin.privkey_str = hex.encode(privkey_enc)
	twins := sql twin.keysafe.db {
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
	sql twin.keysafe.db {
		insert twin into MyTwin
	}!
}
