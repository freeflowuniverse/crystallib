module dbfs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.crypt.aes_symmetric
import encoding.base64

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
	ext string //extension if we want to use it in DB e.g. 'json'
	//base64 bool //if binary data will be base encoded
}

@[params]
pub struct GetArgs {
pub mut:
	key     string
	id      u32
}

// get the value, if it doesn't exist then return empty string
pub fn (mut db DB) get(args_ GetArgs) !string {
	mut args:=args_
	args.key = texttools.name_fix(args.key)
	if args.key.len>0{
		if db.config.withkeys{
			if db.config.keyshashed{
				//means we use a namedb
				mut ndb := db.namedb or {
						panic("namedb should be available")
					}
				args.id,_ =ndb.getdata(args.key)!
			}else{

			}
		}
	}

	mut pathsrc:=db.path_get(args.id)!

	mut data := pathsrc.read()!
	if data.len == 0 {
		panic('data cannot be empty for get:${args}')
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
	
	//lets deal with key
	if args.key.len>0{
		if args.id>0{
			return error("cant have id and key at same time")
		}
		if db.config.withkeys{
			if db.config.keyshashed{
				//means we use a namedb
				mut ndb := db.namedb or {
						panic("namedb should be available")
					}
				args.id = ndb.set(args.key,"")!
			}else{
				//write key in other ways
				args.id = db.parent.incr()!
			}
		}else{
			return error("if key specified, then db needs to be in keymode")
		}
	}
	mut pathsrc:=db.path_get(args.id)!
	//make symlink if keys are not hashed
	if db.config.withkeys && ! (db.config.keyshashed){
		mut destname:="${db.path.path}/${args.key}"
		if db.config.ext.len>0{
			destname+=".${db.config.ext}"
		}
		pathsrc.link(destname,true)! //link the key to the right source info
	}
	if db.config.encrypted {
		args.valueb = aes_symmetric.encrypt(args.valueb, db.secret()!)
	}
	//shortcut for now, need to use writeb later
	pathsrc.write(base64.encode(args.valueb))!

	assert args.id>0
	return args.id
}

//get path based on int id in the DB
fn (mut db DB) path_get(myid u32) !pathlib.Path {	
	a,b,c:=namedb_dbid(myid)
	mut destname:=c.str()
	if db.config.ext.len>0{
		destname+=".${db.config.ext}"
	}	
	mut mydatafile := pathlib.get_file(
		path: "${db.path.path}/${a}/${b}/${destname}"
		create: true
	)!
	return mydatafile
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