
module tfgrid3deployer
import freeflowuniverse.crystallib.baobab.context

fn set (key string, data []u8)!{
	//set in context
	mut mycontext:=context_new.new()!
	mut db := mycontext.db_get("deployer")!
	db.set(key: key, value: encode(data.encode())!)!

}

fn delete (key string)!{
	
}

fn get (key string)![]u8 {
	
}



fn (mut self TFGridDeployer) encode (data []u8) ![]u8{
	//compression use https://modules.vlang.io/compress.zlib.html
	//encryption use https://modules.vlang.io/x.crypto.chacha20.html
	return data
	

}

fn (mut self TFGridDeployer) decode (data []u8) ![]u8{
	return data
}