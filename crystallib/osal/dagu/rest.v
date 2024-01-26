module dagu

// pub fn get(args GetArgs) !bool {
// 	//this checks health of dagu
// 	// curl http://localhost:3333/api/v1/s --oauth2-bearer 1234 works
// 	mut conn := httpconnection.new(name: 'dagu', url: 'http://localhost:3333/api/v1/')!	
// 	if args.secret.len>0{
// 		conn.default_header.add(.authorization, 'Bearer ${args.secret}')
// 	}
// 	conn.default_header.add(.content_type, 'application/json')	
// 	r := conn.get_json_dict(prefix: 'dags') or {return false}
// 	// r := conn.get_json_dict(prefix: 'dags')!
// 	dags:=r["DAGs"] or {return false}
// 	// println(dags)
// 	// dags:=r["DAGs"] or {return error("can't find DAG's in json.\n$r")}
// 	// println(dags)
// 	// println(dags.arr().len)
// 	// if r.trim_space() == "OK" {
// 	// 	return true
// 	// }
// 	return true

// }
