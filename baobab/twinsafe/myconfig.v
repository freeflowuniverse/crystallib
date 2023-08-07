module twinsafe

//this is me, my representation
pub struct MyConfig{
pub:
	name string
	id u32
	description string
	config string //this is 3script which holds the initialization content for configuration of anything
	keysafe  &KeysSafe            [str: skip]  //allows us to remove ourselves from mem, or go to db
}


[params]
pub struct TwinAddArgs{
pub:
	name string
	id u32
	description string
	privatekey_generate bool
	privatekey string //given in hex or mnemonics
}


// generate a new key is just importing a key with a random seed
// if it exists will return the key which is already there
pub fn (mut ks KeysSafe) myconfig_add(args_ TwinAddArgs) ! {

}



//I can have more than 1 myconfig, ideal for testing as well
pub fn (mut ks KeysSafe) myconfig_get(args GetArgs) !MyConfig {


	//use sqlite to get info (do query)
	//decrypt the config
}


pub fn (mut o MyConfig) delete() ! {
    //delete from memory and from sqlitedb
}

pub fn (mut o MyConfig) save() ! {
    //update in DB, or insert if it doesn't exist yet
}

