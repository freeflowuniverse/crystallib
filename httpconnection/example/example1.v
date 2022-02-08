

module main

import despiegk.crystallib.httpconnection
// import despiegk.crystallib.crystaljson
// import json
// import x.json2
// import os


fn do()?{

	// http.CommonHeader.authorization: 'Bearer $h.auth.auth_token'

	mut conn := httpconnection.new("test","https://reqres.in/api/",true)

	//do the settings on the connection
	conn.settings.retry = 3
	conn.settings.cache_timeout = 7200 //make the cache timeout 2h
	conn.settings.cache_enable = true

	//make sure we empty cache
	conn.cache_drop("")?

	//subkey will get result of rest call & get subset of dict
	mut r := conn.get_json_dict(mut prefix:"users")?

	//will return as list but will start from subkey data
	mut r2 := conn.get_json_list(mut prefix:"users", dict_key:"data")?

	mut r3 := conn.get_json_str(mut prefix:"users", id:"1", dict_key:"data")?

	println(r3)

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

	do() or {panic(err)}

}
