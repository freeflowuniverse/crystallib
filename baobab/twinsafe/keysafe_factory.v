module twinsafe

import freeflowuniverse.crystallib.pathlib
// import freeflowuniverse.crystallib.mnemonic // buggy for now
import encoding.hex
import json
import os
import db.sqlite

pub struct KeysSafe {
pub mut:
	secret string // secret to encrypt local file
	db sqlite.DB

}

[params]
pub struct KeysSafeNewArgs {
pub mut:
	path   string // location where sqlite db will be which holds the keys
	secret string // secret to encrypt local file

}


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
