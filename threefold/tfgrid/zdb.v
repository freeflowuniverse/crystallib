module tfgrid

pub fn (mut client TFGridClient) zdb_deploy(zdb ZDB) !ZDBResult {
	retqueue := client.rpc.call[ZDB]('tfgrid.zdb.deploy', zdb)!
	return client.rpc.result[ZDBResult](500000, retqueue)!
}

pub fn (mut client TFGridClient) zdb_delete(name string) ! {
	retqueue := client.rpc.call[string]('tfgrid.zdb.delete', name)!
	_ := client.rpc.result[ZDBResult](500000, retqueue)!
}

pub fn (mut client TFGridClient) zdb_get(name string) !ZDBResult {
	retqueue := client.rpc.call[string]('tfgrid.zdb.get', name)!
	return client.rpc.result[ZDBResult](500000, retqueue)!
}
