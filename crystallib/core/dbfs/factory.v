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
	context     string = 'default'
	interactive bool
	secret      string
}

// will return the dbcollection for a specific context
// will check on env variable "MYSECRET" if found will use to encrypt/decrypt .
// will check on env variable "MYCONTEXT" if found this will be the chosen context (overrules the context as given in args)
pub fn get(args_ CollectionGetArgs) !DBCollection {
	mut args := args_
	args.context = texttools.name_fix(args.context)

	mut secret := args.secret

	dbpath := '${os.home_dir()}/hero/db/${args.context}'
	mut p := pathlib.get_dir(create: true, path: dbpath)!

	mut redis := redisclient.core_get()!
	mut key := 'hero:${args.context}:something'
	if redis.exists(key)! {
		secret = redis.get(key)!
	}

	if secret == '' && 'SECRET' in os.environ() {
		secret = os.environ()['SECRET'] or { panic('bug') }
		secret = secret.trim_space()
		secret = md5.hexhash(secret)
	}

	if args.context == 'default' && 'MYCONTEXT' in os.environ() {
		args.context = os.environ()['MYCONTEXT'] or { panic('bug') }
		args.context = texttools.name_fix(args.context.trim_space())
	}

	if secret == '' && args.interactive {
		// we can ask interactive
		mut ui := gui.new()!
		secret = ui.ask_question(
			question: '\nPlease specify your secret for your hero environment. (context:${args.context})'
		)!
		secret = secret.trim_space()
		secret = md5.hexhash(secret)
		redis.set(key, secret)!
		redis.expire(key, 3600 * 24)!
	}

	mut db := DBCollection{
		path: p
		secret: secret
		name: args.context
	}
	return db
}

pub fn exists(context_ string) bool {
	context := texttools.name_fix(context_)
	dbpath := '${os.home_dir()}/hero/db/${context}'
	return os.exists(dbpath)
}
