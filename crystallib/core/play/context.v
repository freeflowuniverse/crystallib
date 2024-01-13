module play

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.osal.gittools
// import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.core.playbook

@[heap]
pub struct Context {
pub mut:
	cid          string // rid.cid or just cid
	name         string // a unique name in cid
	params       paramsparser.Params
	snippets     map[string]string
	gitstructure &gittools.GitStructure @[skip; str: skip]
	redis        &redisclient.Redis     @[skip; str: skip]
	kvs          &fskvs.KVSContext      @[skip; str: skip]
}

@[params]
pub struct ContextNewArgs {
pub mut:
	cid             string = '000' // rid.cid or cid allone
	name            string // a unique name in cid
	params          string
	coderoot        string
	interactive     bool
	fsdb_encryption bool
	// script3         string // if context is created from a 3script
}

// create context object .
// params: .
// ```
// cid          string = "000" // rid.cid or cid allone
// name         string // a unique name in cid
// params       string
// coderoot	 string
// interactive  bool
// fsdb_encryption bool	
// ```
//
fn new(args_ ContextNewArgs) !Context {
	mut args := args_
	mut p := paramsparser.new(args.params)!

	if args.name == '' {
		args.name = 'default'
	}

	mut r := redisclient.core_get()!

	mut kvs := fskvs.new(
		context: args.name
		encryption: args.fsdb_encryption
		interactive: args.interactive
	)!

	mut kvsconfig := kvs.get(name: 'config', encryption: false)! // if encryption set, needs to always be encrypted TODO:despiegk
	if args.coderoot == '' {
		args.coderoot = kvsconfig.get('coderoot')!
	} else {
		kvsconfig.set('coderoot', args.coderoot)!
	}

	mut gs := gittools.get(coderoot: args.coderoot)!

	mut c := Context{
		cid: args.cid
		name: args.name
		params: p
		gitstructure: &gs
		redis: &r
		kvs: &kvs
	}
	c.check()!
	return c
}

pub fn (mut self Context) coderoot() string {
	return self.gitstructure.rootpath.path
}

///////// LOAD & SAVE

fn (mut self Context) key() string {
	return 'contexts:${self.guid()}'
}

// save the context to redis & mem
pub fn (mut self Context) load() ! {
	mut r := self.redis
	t := r.get(self.key())!
	if t == '' {
		return
	}
}

// save the self to redis & mem
pub fn (mut self Context) save() ! {
	self.check()!
	mut r := self.redis
	r.set(self.key(), self.script3()!)!
	r.expire(self.key(), 3600 * 48)!
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

fn (mut self Context) db_get(name string) !fskvs.KVS {
	return self.kvs.get(name: name)!
}

fn (mut self Context) db_config_get() !fskvs.KVS {
	return self.kvs.get(name: 'config')!
}
