module twinclient

import json

// Set a new record in my kvstore as key and value, if success return account_id
pub fn (mut tw Client) set_kvstore(key string, value string) ?string {
	mut msg := tw.send('twinserver.kvstore.set', '{"key": "$key", "value": "$value"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data
}

// Get a record from my kvstore using key
pub fn (mut tw Client) get_kvstore(key string) ?string {
	mut msg := tw.send('twinserver.kvstore.get', '{"key": "$key"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data
}

// List all keys in my kvstore
pub fn (mut tw Client) list_kvstore() ?[]string {
	mut msg := tw.send('twinserver.kvstore.list', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

// Remove a record from my kvstore using key, if success return account_id
pub fn (mut tw Client) remove_kvstore(key string) ?string {
	mut msg := tw.send('twinserver.kvstore.remove', '{"key": "$key"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data
}

// Remove all my records in my kvstore, if success return deleted Keys
pub fn (mut tw Client) remove_all_kvstore() ?[]string {
	mut msg := tw.send('twinserver.kvstore.removeAll', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}
