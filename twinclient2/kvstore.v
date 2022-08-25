module twinclient2

import json


fn new_kvstore(mut client TwinClient) KVstore {
	// Initialize new kvstore.
	return KVstore{
		client: unsafe {client}
	}
}

// Set a new record in my kvstore as key and value, if success return account_id
pub fn (mut kvs KVstore) set(key string, value string) ?string {
	response := kvs.client.send('kvstore.set', '{"key": "$key", "value": "$value"}')?
	return response.data
}

// Get a record from my kvstore using key
pub fn (mut kvs KVstore) get(key string) ?string {
	response := kvs.client.send('kvstore.get', '{"key": "$key"}')?
	return response.data
}

// List all keys in my kvstore
pub fn (mut kvs KVstore) list() ?[]string {
	response := kvs.client.send('kvstore.list', '{}')?
	return json.decode([]string, response.data) or {}
}

// Remove a record from my kvstore using key, if success return account_id
pub fn (mut kvs KVstore) remove(key string) ?string {
	response := kvs.client.send('kvstore.remove', '{"key": "$key"}')?
	return response.data
}

// Remove all my records in my kvstore, if success return deleted Keys
pub fn (mut kvs KVstore) remove_all() ?[]string {
	response := kvs.client.send('kvstore.removeAll', '{}')?
	return json.decode([]string, response.data) or {}
}
