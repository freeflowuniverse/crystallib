module twinclient2

import json

// Set a new record in my kvstore as key and value, if success return account_id
pub fn (mut tw TwinClient) set_kvstore(key string, value string) ?string {
	response := tw.send('kvstore.set', '{"key": "$key", "value": "$value"}')?

	return response.data
}

// Get a record from my kvstore using key
pub fn (mut tw TwinClient) get_kvstore(key string) ?string {
	response := tw.send('kvstore.get', '{"key": "$key"}')?

	return response.data
}

// List all keys in my kvstore
pub fn (mut tw TwinClient) list_kvstore() ?[]string {
	response := tw.send('kvstore.list', '{}')?

	return json.decode([]string, response.data) or {}
}

// Remove a record from my kvstore using key, if success return account_id
pub fn (mut tw TwinClient) remove_kvstore(key string) ?string {
	response := tw.send('kvstore.remove', '{"key": "$key"}')?

	return response.data
}

// Remove all my records in my kvstore, if success return deleted Keys
pub fn (mut tw TwinClient) remove_all_kvstore() ?[]string {
	response := tw.send('kvstore.removeAll', '{}')?

	return json.decode([]string, response.data) or {}
}
