module zdb

// TODO: enable this test when we have running zdb in ci also implement missing tests
fn test_get() {
	// 	// must set unix domain with --socket argument when running zdb
	// 	// run zdb as following:
	// 	//		mkdir -p ~/.zdb/ && zdb --socket ~/.zdb/socket --admin 1234
	// 	mut zdb := get('~/.zdb/socket', '1234', 'test')!

	// 	// check info returns info about zdb
	// 	info := zdb.info()!
	// 	assert info.contains('server_name: 0-db')

	// 	nslist := zdb.nslist()!
	// 	assert nslist == ['default', 'test']

	// 	nsinfo := zdb.nsinfo('default')!
	// 	assert 'name: default' in nsinfo
}
