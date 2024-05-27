# HTTP connection

http client with caching in redis (default disabled)


```v

//as given to get
pub struct Request {
	method        Method
	prefix        string
	id            string
	params        map[string]string
	data          string
	cache_disable bool = true
	header        Header
	dict_key      string
}

import freeflowuniverse.crystallib.clients.httpconnection

mut conn := httpconnection.new(name: 'coredns', url: 'http://localhost:3334')!	

r := conn.get(prefix: 'health')!
println(r)

if r.trim_space == "OK" {
    return
}



```