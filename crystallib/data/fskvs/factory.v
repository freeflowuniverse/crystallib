module fskvs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.ui as gui
import os

@[params]
pub struct ContextConfigureArgs {
pub mut:
	name      string = 'default'
	secret    string
	encrypted bool
}

// configure a contextdb, make sure it exists
// if secret specified then we do encrypted
pub fn contextdb_configure(args_ ContextConfigureArgs) ! {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	dbpath := '${os.home_dir()}/hero/db/${args.name}'
	pathlib.get_dir(create: true, path: dbpath)!

	if args.secret.len > 0 || args.encrypted {
		pathlib.get_file(create: true, path: '${dbpath}/encrypted')!
	}

	if args.secret.len > 0 {
		mut redis := redisclient.core_get()!
		mut key := 'hero:${args.name}:something'
		redis.set(key, args.secret.trim_space())!
	}
}

pub fn contextdb_exists(name_ string) bool {
	name := texttools.name_fix(name_)
	dbpath := '${os.home_dir()}/hero/db/${name}'
	return os.exists(dbpath)
}

@[params]
pub struct DBGetArgsArgs {
pub mut:
	name        string = 'default'
	interactive bool   = true
}

// will check on env variable "MYSECRET" if found will use to encrypt/decrypt .
// or will check on env variable "MYCONTEXT" if found format is export MYCONTEXT=contextname:mysecret .
// or will check in redis in hero:current which gives back the contextdb if interactive chosen
// make sure to set secret if you don't want to use the 'MYSECRET' as mybe set in os.env arguments
pub fn contextdb_get(args_ DBGetArgsArgs) !ContextDB {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	mut secret := ''

	dbpath := '${os.home_dir()}/hero/db/${args.name}'
	mut p := pathlib.get_dir(create: true, path: dbpath)!

	mut encrypted := false
	if os.exists('${dbpath}/encrypted') {
		encrypted = true
	}

	// means we need to find the key otherwise ask
	if encrypted {
		mut redis := redisclient.core_get()!
		mut key := 'hero:${args.name}:something'
		if redis.exists(key)! {
			secret = redis.get(key)!
		}
		if secret == '' && 'MYCONTEXT' in os.environ() {
			// get out of os env
			mycontext := os.environ()['MYCONTEXT'] or { panic('bug') }
			if mycontext.contains(':') {
				spl := mycontext.split(':')
				if spl.len == 2 {
					name := texttools.name_fix(spl[0])
					if name == args.name {
						secret = spl[1].trim_space()
					}
				} else {
					return error("format: 'export MYCONTEXT=contextname:mysecret'")
				}
			} else {
				return error("format: 'export MYCONTEXT=contextname:mysecret'")
			}
		}
		if secret == '' && args.interactive {
			// we can ask interactive
			mut ui := gui.new()!
			secret = ui.ask_question(
				question: '\nPlease specify your secret for your hero environment. (context:${args.name})'
			)!
			secret = secret.trim_space()
			redis.set(key, secret)!
			redis.expire(key, 3600 * 24)!
		}
		if secret == '' {
			return error('we did not find a way how to get to the secret, is not in redis or was non interactive')
		}
		if secret.len < 6 {
			return error('secret needs to be at least 6 chars')
		}
	}

	mut db := ContextDB{
		path: p
		secret: secret
		name: args.name
	}
	return db
}
