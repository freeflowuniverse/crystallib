module base

import freeflowuniverse.crystallib.data.paramsparser
// import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.clients.redisclient
// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.dbfs


@[params]
pub struct ContextConfigureArgs {
pub mut:
	cid            string = '000' // rid.cid or cid allone
	name           string // a unique name in cid
	params         string
	coderoot       string
	interactive    bool
	fsdb_encrypted bool
	secret         string
}

// configure a context object
// params: .
// ```
// cid          string = "000" // rid.cid or cid allone
// name         string = "default" // a unique name in cid
// params       string
// coderoot	 string
// interactive  bool
// secret string
// ```
//
fn context_configure(args_ ContextConfigureArgs) ! {
	mut args := args_

	if args.name == '' {
		args.name = 'default'
	}

	mut dbcollection := dbfs.get(
		context: args.name
		interactive: args.interactive
		secret: args.secret
	)!
	mut db := dbcollection.get( 'context')!
	db.set('coderoot', args.coderoot)!

	if args.params.len > 0 {
		db.set("params", args.params)!
	}
		
}

@[params]
pub struct ContextGetArgs {
pub mut:
	name        string // a unique name in cid
	interactive bool = true
}

pub fn context_get(args_ ContextGetArgs) !Context {
	mut args := args_

	mut dbcollection := dbfs.get(
		context: args.name
		interactive: args.interactive
	) or { return error('cannot get dbcollection: ${args.name}') }

	mut r := redisclient.core_get()!
	mut p := paramsparser.new('')!

	mut c := Context{
		name: args.name
		params: p
		redis: &r
		dbcollection: &dbcollection
	}
	c.load()!
	return c
}
