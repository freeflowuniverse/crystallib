module fskvs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.ui as gui
import os

@[heap]
pub struct KVSContext {
pub mut:
	path   pathlib.Path
	config KVSConfig
}

@[params]
pub struct KVSConfig {
pub mut:
	context     string = 'default'
	secret      string
	encryption  bool
	interactive bool = true
}

@[params]
pub struct KVSNewArgs {
pub mut:
	name string
}

// will open KVS in 'core' context which is always non encrypted, non interactive
pub fn db_core_new(args_ KVSNewArgs) !KVS {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	if args.name.len < 4 {
		return error('name needs to be at least 4 chars')
	}
	mut context := new(context: 'core', encryption: false, interactive: false)!
	mut db := context.get(name: args.name, encryption: false)!
	return db
}

// will check on env variable "MYSECRET" if found will use to encrypt/decrypt .
// or will check on env variable "MYCONTEXT" if found format is export MYCONTEXT=contextname:mysecret .
// or will check in redis in hero:current which gives back the context if interactive chosen
// make sure to set secret if you don't want to use the 'MYSECRET' as mybe set in os.env arguments
pub fn new(args_ KVSConfig) !KVSContext {
	mut args := args_
	args.context = texttools.name_fix(args.context)
	if args.secret.len > 0 {
		args.encryption = true
	}
	if args.encryption && args.secret.len == 0 {
		if 'MYSECRET' in os.environ() {
			args.secret = os.environ()['MYSECRET']
		} else if 'MYCONTEXT' in os.environ() {
			parse_context(os.environ()['MYCONTEXT'], mut args)!
		} else {
			if args.interactive {
				mut redis := redisclient.core_get()!
				am_in_redis := redis.exists('hero:current')!
				if am_in_redis {
					context := redis.get('hero:current') or {
						return error("can't get hero:current from redis, is bug.")
					}
					parse_context(context, mut args)!
				}
				mut ui := gui.new()!
				if args.secret.len == 0 {
					args.secret = ui.ask_question(question: '\nPlease specify your secret.')!
				}
				if args.context == 'default' {
					args.context = ui.ask_question(
						question: '\nPlease specify your context, press enter if default.'
						default: 'default'
					)!
				}
				redis.set('hero:current', '${args.context}:${args.secret}') or {
					return error("can't set hero:current to redis, is bug.")
				}
				redis.expire('hero:current', 3600 * 24)! // remove the sensitive info out of local redis in 24 hours
			} else {
				return error("'MYSECRET' or 'MYCONTEXT' not set in env, or not given to arguments, you can also run interactive.")
			}
		}
		if args.secret.len < 7 {
			return error('secret needs to be at least 6 chars')
		}
	}

	if args.context.len < 4 {
		return error('context needs to be at least 3 chars')
	}

	mut p := pathlib.get_dir(create: true, path: '${os.home_dir()}/hero/db/${args.context}')!
	mut db := KVSContext{
		path: p
		config: args
	}
	return db
}

fn parse_context(context string, mut args KVSConfig) ! {
	if context.contains(':') {
		spl := context.split(':')
		if spl.len == 2 {
			args.secret = spl[1].trim_space()
			args.context = spl[0].trim_space()
		} else {
			return error("format: 'export MYCONTEXT=contextname:mysecret'")
		}
	} else {
		return error("format: 'export MYCONTEXT=contextname:mysecret'")
	}
}

// checks if db exists in context
pub fn (mut db KVSContext) exists(name_ string) bool {
	name := texttools.name_fix(name_)
	return db.path.dir_exists(name)
}

pub fn (mut db KVSContext) delete(name_ string) ! {
	name := texttools.name_fix(name_)
	mut datafile := db.path.dir_get(name) or { return }
	datafile.delete()!
}

pub fn (mut db KVSContext) keys() ![]string {
	mut r := db.path.list(recursive: false, dirs_only: true)!
	mut res := []string{}
	for item in r.paths {
		res << item.name()
	}
	return res
}

pub fn (mut db KVSContext) prefix(prefix string) ![]string {
	mut res := []string{}
	for item in db.keys()! {
		// println(" ---- $item ($prefix)")
		if item.trim_space().starts_with(prefix) {
			// println("888")
			res << item
		}
	}
	return res
}

// delete all data in the context (be careful)
pub fn (mut db KVSContext) destroy() ! {
	db.path.delete()!
}
