module base

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.dbfs
import freeflowuniverse.crystallib.crypt.secp256k1
import freeflowuniverse.crystallib.crypt.aes_symmetric
import crypto.md5

@[heap]
pub struct Context {
mut:
	gitstructure_ ?&gittools.GitStructure @[skip; str: skip]
	priv_key_     ?&secp256k1.Secp256k1	
	secret_       string
pub mut:
	id 			 int //corresponds to redis DB, min is 1
	name         string
	params       paramsparser.Params
	snippets     map[string]string
	redis        &redisclient.Redis  @[skip; str: skip]
	dbcollection &dbfs.DBCollection  @[skip; str: skip]
	interactive bool = true

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


/////////////PRIVKEY

pub fn (mut self Context) privkey_new() !&secp256k1.Secp256k1	 {
	mypk := secp256k1.new()!	
	return self.privkey_set(mypk.private_key())!
}

pub fn (mut self Context) privkey_set(key string) !&secp256k1.Secp256k1	 {
	mut mypk := secp256k1.new(
		privhex: key
	)!
	privkeyencr:=self.secret_encrypt(mypk.private_key())!
	self.redis.set("context:privkey",privkeyencr)!
	return self.privkey()
}

//get the private key
pub fn (mut self Context) privkey() !&secp256k1.Secp256k1	 {
	mut mypk := self.priv_key_ or {
		mut key:=self.redis.get("context:privkey") or {""}
		if key==""{
			return error("can't find priv key for context:${self.id}")
		}
		key=self.secret_decrypt(key)!
		mut mypk := secp256k1.new(
			privhex: key
		)!		
		self.priv_key_ = &mypk
		&mypk
	}	
	return mypk
}


/////////////SECRET MANAGEMENT

//show a UI in console to configure the secret
pub fn (mut self Context) secret_configure() ! {
	mut myui := ui.new()!
	console.clear()
	secret_ := myui.ask_question(question: 'Please enter your hero secret string:')!
	return self.secret_set(secret_)!

}


//unhashed secret
pub fn (mut self Context) secret_set(secret string) ! {
	mut r := self.redis
	secret2 = md5.hexhash(secret)
	r.set(key, secret2)!
	self.secret_ = secret2
	return secret2
}

pub fn (mut self Context) secret_get() !string {
	if self.secret_==""{
		mut r := self.redis
		key := 'context:secret'
		mut secret := r.get(key)!
		if secret.len == 0 {
			if self.interactive == false {
				return error("can't use secret_get in non-interactive mode on context")
			}			
			return self.secret_configure()!
		}
		self.secret_ = secret
	}
	return self.secret_
}


//will use our secret as configured for the hero to encrypt
pub fn (mut self Context) secret_encrypt(txt string) !string {
	mut secret:=self.secret_get()!
	d:= aes_symmetric.encrypt_str(txt, secret)
	return base64.encode_str(d)

}

pub fn (mut self Context) secret_decrypt(txt string) !string {
	mut secret:=self.secret_get()!
	txt2:=base64.decode_str(txt)
	return aes_symmetric.decrypt_str(txt2, secret)
}

