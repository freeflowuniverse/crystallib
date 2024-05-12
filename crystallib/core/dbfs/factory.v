module dbfs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.clients.redisclient
import crypto.md5
import freeflowuniverse.crystallib.ui as gui
import os

@[params]
pub struct CollectionGetArgs {
pub mut:
	dbpath    string
	secret      string
}

// will return the dbcollection for a specific context
// will check on env variable "MYSECRET" if found will use to encrypt/decrypt .
// will check on env variable "MYCONTEXT" if found this will be the chosen context (overrules the context as given in args)
pub fn get(args_ CollectionGetArgs) !DBCollection {
	mut args := args_
	mut secret := args.secret
	mut p := pathlib.get_dir(create: true, path: args.dbpath)!

	mut db := DBCollection{
		path: p
		secret: secret
		name: args.context
	}
	return db
}

