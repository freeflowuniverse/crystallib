module main

import httpconnection
// import crystaljson
// import json
// import x.json2
// import os

fn do() ? {
	// http.CommonHeader.authorization: 'Bearer $h.auth.auth_token'

	mut conn := httpconnection.new('example', 'https://reqres.in/api/', true)

	// do the cache on the connection
	conn.cache.expire_after = 7200 // make the cache expire_after 2h

	// make sure we empty cache
	conn.cache_drop()?

	// subkey will get result of rest call & get subset of dict
	r := conn.get_json_dict(mut prefix: 'users')?
	println(r)

	// will return as list but will start from subkey data
	mut r2 := conn.get_json_list(mut prefix: 'users', dict_key: 'data')?
	println(r2)

	t3 := go conn.get_json_str(mut prefix: 'users', id: '1', dict_key: 'data')
	d3 := t3.wait()?
	println(d3)

	// mut rc3,r3 := conn.get_json_str(mut prefix:"users", id:"1", dict_key:"data")?

	// println(rc3)
	// println(r3)

	// resp := conn.get_json_str('tasks', '', true) ?
	// raw_data := json2.raw_decode(resp.replace('\\\\', '')) ?
	// blocks := raw_data.arr()
	// os.write_file('/tmp/httpconnection_blocks/tasks', '$blocks') ?
	// println('[+] Loading $blocks.len tasks ...')
	// for t in blocks {
	// 	mut task := Task{}
	// 	task = task_decode(t.str()) or {
	// 		eprintln(err)
	// 		Task{}
	// 	}
	// 	if task != Task{} && task.project in conn.projects {
	// 		conn.task_remember(task)
	// 	}
	// }	
}

fn main() {
	do() or { panic(err) }
}
