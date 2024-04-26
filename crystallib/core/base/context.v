module base

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.dbfs

@[heap]
pub struct Context {
mut:
	gitstructure_ ?&gittools.GitStructure @[skip; str: skip]
pub mut:
	cid          string // rid.cid or just cid
	name         string // a unique name in cid
	params       paramsparser.Params
	snippets     map[string]string
	redis        &redisclient.Redis  @[skip; str: skip]
	dbcollection &dbfs.DBCollection  @[skip; str: skip]
}

// return the gistructure as is being used in context
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

// return the coderoot as is used in context
pub fn (mut self Context) coderoot() !string {
	mut db := self.dbcollection.get('context')!
	coderoot := db.get('coderoot')!
	return coderoot
}

///////// LOAD & SAVE

fn (mut self Context) key() string {
	return 'contexts:${self.guid()}'
}

// load the params from redis
pub fn (mut self Context) load() ! {
	mut db := self.dbcollection.get('context')!
	if db.exists('params') {
		paramtxt := db.get('params')!
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
// 	return self.heroscript() or { "BUG: can't represent the object properly, I try raw" }
// }

fn (mut self Context) str2() string {
	return 'cid:${self.cid} name:${self.name}'
}

pub fn (mut self Context) heroscript() !string {
	mut out := '!!core.context_define ${self.str2()}\n'
	if !self.params.empty() {
		out += '\n!!core.params_context_set'
		out += texttools.indent(self.params.heroscript(), '    ') + '\n'
	}
	// if self.snippets.len > 0 {
	// 	for key, snippet in self.snippets {
	// 		out += '\n!!core.snippet guid:${self.guid()} name:${key}'
	// 		out += texttools.indent(snippet.heroscript(),"    ") + '\n'
	// 	}
	// }
	return out
}

pub fn (mut self Context) guid() string {
	return '${self.cid}:${self.name}'
}

fn (mut self Context) db_get(dbname string) !dbfs.DB {
	return self.dbcollection.get(dbname)!
}

// always return the config db which is the same for all apps in context
fn (mut self Context) db_config_get() !dbfs.DB {
	return self.dbcollection.get('config')!
}
