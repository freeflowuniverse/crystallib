
module tfgrid3deployer
import freeflowuniverse.crystallib.core.base as context

// Will be changed when we support the logic of the TFChain one
pub struct KVStoreFS {}

fn (kvs KVStoreFS)set(key string, data []u8)! {
	//set in context
	mut mycontext := context.context_new()!
	mut session := mycontext.session_new(name: "deployer")!
	mut db := session.db_get()!
	db.set(key: key, valueb: data) or { return error("Cannot set the key due to: ${err}")}
}

fn (kvs KVStoreFS)get(key string)![]u8{
	mut mycontext := context.context_new()!
	mut session := mycontext.session_new(name: "deployer")!
	mut db := session.db_get()!
	value := db.get(key: key) or { return error("Cannot get value of key ${key} due to: ${err}") }
	if value.len == 0 {
		return error("The value is empty.")
	}

	return value.bytes()
}

fn (kvs KVStoreFS)delete(key string)!{

}
