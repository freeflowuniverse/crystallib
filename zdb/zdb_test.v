module zdb

fn test_get() {
	// must set unix domain with --socket argument when running zdb
	// run zdb as following: ./zdbd/zdb --socket /socket/path --admin 1234 || true
	mut zdb := get("/Users/timurgordon/zdb","1234","test")!

	// check info returns info about zdb
	info := zdb.info()!
	assert info.contains('server_name: 0-db')

	nslist := zdb.nslist()!
	assert nslist == ['default', 'test']

	nsinfo := zdb.nsinfo('default')!
	assert nsinfo.contains('name: default')
}