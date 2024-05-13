module dbfs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.redisclient
import os

@[params]
pub struct CollectionGetArgs {
pub mut:
	dbpath    string
	secret      string
	contextid   u32//needed to connect to the redis
}

// will return the dbcollection for a specific context
// will check on env variable "MYSECRET" if found will use to encrypt/decrypt .
// will check on env variable "MYCONTEXT" if found this will be the chosen context (overrules the context as given in args)
pub fn get(args_ CollectionGetArgs) !DBCollection {
	mut args := args_
	mut secret := args.secret
	if args.dbpath==""{
		args.dbpath = "${os.home_dir()}/var/dbfs"
	}
	mut p := pathlib.get_dir(create: true, path: args.dbpath)!

	mut r := redisclient.core_get()!
	r.selectdb(args_.contextid)!

	mut dbcollection := DBCollection{
		path: p
		secret: secret
		contextid: args.contextid
		redis:r
	}
	return dbcollection
}

