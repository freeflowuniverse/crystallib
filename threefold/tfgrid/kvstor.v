module tfgrid

// Set a new record in my kvstore as key and value, if success return account_id
pub fn (mut client TFGridClient) kvstore_set(key string, value string) !string {
	retqueue := client.rpc.call[KeyValue]('tfgrid.kvstore.set', KeyValue{ key: key, value: value })!
	return client.rpc.result[string](5000, retqueue)!
}

// Get a record from my kvstore using key
pub fn (mut client TFGridClient) kvstore_get(key string) !string {
	retqueue := client.rpc.call[string]('tfgrid.kvstore.get', key)!
	return client.rpc.result[string](5000, retqueue)!
}

// List all keys in my kvstore
pub fn (mut client TFGridClient) kvstore_list() ![]string {
	retqueue := client.rpc.call[string]('tfgrid.kvstore.list', '')!
	return client.rpc.result[[]string](5000, retqueue)!
}

// Remove a record from my kvstore using key, if success return account_id
pub fn (mut client TFGridClient) kvstore_remove(key string) !string {
	retqueue := client.rpc.call[string]('tfgrid.kvstore.remove', key)!
	return client.rpc.result[string](5000, retqueue)!
}

// Remove all my records in my kvstore, if success return deleted Keys
pub fn (mut client TFGridClient) kvstore_remove_all() ![]string {
	retqueue := client.rpc.call[string]('tfgrid.kvstore.removeAll', '')!
	return client.rpc.result[[]string](5000, retqueue)!
}
