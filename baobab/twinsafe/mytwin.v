module twinsafe

import freeflowuniverse.crystallib.algo.secp256k1

// this is me, my representation
pub struct MyTwin {
pub:
	id          u32       [primary; sql: serial]
	name        string    [nonull]
	description string
	privkey     Secp256k1        // to be used for signing, verifying, only to be filled in when private key	
	keysafe     &KeysSafe [skip] // allows us to remove ourselves from mem, or go to db
}

// ADD

[params]
pub struct MyTwinAddArgs {
pub:
	id                  u32
	name                string [sql: unique]
	description         string
	privatekey_generate bool
	privatekey          string // given in hex or mnemonics
}

// generate a new key is just importing a key with a random seed
// if it exists will return the key which is already there
pub fn (mut ks KeysSafe) mytwin_add(args_ MyTwinAddArgs) ! {
	mut args := args_
	if args.privatekey_generate && args.privatekey.len > 0 {
	}
	mut seed := []u8{}

	// generate a new random seed
	for _ in 0 .. 32 {
		seed << u8(libsodium.randombytes_random()) // TODO: use secp256k1
	}

	// TODO: based on args generate key or add pre-defined key
	// check if hex or mnemonics, then import accordingly

	// use sqlite to store in db, encrypt the private key, symmetric using aes_symmetric
	// no need to encrypt other properties

	// TODO: use proper error handling with custom error type
}

// I can have more than 1 mytwin, ideal for testing as well
pub fn (mut ks KeysSafe) mytwin_get(args GetArgs) !MyTwin {
	// use sqlite to get info (do query)
	// decrypt the private key
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
}

pub fn (mut o MyTwin) delete() ! {
	// delete from memory and from sqlitedb
}

pub fn (mut o MyTwin) save() ! {
	// update in DB, or insert if it doesn't exist yet
}
