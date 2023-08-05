module twinsafe

import freeflowuniverse.crystallib.pathlib
// import freeflowuniverse.crystallib.mnemonic // buggy for now
import encoding.hex
import libsodium
import json
import os
import db.sqlite

/*
* KeysSafe
 *
 * This module implement a secure keys manager.
 *
 * When loading a keysafe object, you can specify a directory and a secret.
 * In that directory, a file called '.keys' will be created and encrypted using
 * the 'secret' provided (AES-CBC).
 *
 * Content of that file is a JSON dictionnary of key-name and it's mnemonic,
 * a single mnemonic is enough to derivate ed25519 and x25519 keys.
 *
 * When loaded, private/public signing key and public/private encryption keys
 * are loaded and ready to be used.
 *
 * key_generate_add() generate a new key and store is as specified name
 * key_import_add() import an existing key based on it's seed and specified name
 *
*/

pub struct KeysSafe {
pub mut:
	secret string // secret to encrypt local file
	db sqlite.DB

}

[params]
pub struct KeysSafeNewArgs {
pub mut:
	path   string //location where sqlite db will be which holds the keys
	secret string // secret to encrypt local file

}



// note: root key needs to be 'SigningKey' from libsodium
//       from that SigningKey we can derivate PrivateKey needed to encrypt

pub fn new(args_ KeysSafeNewArgs) !KeysSafe {
	mut args:=args_
	if args.path.len==0{
		args.path="~/.twin"
	}
	pathlib.get_dir(args.path,true)!
	mut db := sqlite.connect("${args.path}/keysafe.db")! 
	mut safe := KeysSafe{
		db: db 
		secret: args.secret
	}

	return safe
}
