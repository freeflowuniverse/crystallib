module tfgrid

import json

pub fn (mut client TFGridClient) zdb_deploy(zdb ZDB) !ZDBResult {
	payload := json.encode_pretty(zdb)
	res := client.rpc.call(cmd: 'zdb.deploy', data: payload)!
	return json.decode(ZDBResult, res)
}

pub fn (mut client TFGridClient) zdb_delete(name string) ! {
	client.rpc.call(cmd: 'zdb.delete', data: name)!
}

pub fn (mut client TFGridClient) zdb_get(name string) !ZDBResult {
	res := client.rpc.call(cmd: 'zdb.get', data: name)!
	return json.decode(ZDBResult, res)
}