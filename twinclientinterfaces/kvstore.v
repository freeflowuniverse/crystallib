module twinclientinterfaces

import json


// Set a new record in my kvstore as key and value, if success return account_id
pub fn (mut client TwinClient) kvstore_set(key string, value string) ?string {
	response := client.transport.send('kvstore.set', '{"key": "$key", "value": "$value"}')?
	return response.data
}

// Get a record from my kvstore using key
pub fn (mut client TwinClient) kvstore_get(key string) ?string {
	response := client.transport.send('kvstore.get', '{"key": "$key"}')?
	return response.data
}

// List all keys in my kvstore
pub fn (mut client TwinClient) kvstore_list() ?[]string {
	response := client.transport.send('kvstore.list', '{}')?
	return json.decode([]string, response.data) or {}
}

// Remove a record from my kvstore using key, if success return account_id
pub fn (mut client TwinClient) kvstore_remove(key string) ?string {
	response := client.transport.send('kvstore.remove', '{"key": "$key"}')?
	return response.data
}

// Remove all my records in my kvstore, if success return deleted Keys
pub fn (mut client TwinClient) kvstore_remove_all() ?[]string {
	response := client.transport.send('kvstore.removeAll', '{}')?
	return json.decode([]string, response.data) or {}
}
