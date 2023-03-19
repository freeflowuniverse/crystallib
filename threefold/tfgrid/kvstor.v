module tfgrid

import json

//>TODO: needs to be redone using the redis

// Set a new record in my kvstore as key and value, if success return account_id
pub fn (mut client TFGridClient) kvstore_set(key string, value string) !string {
	response := client.rpc('kvstore.set', '{"key": "${key}", "value": "${value}"}')!
	return response.data
}

// Get a record from my kvstore using key
pub fn (mut client TFGridClient) kvstore_get(key string) !string {
	response := client.rpc('kvstore.get', '{"key": "${key}"}')!
	return response.data
}

pub struct KVStorListArgs{
pub:
	reset bool
}


// List all keys in my kvstore
pub fn (mut client TFGridClient) kvstore_list() ![]string {
	response := client.rpc('kvstore.list', '{}')!
	return json.decode([]string, response.data) or {}
}

// Remove a record from my kvstore using key, if success return account_id
pub fn (mut client TFGridClient) kvstore_remove(key string) !string {
	response := client.rpc('kvstore.remove', '{"key": "${key}"}')!
	return response.data
}

// Remove all my records in my kvstore, if success return deleted Keys
pub fn (mut client TFGridClient) kvstore_remove_all() ![]string {
	response := client.rpc('kvstore.removeAll', '{}')!
	return json.decode([]string, response.data) or {}
}
