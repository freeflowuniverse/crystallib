module twinsafe

import freeflowuniverse.crystallib.algo.aes_symmetric

// this is me, my representation
pub struct MyConfig {
pub mut:
	id          u32       [primary; sql: serial]
	name        string    [nonull]
	description string
	config      string [skip] // this is 3script which holds the initialization content for configuration of anything
	keysafe     &KeysSafe [skip] // allows us to remove ourselves from mem, or go to db
	config_enc string
}

[params]
pub struct MyConfigAddArgs {
pub:
	name        string
	description string
	config      string
}

// generate a new key is just importing a key with a random seed
// if it exists will return the key which is already there
pub fn (mut ks KeysSafe) myconfig_add(args_ MyConfigAddArgs) ! {
	config_enc := aes_symmetric.encrypt(args_.config, ks.secret)
	myconfig := MyConfig{
		name: args_.name
		description: args_.description
		config: args_.config
		config_enc: config_enc
		keysafe: ks
	}
	configs := sql ks.db {
		select from MyConfig where name == myconfig.name
	}!
	if configs.len > 0 {
		return GetError{
			args: GetArgs{
				id:   configs[0].id,
				name: configs[0].name
			}
			msg: 'myconfig with name: ${configs[0].name} aleady exist'
			error_type: GetErrorType.alreadyexists
		}
	}
	sql ks.db {
		insert myconfig into MyConfig
	}!
	ks.myconfigs[myconfig.name] = myconfig
}

// I can have more than 1 myconfig, ideal for testing as well
pub fn (mut ks KeysSafe) myconfig_get(args GetArgs) !MyConfig {
	configs := sql ks.db {
		select from MyConfig where name == args.name
	}!
	if configs.len == 1 {
		myconfig := configs[0]
		config := aes_symmetric.decrypt(myconfig.config_enc, ks.secret)
		myconfig.config = config
		myconfig.keysafe = ks
		return myconfig
	}
	return  GetError{
		args: args,
		msg: "couldn't get myconfig with name: ${args.name}" 
		error_type: GetErrorType.notfound}
}

pub fn (mut myconfig MyConfig) delete() ! {
	myconfig.keysafe.myconfigs.delete(myconfig.name)
	sql myconfig.keysafe.db {
		delete from MyConfig where id == myconfig.id
	}!
}

pub fn (mut myconfig MyConfig) save() ! {
	myconfig.config_enc = aes_symmetric.encrypt(myconfig.config, twin.keysafe.secret)

	cfgs := sql myconfig.keysafe.db {
		select from MyConfig where name == myconfig.name
	}!
	if cfgs.len > 0 {
		// twin already exists in the data base so we update
		sql myconfig.keysafe.db {
			update MyConfig set name = myconfig.name, description = myconfig.description, config_enc = myconfig.config_enc
			where id == cfgs[0].id
		}!
		return
	}
	sql myconfig.keysafe.db {
		insert myconfig into MyConfig
	}!
}
