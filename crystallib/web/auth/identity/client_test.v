module identity

import net.http
import db.sqlite
import rand
import json
import vweb

fn testsuite_begin() {
	mut db := sqlite.connect('test.sqlite')!
	sql db {
		create table User
	} or { panic(err) }
	ctrl := &Controller{
		db:db
	}
	spawn vweb.run(ctrl, 8080)
}

fn test_register() {
	mut client := Client{'http://localhost:8080'}
	client.register(
		email: 'test@email.com'
	)!
}

// [get]
// pub fn (mut ctrl Controller) logs() vweb.Result {
// 	logs := sql ctrl.db {
// 		select from Log
// 	} or {
// 		ctrl.set_status(500, '')
// 		return ctrl.text('Failed insert log into db.')
// 	}
// 	return ctrl.json(logs)
// }


