module base

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.dbfs
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import crypto.md5

pub struct ContextConfigArgs {
pub mut:
	id			u32 @[required]
	name        string = 'default'
	params      string
	coderoot    string
	interactive bool
	secret      string
	priv_key_hex string //hex representation of private key
}



// configure a context object
// params: .
// ```
// id			u32 @[required]
// name        string = 'default'
// params      string
// coderoot    string
// interactive bool
// secret      string
// priv_key_hex string //hex representation of private key
// ```
fn context_new(args_ ContextConfigArgs) !&Context {
	
	mut args := ContextConfig{
			id:args_.id
			name:args_.name
			params:args_.params
			coderoot:args_.coderoot
			interactive:args_.interactive
			secret:args_.secret
		}
	
	mut r := redisclient.core_get()!
	if args.id > 0 {
		// make sure we are on the right db
		r.selectdb(args.id)!
	}

	if args.secret == '' && args.interactive {
		mut myui := ui.new()!
		console.clear()
		args.secret = myui.ask_question(question: 'Please enter your hero secret string:')!

	}

	args.secret = md5.hexhash(args.secret)

	mut dbcollection := dbfs.get(context_id: args.id)!

	mut c := Context{
		config: args
		redis: &r
		dbcollection: &dbcollection
	}

	if args_.priv_key_hex.len>0{
		c.privkey_set(args_.priv_key_hex)!
	}

	c.save()!

	if args.params.len > 0 {
		mut p := paramsparser.new('')!
		c.params_ = &p
	}
	
	contexts[args.id] = &c

	return contexts[args.id] or {panic("bug")}
}


fn context_get(id u32) !&Context {

	if id in contexts{
		return contexts[id] or {panic("bug")}
	}



	return error("cant find context with id: %{id}")
}

