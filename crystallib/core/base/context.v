module base

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.dbfs
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.crypt.secp256k1
import freeflowuniverse.crystallib.crypt.aes_symmetric
import crypto.md5
import encoding.base64
import json

@[heap]
pub struct Context {
mut:
	gitstructure_ ?&gittools.GitStructure @[skip; str: skip]
	priv_key_     ?&secp256k1.Secp256k1
	params_		 ?&paramsparser.Params
pub mut:
	snippets     map[string]string
	redis        &redisclient.Redis  @[skip; str: skip]
	dbcollection &dbfs.DBCollection  @[skip; str: skip]
	config 		 ContextConfig
	
}

@[params]
pub struct ContextConfig {
pub mut:
	id			u32 @[required]
	name        string = 'default'
	params      string
	coderoot    string
	interactive bool
	secret      string
	priv_key string //encrypted version
}


// return the gistructure as is being used in context
pub fn (mut self Context) params() !&paramsparser.Params {
	mut p := self.params_ or {
		mut p := paramsparser.new(self.config.params)!
		self.params_ = &p
		&p
	}
	return p
}

// return the gistructure as is being used in context
pub fn (mut self Context) gitstructure() !&gittools.GitStructure {
	mut gs2 := self.gitstructure_ or {
		mut gs := gittools.get(coderoot: self.config.coderoot)!
		self.gitstructure_ = &gs
		&gs
	}

	return gs2
}

pub fn (mut self Context) gitstructure_reload() ! {
	mut gs := gittools.get(coderoot: self.config.coderoot)!
	self.gitstructure_ = &gs
}

//////DATA

pub fn (mut self Context) check() ! {
	if self.config.name.len < 4 {
		print_backtrace()
		return error('name of context needs to be 4 or more chars. Now was: "${self.config.name}"')
	}
}

// pub fn (mut self Context) str() string {
// 	return self.heroscript() or { "BUG: can't represent the object properly, I try raw" }
// }

fn (mut self Context) str2() string {
	panic("implement")
	//return 'cid:${self.cid} name:${self.name}'
}

pub fn (mut self Context) heroscript() !string {
	panic("implement")
	mut out := '!!core.context_define ${self.str2()}\n'
	mut p:=self.params()!
	if !p.empty() {
		out += '\n!!core.params_context_set'
		out += texttools.indent(p.heroscript(), '    ') + '\n'
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
	panic("implement")
	//return '${self.cid}:${self.name}'
	return ""
}

pub fn (mut self Context) save()! {
	jsonargs:=json.encode_pretty(self.config)
	self.redis.set("context:config",jsonargs)! 
}

//get context from out of redis
pub fn (mut self Context) load()! {
	d:=self.redis.get("context:config")! 
	self.config =json.decode(ContextConfig,d)!
}


fn (mut self Context) db_get(dbname string) !dbfs.DB {
	return self.dbcollection.get(dbname)!
}

// always return the config db which is the same for all apps in context
fn (mut self Context) db_config_get() !dbfs.DB {
	return self.dbcollection.get('config')!
}

/////////////PRIVKEY

pub fn (mut self Context) privkey_new() !&secp256k1.Secp256k1 {
	mypk := secp256k1.new()!
	return self.privkey_set(mypk.private_key_hex())!
}

pub fn (mut self Context) privkey_set(keyhex string) !&secp256k1.Secp256k1 {
	privkeyencr := self.secret_encrypt(keyhex)!
	self.config.priv_key = privkeyencr
	self.save()!
	return self.privkey()
}

// get the private key
pub fn (mut self Context) privkey() !&secp256k1.Secp256k1 {
	mut mypk := self.priv_key_ or {
		mut key := self.redis.get('context:privkey') or { '' }
		if key == '' {
			return error("can't find priv key for context:${self.config.id}")
		}
		key = self.secret_decrypt(key)!
		mut mypk := secp256k1.new(
			privhex: key
		)!
		self.priv_key_ = &mypk
		&mypk
	}

	return mypk
}

/////////////SECRET MANAGEMENT

// show a UI in console to configure the secret
pub fn (mut self Context) secret_configure() ! {
	mut myui := ui.new()!
	console.clear()
	secret_ := myui.ask_question(question: 'Please enter your hero secret string:')!
	self.secret_set(secret_)!
}

// unhashed secret
pub fn (mut self Context) secret_set(secret_ string) ! {
	mut r := self.redis
	secret := secret_.trim_space()
	secret2 := md5.hexhash(secret)
	self.config.secret = secret2
	self.save()!
}

pub fn (mut self Context) secret_get() !string {
	if self.config.secret == '' {
		if self.config.interactive == false {
			return error("can't use secret_get in non-interactive mode on context")
		}
		self.secret_configure()!
	}
	return self.config.secret
}

// will use our secret as configured for the hero to encrypt, uses base64
pub fn (mut self Context) secret_encrypt(txt string) !string {
	mut secret := self.secret_get()!
	d := aes_symmetric.encrypt_str(txt, secret)
	return d
}

pub fn (mut self Context) secret_decrypt(txt string) !string {
	mut secret := self.secret_get()!
	return aes_symmetric.decrypt_str(txt, secret)
}
