module http

import arrays

pub fn merge_http(http1 HTTP, http2 HTTP) HTTP {
	mut servers := http1.servers.clone()

	for key2, server2 in http2.servers {
		if key2 in servers {
			servers[key2] = merge_servers(servers[key2], server2)
		} else {
			servers[key2] = server2
		}
	}
	return HTTP{
		servers: servers
	}
}

pub fn merge_servers(server1 Server, server2 Server) Server {
	mut listen := server1.listen.clone()

	for port in server2.listen {
		if !listen.contains(port) {
			listen << port
		}
	}

	mut routes := server1.routes.clone()

	for route2 in server2.routes {
		// only add routes for hosts that have not been defined
		route2_hosts := arrays.flatten[string](route2.@match.map(it.host.map(it)))
		routes_hosts := arrays.flatten[string](routes.map(arrays.flatten[string](it.@match.map(it.host.map(it)))))
		if !route2_hosts.any(it in routes_hosts) {
			routes << route2
		}
	}
	return Server{
		listen: listen
		routes: routes
	}
}
