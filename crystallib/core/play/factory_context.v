module play

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.fskvs

@[heap]
pub struct Context {
mut:
	gitstructure_ ?&gittools.GitStructure @[skip; str: skip]
pub mut:
	cid       string // rid.cid or just cid
	name      string // a unique name in cid
	params    paramsparser.Params
	snippets  map[string]string
	redis     &redisclient.Redis  @[skip; str: skip]
	contextdb &fskvs.ContextDB    @[skip; str: skip]
}

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

// create context object, gets coderoot from before .
// params: .
// ```
// cid          string = "000" // rid.cid or cid allone
// name         string // a unique name in cid
// params       string
// coderoot	 string
// interactive  bool
// fsdb_encrypted bool	
// secret string
// ```
//
fn context_configure(args_ ContextConfigureArgs) ! {
	mut args := args_

	if args.name == '' {
		args.name = 'default'
	}

	mut r := redisclient.core_get()!
	if args.params.len > 0 {
		mut p := paramsparser.new(args.params)!
		rkey := 'hero:context:params:${args.name}'
		r.set(rkey, args.params)!
	}

	fskvs.contextdb_configure(
		name: args.name
		encrypted: args.fsdb_encrypted
		secret: args.secret
	)!

	mut contextdb := fskvs.contextdb_get(
		name: args.name
		interactive: args.interactive
	)!

	// need this dbname for the basic configuration
	contextdb.db_configure(dbname: 'context', encrypted: false)!

	mut db := contextdb.db_get(dbname: 'context')!

	db.set('coderoot', args.coderoot)!
}

@[params]
pub struct ContextGetArgs {
pub mut:
	name        string // a unique name in cid
	interactive bool
}

fn context_get(args_ ContextGetArgs) !Context {
	mut args := args_

	mut contextdb := fskvs.contextdb_get(
		name: args.name
		interactive: args.interactive
	) or { return error('cannot get contextdb: ${args.name}') }

	mut r := redisclient.core_get()!
	mut p := paramsparser.new('')!

	mut c := Context{
		name: args.name
		params: p
		redis: &r
		contextdb: &contextdb
	}
	c.load()!
	return c
}

pub fn (mut self Context) gitstructure() !&gittools.GitStructure {
	mut gs2 := self.gitstructure_ or {
		cr := self.coderoot()!
		mut gs := gittools.get(coderoot: cr)!
		self.gitstructure_ = &gs
		&gs
	}

	return gs2
}

pub fn (mut self Context) gitstructure_reload() ! {
	cr := self.coderoot()!
	mut gs := gittools.get(coderoot: cr)!
	self.gitstructure_ = &gs
}

pub fn (mut self Context) coderoot() !string {
	mut db := self.contextdb.db_get(dbname: 'context')!
	coderoot := db.get('coderoot')!
	return coderoot
}

///////// LOAD & SAVE

fn (mut self Context) key() string {
	return 'contexts:${self.guid()}'
}

// load the params from redis
pub fn (mut self Context) load() ! {
	mut r := self.redis
	rkey := 'hero:context:params:${self.name}'
	if r.exists(rkey)! {
		paramtxt := r.get(rkey)!
		self.params = paramsparser.new(paramtxt)!
	}
}

// save the params to redis
pub fn (mut self Context) save() ! {
	self.check()!
	mut r := self.redis
	rkey := 'hero:context:params:${self.name}'
	r.set(rkey, self.params.str())!
}

//////DATA

pub fn (mut self Context) check() ! {
	if self.name.len < 4 {
		print_backtrace()
		return error('name of context needs to be 4 or more chars. Now was: "${self.name}"')
	}
}

// pub fn (mut self Context) str() string {
// 	return self.script3() or { "BUG: can't represent the object properly, I try raw" }
// }

fn (mut self Context) str2() string {
	return 'cid:${self.cid} name:${self.name}'
}

pub fn (mut self Context) script3() !string {
	mut out := '!!core.context_define ${self.str2()}\n'
	if !self.params.empty() {
		out += '\n!!core.params_context_set'
		out += texttools.indent(self.params.script3(), '    ') + '\n'
	}
	// if self.snippets.len > 0 {
	// 	for key, snippet in self.snippets {
	// 		out += '\n!!core.snippet guid:${self.guid()} name:${key}'
	// 		out += texttools.indent(snippet.script3(),"    ") + '\n'
	// 	}
	// }
	return out
}

pub fn (mut self Context) guid() string {
	return '${self.cid}:${self.name}'
}

fn (mut self Context) db_get(dbname string) !fskvs.DB {
	return self.contextdb.db_get(dbname: dbname)!
}

fn (mut self Context) db_config_get() !fskvs.DB {
	return self.contextdb.db_get(dbname: 'config')!
}
