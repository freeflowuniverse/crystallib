module zdb

import freeflowuniverse.crystallib.clients.zdb

fn test_get() {
	// must set unix domain with --socket argument when running zdb
	// run zdb as following:
	//		mkdir -p ~/.zdb/ && zdb --socket ~/.zdb/socket --admin 1234
	install(secret: 'hamada', start: true) or { panic(err) }
	
	mut client := zdb.get('/root/hero/var/zdb.sock', 'hamada', 'test') or { panic(err) }

	// check info returns info about zdb
	info := client.info()!
	assert info.contains('server_name: 0-db')

	nslist := client.nslist()!
	assert nslist == ['default', 'test']

	nsinfo := client.nsinfo('default')!
	assert nsinfo['name'] == 'default'
}
