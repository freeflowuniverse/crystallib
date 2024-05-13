module dbfs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.crypt.aes_symmetric

@[heap]
pub struct DB {
pub:
	config DBConfig
pub mut:
	path      pathlib.Path
	parent    &DBCollection @[skip; str: skip]
	namedb 	  ?NameDB //optional namedb which is for hashed keys
}

pub struct DBConfig {
pub mut:
	name string
	encrypted bool
	withkeys bool //if set means we will use keys in stead of only u32
	keyshashed bool //if its ok to hash the keys, which will generate id out of these keys and its more scalable
	//base64 bool //if binary data will be base encoded
}


// get the value, if it doesn't exist then return empty string
pub fn (mut db DB) get(key_ string) !string {
	key := texttools.name_fix(key_)
	if !db.exists(key) {
		return ''
	}
	mut datafile := db.path.file_get_new(key)!
	mut data := datafile.read()!
	if data.len == 0 {
		panic('data cannot be empty for get:${key}')
	}
	if db.config.encrypted {
		data = aes_symmetric.decrypt_str(data, db.secret()!)
	}
	return data
}

@[params]
pub struct SetArgs {
pub mut:
	key     string
	id      u32
	value   string
	valueb   []u8 //as bytes
}


// set the key/value will go to filesystem, is organzed per context and each db has a name
pub fn (mut db DB) set(args_ SetArgs) !u32 {
	mut args:=args_
	if args.value.len==0 && args.valueb.len==0 {
		return error("specify for value or valueb, now both empty")
	}		
	if args.key.len>0{
		args.key = texttools.name_fix(args.key)
	}

	if args.value.len>0  {
		args.valueb = args.value.bytes()
		args.value = ""
	}	
	
	mut datafile := db.path.file_get_new(key)!
	if db.config.encrypted {
		args.valueb = aes_symmetric.encrypt(args.valueb, db.secret()!)
	}
	datafile.write(args.valueb)!
}

@[params]
pub struct GetArgs {
pub mut:
	key     string
	id      u32
}

pub fn (mut db DB) key_register(key string,data string) !u32 {
	if db.config.withkeys{
		if db.config.keyshashed{
			//means we use a namedb
			mut ndb := db.namedb or {
					panic("namedb should be available")
				}
			return ndb.set(key,data)!
		}
		if data.len>0{panic("bug, data should not be used for when namedb is not available")}
		return db.parent.incr()!
	}else{
		return error("can't use keys for database which is not configured as such.")
	}
}

//key can be linked to a string and this will also be returned, is stored in our namedb
pub fn (mut db DB) key_get(key string) !(u32,string) {
	if db.config.withkeys{
		if db.config.keyshashed{
			//means we use a namedb
			mut ndb := db.namedb or {
					panic("namedb should be available")
				}
			return ndb.get(key)!
		}
		if data.len>0{panic("bug, data should not be used for when namedb is not available")}
		return db.parent.incr()!
	}else{
		return error("can't use keys for database which is not configured as such.")
	}

}

// check if entry exists based on keyname
pub fn (mut db DB) exists(key_ string) bool {
	if args.key.len>0{
		args.key = texttools.name_fix(args.key)
	}

	if !(db.path.file_exists(key)) {
		return false
	}
	mut datafile := db.path.file_get(key) or { panic(err) }
	mut data := datafile.read() or { panic(err) }
	if data.len == 0 {
		datafile.delete() or { panic(err) }
		return false
	}
	return true
}

// delete an entry
pub fn (mut db DB) delete(key_ string) ! {
	key := texttools.name_fix(key_)
	mut datafile := db.path.file_get(key) or { return }
	datafile.delete()!
}

// delete the db, will not be able to use it any longer
pub fn (mut db DB) destroy() ! {
	db.path.delete()!
}

// get all keys of the db (e.g. per session) can be with a prefix
pub fn (mut db DB) keys(prefix_ string) ![]string {
	prefix := texttools.name_fix(prefix_)
	mut r := db.path.list(recursive: false)!
	mut res := []string{}
	for item in r.paths {
		name := item.name()
		if prefix == '' || name.starts_with(prefix) {
			res << name
		}
	}
	return res
}

// delete all data
pub fn (mut db DB) empty() ! {
	db.path.empty()!
	if db.config.encrypted {
		// need to make sure we restore the encrypted file
		db.path.file_get_new('encrypted')!
	}
}

fn (mut db DB) secret() !string {
	if db.config.encrypted {
		return db.parent.secret
	}
	return ''
}

// will mark db for encryption .
// will go over all existing keys and encrypt
pub fn (mut db DB) encrypt() ! {
	if db.config.encrypted {
		return
	}
	db.secret()! // just to check if ok
	for key in db.keys('')! {
		db.config.encrypted = false
		v := db.get(key)!
		db.config.encrypted = true
		db.set(key, v)!
	}
	db.config.encrypted = true
	db.path.file_get_new('encrypted')!
}

// incr_file:=dbcollection.path.file_get_new("incr_${memberid}")!